import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'token_service.dart';

class ApiConfig {
  // static const String baseUrl = "http://192.168.1.5:3000/api/v1";
  // static const baseUrl = "http://localhost:3000/api/v1";
  static const String baseUrl = "https://thieunhi.onrender.com/api/v1";

  static Future<String?> uploadImage(XFile imageFile) async {
    try {
      final token = await TokenService().getToken();
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
      
      // Add Authorization header
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      // Use fromBytes to support Web (dart:io is not available on Web)
      final bytes = await imageFile.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'image', 
        bytes,
        filename: imageFile.name,
      ));
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final urlPath = data['data']['url'];
          final domain = baseUrl.replaceAll('/api/v1', '');
          return '$domain$urlPath';
        }
      }
      print('Upload Response Status: ${response.statusCode}');
      print('Upload Response Body: ${response.body}');
      return null;
    } catch (e) {
      print('Upload Error: $e');
      return null;
    }
  }
}