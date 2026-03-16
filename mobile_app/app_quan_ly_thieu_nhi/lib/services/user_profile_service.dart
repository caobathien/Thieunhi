import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'token_service.dart';

class UserProfileService {
  final TokenService _tokenService = TokenService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Lấy hồ sơ của chính mình (cho vai trò USER)
  Future<Map<String, dynamic>> getMyProfile() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/users/me'),
        headers: await _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }

  // Lấy hồ sơ theo ID người dùng (nếu cần cho Admin)
  Future<Map<String, dynamic>> getProfile(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/user-profiles/$userId'),
        headers: await _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }

  // Vai trò USER tự cập nhật hồ sơ
  Future<Map<String, dynamic>> updateMyProfile(Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/users/update-me'),
        headers: await _getHeaders(),
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }
}
