import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'token_service.dart';

class LeaderProfileService {
  final TokenService _tokenService = TokenService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Admin tạo leader mới
  Future<Map<String, dynamic>> createLeader(String? phone, String? gmail) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/leaders-profile'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'phone': phone,
          'gmail': gmail,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }

  // Lấy hồ sơ của chính mình
  Future<Map<String, dynamic>> getMyProfile() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/leaders-profile/profile'),
        headers: await _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }

  // Lấy hồ sơ (theo user_id)
  Future<Map<String, dynamic>> getProfile(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/leaders-profile/$userId'),
        headers: await _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }

  // Leader tự cập nhật hồ sơ (Alias for updateMyProfile to support legacy calls)
  Future<Map<String, dynamic>> upsertProfile(Map<String, dynamic> data) async {
    return updateMyProfile(data);
  }

  // Leader tự cập nhật hồ sơ
  Future<Map<String, dynamic>> updateMyProfile(Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/leaders-profile/profile'),
        headers: await _getHeaders(),
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }

  // Admin cập nhật thông tin hành chính
  Future<Map<String, dynamic>> adminUpdateProfile(String userId, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/leaders-profile/admin/$userId'),
        headers: await _getHeaders(),
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }

  Future<Map<String, dynamic>> getAllLeaders() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/leaders-profile'),
        headers: await _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }
}