import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'api_service.dart';
import 'token_service.dart';

class ChildService {
  final TokenService _tokenService = TokenService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Lấy danh sách tất cả thiếu nhi (Admin/Leader)
  Future<Map<String, dynamic>> getAllChildren() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/children'),
        headers: await _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi: $e"};
    }
  }

  // Thêm mới thiếu nhi (Admin/Leader)
  Future<Map<String, dynamic>> createChild(Map<String, dynamic> childData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/children'),
        headers: await _getHeaders(),
        body: jsonEncode(childData),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi: $e"};
    }
  }

  // Lấy thiếu nhi theo lớp (Admin/Leader/Teacher)
  Future<Map<String, dynamic>> getChildrenByClass(String classId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/children/class/$classId'),
        headers: await _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi: $e"};
    }
  }

  // Xóa thiếu nhi (Admin/Leader)
  Future<Map<String, dynamic>> deleteChild(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/children/$id'),
        headers: await _getHeaders(),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Lỗi: $e"};
    }
  }
  // chỉnh sửa thiếu nhi
  Future<Map<String, dynamic>> updateChild(String id, Map<String, dynamic> childData) async {
  try {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/children/$id'),
      headers: await _getHeaders(),
      body: jsonEncode(childData),
    );
    return jsonDecode(response.body);
  } catch (e) {
    return {"success": false, "message": "Lỗi cập nhật: $e"};
  }
}

  // Xuất Excel danh sách học sinh theo lớp
  Future<void> exportChildren(String classId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/children/export/class/$classId'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/DanhSachLop_$classId.xlsx');
        await file.writeAsBytes(response.bodyBytes);
        await OpenFilex.open(file.path);
      }
    } catch (e) {
      // Ignored
    }
  }

  // Nhập Excel danh sách học sinh
  Future<Map<String, dynamic>> importChildren(String classId, File file) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/children/import/$classId'),
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