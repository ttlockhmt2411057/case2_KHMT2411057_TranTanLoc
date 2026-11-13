import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StatisticsService {
  static const String baseUrl = 'http://10.0.2.2:3000/api/statistics';

  Future _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future getOverview() async {
    final response = await http.get(
      Uri.parse('$baseUrl/overview'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Không tải được số liệu thống kê');
    }
  }
}