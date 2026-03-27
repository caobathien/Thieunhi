import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'token_service.dart';

class TermSummaryService {
  final TokenService _tokenService = TokenService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> processSummary(int classId, String term) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/term-summaries/process'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'class_id': classId,
          'term': term,
          'academic_year': "2025-2026",
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }

  // 2. Xem kết quả tổng kết của 1 em (GET /child/:childId)
  Future<Map<String, dynamic>> getStudentSummary(String childId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/term-summaries/child/$childId'),
        headers: await _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }

  // 3. MỚI: Xem tổng kết của toàn bộ lớp (GET /class/:classId)
  Future<Map<String, dynamic>> getClassSummary(int classId, {String? year}) async {
    try {
      // 1. Thêm 's' vào term-summaries và gán year mặc định nếu không có
      final String academicYear = year ?? "2025-2026";
      
      // 2. Xây dựng URL chuẩn xác khớp với ví dụ hoạt động của các module khác
      final String url = '${ApiConfig.baseUrl}/term-summaries/class/$classId?year=$academicYear';

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );
      
      // Kiểm tra phản hồi 404 để thông báo chính xác
      if (response.statusCode == 404) {
        return {
          "success": false, 
          "message": "Lỗi 404: Vui lòng kiểm tra lại Route trên Backend (số ít/số nhiều)"
        };
      }
      
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }
}