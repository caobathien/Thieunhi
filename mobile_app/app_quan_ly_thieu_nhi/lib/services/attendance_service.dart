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
}