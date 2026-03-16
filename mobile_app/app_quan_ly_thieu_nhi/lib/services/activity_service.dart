import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'token_service.dart';

class ActivityService {
  final TokenService _tokenService = TokenService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // 1. Xem danh sách thông báo (Công khai - Không cần Token)
  Future<Map<String, dynamic>> getActivities() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/activities'),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }

  // 2. Đăng tin mới (Chỉ Admin/Leader)
  Future<Map<String, dynamic>> createActivity(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/activities'),
        headers: await _getHeaders(),
        body: jsonEncode(data), // Data bao gồm title, summary, content, v.v.
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }

  // Cập nhật tin (MỚI)
  Future<Map<String, dynamic>> updateActivity(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/activities/$id'),
        headers: await _getHeaders(),
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }

  // Xóa tin (Cần Token để kiểm tra quyền Admin/Leader)
  Future<Map<String, dynamic>> deleteActivity(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/activities/$id'),
        headers: await _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }
}