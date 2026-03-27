import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'token_service.dart';

class AttendanceService {
  final TokenService _tokenService = TokenService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Gửi mã QR đã quét về Server
  Future<Map<String, dynamic>> scanQR(String qrData) async {
  try {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/attendance/scan'),
      headers: await _getHeaders(),
      // Gửi qrData, Server sẽ tìm UUID child_id tương ứng
      body: jsonEncode({
        'qr_data': qrData,
        'attendance_date': DateTime.now().toIso8601String().split('T')[0],
      }),
    );
    return jsonDecode(response.body);
  } catch (e) {
    return {"success": false, "message": "Lỗi kết nối: $e"};
  }

  // Lấy danh sách thiếu nhi có nguy cơ (nghỉ >= 3 buổi)
  Future<List<Map<String, dynamic>>> getAtRiskStudents(int classId) async {
    try {
      // Xác định khoảng thời gian niên khóa hiện tại (Từ tháng 8 năm trước dến nay)
      final now = DateTime.now();
      final year = now.month >= 8 ? now.year : now.year - 1;
      final startDate = "$year-08-01";
      final endDate = now.toIso8601String().split('T')[0];

      final statsResponse = await getAttendanceStats(classId, startDate, endDate);
      if (statsResponse['success'] == true) {
        final List data = statsResponse['data'] ?? [];
        
        // Nhóm theo child_id và đếm số buổi vắng
        Map<String, Map<String, dynamic>> atRiskMap = {};
        
        for (var record in data) {
          final childId = record['child_id'].toString();
          final isPresent = record['is_present'] == true;
          
          if (!isPresent) {
            if (!atRiskMap.containsKey(childId)) {
              atRiskMap[childId] = {
                'child_id': childId,
                'full_name': "${record['last_name']} ${record['first_name']}",
                'baptismal_name': record['baptismal_name'] ?? '',
                'absence_count': 0,
                'last_absence': record['attendance_date'],
              };
            }
            atRiskMap[childId]!['absence_count']++;
            // Cập nhật ngày vắng gần nhất
            if (record['attendance_date'].compareTo(atRiskMap[childId]!['last_absence']) > 0) {
              atRiskMap[childId]!['last_absence'] = record['attendance_date'];
            }
          }
        }
        
        // Lọc những em vắng >= 3 buổi
        return atRiskMap.values
            .where((student) => student['absence_count'] >= 3)
            .toList()
          ..sort((a, b) => b['absence_count'].compareTo(a['absence_count']));
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> manualMark({
    required String childId,
    required int classId,
    required bool isPresent,
    required String status,
    String? reason,
    String? attendanceDate,
    String? lessonTopic,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/attendance/manual'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'child_id': childId,
          'class_id': classId,
          'is_present': isPresent,
          'status': status,
          'reason': reason ?? "",
          'attendance_date': attendanceDate ?? DateTime.now().toIso8601String().split('T')[0],
          'lesson_topic': lessonTopic ?? "",
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }

  // Chức năng 1: Lấy báo cáo ngày hiện tại
  Future<Map<String, dynamic>> getClassReport(int classId, {String? date}) async {
    try {
      // Xây dựng URL với Query Parameter nếu có date
      String url = '${ApiConfig.baseUrl}/attendance/class/$classId';
      if (date != null && date.isNotEmpty) {
        url += '?date=$date';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }

  // Chức năng 2: Lấy báo cáo theo ngày tùy chọn
  Future<List<dynamic>> getReportByDate(int classId, String date) async {
    try {
      // Tùy vào route bạn đặt ở express, ví dụ dùng query param: ?date=...
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/attendance/class/$classId?date=$date'),
        headers: await _getHeaders(),
      );
      
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return data['data']; // Giả sử backend dùng hàm sendSuccess
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  //điểm danh bằng tay 
  Future<Map<String, dynamic>> getManualList(int classId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/attendance/manual-list/$classId'),
        headers: await _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }

  // Thống kê điểm danh theo khoảng thời gian
  Future<Map<String, dynamic>> getAttendanceStats(int classId, String startDate, String endDate) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/attendance/stats/$classId?startDate=$startDate&endDate=$endDate'),
        headers: await _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }

  Future<Map<String, dynamic>> updateLessonTopic({
    required int classId,
    required String date,
    required String topic,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/attendance/lesson-topic'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'class_id': classId,
          'date': date,
          'lesson_topic': topic,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }
}