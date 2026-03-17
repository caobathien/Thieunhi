import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiConfig {
  // static const String baseUrl = "http://192.168.1.5:3000/api/v1";
  // static const baseUrl = "http://localhost:3000/api/v1";
  const baseUrl = "https://thieunhi.onrender.com/api/v1";

  static Future<String?> uploadImage(String filePath) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
      request.files.add(await http.MultipartFile.fromPath('image', filePath));
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // data['data']['url'] contains the relative path (e.g. /uploads/filename.jpg)
          // We prepend the baseUrl domain to make it an absolute URL.
          final urlPath = data['data']['url'];
          final domain = baseUrl.replaceAll('/api/v1', '');
          return '$domain$urlPath';
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}