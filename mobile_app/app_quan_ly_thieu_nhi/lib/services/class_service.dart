import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'token_service.dart';

class ClassService {
  final TokenService _tokenService = TokenService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Lấy danh sách tất cả lớp học (Yêu cầu đăng nhập)
  Future<Map<String, dynamic>> getAllClasses() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/classes'),
        headers: await _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi: $e"};
    }
  }

  // Tạo lớp mới (Chỉ Admin/Leader)
  Future<Map<String, dynamic>> createClass(Map<String, dynamic> classData) async {
  try {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/classes'),
      headers: await _getHeaders(),
      // Đảm bảo classData chứa 'class_name', 'room_number', v.v.
      body: jsonEncode(classData),
    );
    return jsonDecode(response.body);
  } catch (e) {
    return {"success": false, "message": "Lỗi: $e"};
  }
}

  // Cập nhật lớp (Chỉ Admin/Leader)
  Future<Map<String, dynamic>> updateClass(int id, Map<String, dynamic> classData) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/classes/$id'),
        headers: await _getHeaders(),
        body: jsonEncode(classData),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi: $e"};
    }
  }
  // 4. Xóa lớp học (DELETE /:id) - Chỉ Admin/Leader
  Future<Map<String, dynamic>> deleteClass(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/classes/$id'),
        headers: await _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }
  // hiển thị danh sách thiếu nhi trong lớp
  Future<Map<String, dynamic>> getchirdrenByClass(int id) async {
  try {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/classes/$id/children'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      return {
        "success": false,
        "message": "Không tìm thấy lớp hoặc không có thiếu nhi"
      };
    } else {
      return {
        "success": false,
        "message": "Lỗi server: ${response.statusCode}"
      };
    }
  } catch (e) {
    return {
      "success": false,
      "message": "Lỗi kết nối: $e"
    };
  }
}
}