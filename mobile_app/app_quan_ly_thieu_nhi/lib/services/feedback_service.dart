import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'token_service.dart';

class FeedbackService {
  final TokenService _tokenService = TokenService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // 1. Gửi phản hồi mới (Bất kỳ ai đã đăng nhập)
  Future<Map<String, dynamic>> submitFeedback(String title, String content) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/feedbacks'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'title': title,
          'content': content,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }

  // 2. Xem phản hồi của chính mình
  Future<Map<String, dynamic>> getMyFeedbacks() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/feedbacks/my'),
        headers: await _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }

  // 3. Xem tất cả phản hồi (Admin, Leader)
  Future<Map<String, dynamic>> getAllFeedbacks() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/feedbacks/all'),
        headers: await _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }

  // 4. Admin/Leader phản hồi
  Future<Map<String, dynamic>> respondToFeedback({
    required int id,
    required String status,
    required String adminNote,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/feedbacks/respond/$id'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'status': status,
          'admin_note': adminNote,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }
}