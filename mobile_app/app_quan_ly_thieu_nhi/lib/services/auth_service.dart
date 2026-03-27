import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'token_service.dart';

class AuthService {
  final TokenService _tokenService = TokenService();

  Future<Map<String, dynamic>> login(String username, String password) async {
  try {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // 1. Tìm token trong mọi trường hợp (data['token'] hoặc data['data']['token'])
      String? token;
      if (data['token'] != null) {
        token = data['token'].toString();
      } else if (data['data'] != null && data['data']['token'] != null) {
        token = data['data']['token'].toString();
      }

      // 2. Chỉ lưu nếu token thực sự tồn tại
      if (token != null && token.isNotEmpty) {
        // Đảm bảo loại bỏ dấu ngoặc kép nếu Backend trả về chuỗi dư thừa
        final cleanToken = token.replaceAll('"', '');
        await _tokenService.saveToken(cleanToken);

        // 3. Lưu Role người dùng
        String? role;
        if (data['user'] != null && data['user']['role'] != null) {
          role = data['user']['role'].toString();
        } else if (data['data'] != null && data['data']['user'] != null && data['data']['user']['role'] != null) {
          role = data['data']['user']['role'].toString();
        }

        if (role != null) {
          await _tokenService.saveUserRole(role.toLowerCase());
        }
      }
    }
    
    return data;
  } catch (e) {
    return {"success": false, "message": "Lỗi kết nối máy chủ: $e"};
  }
}
  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String fullName,
    required String gmail,
    String? phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/register'), //
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'full_name': fullName,
          'gmail': gmail,
          'phone': phone,
        }),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }

  Future<Map<String, dynamic>> changePassword(String oldPassword, String newPassword) async {
    try {
      final token = await _tokenService.getToken();
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/auth/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
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
}