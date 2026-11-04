import 'dart:convert';
import 'package:http/http.dart' as http;

class IPTVService {
  final String serverUrl;
  final String username;
  final String password;

  IPTVService({
    required this.serverUrl,
    required this.username,
    required this.password,
  });

  String get baseUrl => serverUrl.endsWith('/') 
      ? '${serverUrl}player_api.php' 
      : '$serverUrl/player_api.php';

  // 1. التحقق من بيانات الاشتراك
  Future<bool> authenticate() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?username=$username&password=$password'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['user_info']['status'] == 'Active';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // 2. جلب القنوات المباشرة
  Future<List<dynamic>> getLiveStreams() async {
    final response = await http.get(
      Uri.parse('$baseUrl?username=$username&password=$password&action=get_live_streams'),
    );
    return json.decode(response.body);
  }

  // 3. جلب الأفلام (VOD) مع البوسترات
  Future<List<dynamic>> getMovies() async {
    final response = await http.get(
      Uri.parse('$baseUrl?username=$username&password=$password&action=get_vod_streams'),
    );
    return json.decode(response.body);
  }

  // 4. جلب المسلسلات
  Future<List<dynamic>> getSeries() async {
    final response = await http.get(
      Uri.parse('$baseUrl?username=$username&password=$password&action=get_series'),
    );
    return json.decode(response.body);
  }

  // رابط تشغيل البث/الفيديو
  String getStreamUrl(int streamId, String extension) {
    String cleanUrl = serverUrl.endsWith('/') ? serverUrl.substring(0, serverUrl.length - 1) : serverUrl;
    return '$cleanUrl/live/$username/$password/$streamId.$extension';
  }
}
