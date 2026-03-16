import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'api_service.dart';
import 'token_service.dart';

class GradeService {
  final TokenService _tokenService = TokenService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // 2. Xem điểm của một thiếu nhi
  Future<Map<String, dynamic>> getStudentGrades(String childId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/grades/child/$childId'),
        headers: await _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }
  // Xem điểm tất cả thiếu nhi trong lớp
  Future<Map<String, dynamic>> getClassGrades(int classId) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/grades/class/$classId');

      final response = await http.get(
        url,
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 404) {
        return {"success": false, "message": "Không tìm thấy API: Kiểm tra lại route /grades/class/ trên BE"};
      }

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }
  // grade_service.dart

// Nhập điểm mới
Future<Map<String, dynamic>> inputGrade(Map<String, dynamic> gradeData) async {
  try {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/grades'),
      headers: await _getHeaders(),
      body: jsonEncode(gradeData),
    );
    return jsonDecode(response.body);
  } catch (e) {
    return {"success": false, "message": "Lỗi: $e"};
  }
}

// Cập nhật điểm đã có
Future<Map<String, dynamic>> updateGrade(String id, Map<String, dynamic> gradeData) async {
  try {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/grades/$id'),
      headers: await _getHeaders(),
      body: jsonEncode(gradeData),
    );
    return jsonDecode(response.body);
  } catch (e) {
    return {"success": false, "message": "Lỗi: $e"};
  }
}

  // Xuất Excel bảng điểm lớp
  Future<void> exportGrades(int classId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/grades/export/$classId'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/BangDiemLop_$classId.xlsx');
        await file.writeAsBytes(response.bodyBytes);
        await OpenFile.open(file.path);
      }
    } catch (e) {
      // Ignored
    }
  }

  // Nhập Excel bảng điểm
  Future<Map<String, dynamic>> importGrades(int classId, File file) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/grades/import/$classId'),
      );
      request.headers.addAll(await _getHeaders());
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      return jsonDecode(responseData);
    } catch (e) {
      return {"success": false, "message": "Lỗi nhập Excel: $e"};
    }
  }
}