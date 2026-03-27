import 'package:flutter/material.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final IconData icon;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.icon = Icons.campaign_rounded,
  });
}

class NotificationController extends ChangeNotifier {
  final List<AppNotification> _notifications = [];
  AppNotification? _latestNotification;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  AppNotification? get latestNotification => _latestNotification;

  void broadcast(String title, String message, {IconData icon = Icons.campaign_rounded}) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
      icon: icon,
    );
    
    _notifications.insert(0, notification);
    _latestNotification = notification;
    
    notifyListeners();
    
    // Clear the "latest" flag after a delay so the UI can dismiss the overlay
    Future.delayed(const Duration(seconds: 5), () {
      if (_latestNotification == notification) {
        _latestNotification = null;
        notifyListeners();
      }
    });
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}
