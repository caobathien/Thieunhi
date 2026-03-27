import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'api_service.dart';
import 'token_service.dart';

class ClassAssignmentService {
  final TokenService _tokenService = TokenService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // 1. Phân công Huynh trưởng vào lớp (POST /) - Chỉ Admin/Leader
  Future<Map<String, dynamic>> createAssignment(String userId, int classId, {String? role, String? academicYear}) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/class-assignments'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'user_id': userId,
          'class_id': classId,
          'assignment_role': role ?? 'Giáo lý viên',
          'academic_year': academicYear ?? '2025-2026', // Default or fetch from config
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }

  // Alias for legacy support if needed
  Future<Map<String, dynamic>> assignLeader(String userId, int classId, String role, String academicYear) async {
    return createAssignment(userId, classId, role: role, academicYear: academicYear);
  }

  // 1b. Cập nhật phân công (PATCH /:id)
  Future<Map<String, dynamic>> updateAssignment(int id, int classId, {String? role, String? academicYear}) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/class-assignments/$id'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'class_id': classId,
          'assignment_role': ?role,
          'academic_year': ?academicYear,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }

  // 2. Xem danh sách Huynh trưởng của lớp (GET /class/:classId)
  Future<Map<String, dynamic>> getLeadersByClass(int classId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/class-assignments/class/$classId'),
        headers: await _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }

  // 3. Gỡ phân công (DELETE /:id) - Chỉ Admin/Leader
  Future<Map<String, dynamic>> deleteAssignment(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/class-assignments/$id'),
        headers: await _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }

  // Alias for legacy support
  Future<Map<String, dynamic>> removeAssignment(int id) async {
    return deleteAssignment(id);
  }

  // 4. Lấy tất cả phân công (GET /)
  Future<Map<String, dynamic>> getAllAssignments({String? academicYear}) async {
    try {
      // Backend should have an endpoint for all assignments, or we might need to filter by year
      final year = academicYear ?? '2025-2026';
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/class-assignments?year=$year'),
        headers: await _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }

  // 4. Xuất danh sách phân công ra Excel (GET /export/excel/:classId)
  Future<String?> exportAssignmentExcel(int classId) async {
    try {
      final token = await _tokenService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/class-assignments/export/excel/$classId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/PhanCong_Lop_$classId.xlsx';
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