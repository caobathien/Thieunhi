import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/bible_verses.dart';

/// ═══════════════════════════════════════════════════════════════════
/// SPIRITUAL NOTIFICATION SERVICE
/// Thông báo hằng ngày: Lời Chúa + Kinh Sáng (5h) + Kinh Tối (22h)
/// Chỉ hoạt động trên Android/iOS (không hỗ trợ Web)
/// ═══════════════════════════════════════════════════════════════════

class SpiritualNotificationService {
  static FlutterLocalNotificationsPlugin? _notifications;
  static const String _prefKey = 'spiritual_notifications_enabled';
  static bool _initialized = false;

  // Notification IDs
  static const int _morningPrayerId = 1001;
  static const int _eveningPrayerId = 1002;
  static const int _dailyVerseId = 1003;

  /// Kiểm tra platform có hỗ trợ notification không
  static bool get _isSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
           defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Khởi tạo hệ thống notification
  static Future<void> init() async {
    if (!_isSupported) return;

    try {
      _notifications = FlutterLocalNotificationsPlugin();

      // Khởi tạo timezone
      tz_data.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

      // Khởi tạo plugin
      const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications!.initialize(settings: settings);
      _initialized = true;

      // Xin quyền notification trên Android 13+
      await _notifications!
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      // Tự động lên lịch nếu đã bật
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool(_prefKey) ?? true; // Mặc định bật
      if (enabled) {
        await scheduleDailyNotifications();
      }
    } catch (e) {
      debugPrint('SpiritualNotificationService init error: $e');
      _initialized = false;
    }
  }

  /// Kiểm tra trạng thái bật/tắt
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? true;
  }

  /// Bật/tắt thông báo
  static Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, enabled);

    if (!_isSupported || !_initialized) return;

    if (enabled) {
      await scheduleDailyNotifications();
    } else {
      await cancelAllNotifications();
    }
  }

  /// Lên lịch 3 thông báo hằng ngày
  static Future<void> scheduleDailyNotifications() async {
    if (!_isSupported || !_initialized || _notifications == null) return;

    try {
      // Cancel cũ trước
      await cancelAllNotifications();

      // 1. Kinh Sáng — 5:00 AM
      await _scheduleDaily(
        id: _morningPrayerId,
        hour: 5,
        minute: 0,
        title: '🙏 Kinh Sáng',
        body: 'Lạy Chúa, con xin dâng ngày hôm nay cho Chúa. Xin Chúa giữ gìn và hướng dẫn con trong mọi việc.',
        channelId: 'morning_prayer',
        channelName: 'Nhắc đọc kinh sáng',
      );

      // 2. Lời Chúa hằng ngày — 7:00 AM
      final verse = BibleVerses.getDailyVerse();
      await _scheduleDaily(
        id: _dailyVerseId,
        hour: 7,
        minute: 0,
        title: '📖 Lời Chúa hôm nay (${verse['verse']})',
        body: verse['text'] ?? '',
        channelId: 'daily_verse',
        channelName: 'Lời Chúa hằng ngày',
      );

      // 3. Kinh Tối — 10:00 PM
      await _scheduleDaily(
        id: _eveningPrayerId,
        hour: 22,
        minute: 0,
        title: '🌙 Kinh Tối',
        body: 'Đã đến giờ đọc kinh tối. Hãy dành vài phút tạ ơn Chúa về ngày hôm nay và phó thác giấc ngủ cho Người.',
        channelId: 'evening_prayer',
        channelName: 'Nhắc đọc kinh tối',
      );
    } catch (e) {
      debugPrint('Schedule notifications error: $e');
    }
  }

  /// Hủy tất cả thông báo
  static Future<void> cancelAllNotifications() async {
    if (!_isSupported || !_initialized || _notifications == null) return;
    try {
      await _notifications!.cancelAll();
    } catch (e) {
      debugPrint('Cancel notifications error: $e');
    }
  }

  /// Lên lịch thông báo lặp lại hằng ngày
  static Future<void> _scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
  }) async {
    if (_notifications == null) return;

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelName,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
      styleInformation: BigTextStyleInformation(body),
      category: AndroidNotificationCategory.reminder,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Tính thời gian scheduled tiếp theo
    final scheduledTime = _nextInstanceOfTime(hour, minute);

    await _notifications!.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledTime,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Lặp lại hằng ngày
    );
  }

  /// Tính thời điểm tiếp theo cho giờ:phút chỉ định
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    // Nếu thời gian đã qua hôm nay → lên lịch cho ngày mai
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
