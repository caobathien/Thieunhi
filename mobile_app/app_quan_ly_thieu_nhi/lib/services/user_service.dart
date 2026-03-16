import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'token_service.dart';

class UserService {
  final TokenService _tokenService = TokenService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Xem profile cá nhân (/me)
  Future<Map<String, dynamic>> getMyProfile() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/users/me'),
        headers: await _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // Cập nhật profile (/update-me)
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> updateData) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/users/update-me'),
        headers: await _getHeaders(),
        body: jsonEncode(updateData),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // Admin lấy tất cả người dùng (/all)
  Future<Map<String, dynamic>> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/users/all'),
        headers: await _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // Đổi mật khẩu
  Future<Map<String, dynamic>> changePassword(String oldPassword, String newPassword) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/auth/change-password'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }

  // Phân quyền
  Future<Map<String, dynamic>> updateUserRole(String userId, String newRole) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/users/update-role/$userId'),
        headers: await _getHeaders(),
        body: jsonEncode({'role': newRole}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi: $e"};
    }
  }

  // Khóa/Mở khóa tài khoản
  Future<Map<String, dynamic>> toggleUserStatus(String userId, bool isActive) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/users/toggle-status/$userId'),
        headers: await _getHeaders(),
        body: jsonEncode({'is_active': isActive}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi: $e"};
    }
  }

  // Xóa tài khoản
  Future<Map<String, dynamic>> deleteUser(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/users/$userId'),
        headers: await _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi: $e"};
    }
  }

  // Admin cập nhật thông tin bất kỳ
  Future<Map<String, dynamic>> adminUpdateUser(String userId, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/users/admin-update/$userId'),
        headers: await _getHeaders(),
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi: $e"};
    }
  }

  // Cập nhật tài khoản cá nhân (Username, Phone, Gmail)
  Future<Map<String, dynamic>> updateMyAccount(Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/users/update-me'),
        headers: await _getHeaders(),
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi: $e"};
    }
  }

  // Admin thiết lập lại mật khẩu
  Future<Map<String, dynamic>> adminResetPassword(String userId, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/users/admin-reset-password/$userId'),
        headers: await _getHeaders(),
        body: jsonEncode({'newPassword': newPassword}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi: $e"};
    }
  }
}