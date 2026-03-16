import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'api_service.dart';
import 'token_service.dart';

class ClassStatisticService {
  final TokenService _tokenService = TokenService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // 1. Chạy đồng bộ thống kê (POST /sync) - Chỉ Admin/Leader
  Future<Map<String, dynamic>> syncStats() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/class-statistics/sync'),
        headers: await _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }

  // 2. Xem thống kê của 1 lớp (GET /:classId)
  Future<Map<String, dynamic>> getClassStats(int classId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/class-statistics/$classId'),
        headers: await _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }

  // 3. Xuất file Excel (GET /export/:classId) - Trả về file tải về
  Future<String?> exportExcel(int classId) async {
    try {
      final token = await _tokenService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/class-statistics/export/$classId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        // Lưu file vào bộ nhớ máy
        final directory = await getExternalStorageDirectory();
        final filePath = '${directory!.path}/ThongKe_Lop_$classId.xlsx';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}