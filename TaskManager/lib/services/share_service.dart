import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_share.dart';

class ShareService {
  static const String baseUrl = 'http://10.0.2.2:3000/api/shares';

  Future _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<TaskShare>> getTaskShares(String taskId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$taskId'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => TaskShare.fromJson(e)).toList();
    } else {
      throw Exception('Không tải được danh sách chia sẻ');
    }
  }

  Future<void> shareTask(String taskId, String email, String permission) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$taskId'),
      headers: await _getHeaders(),
      body: jsonEncode({'email': email, 'permission': permission}),
    );
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Lỗi chia sẻ công việc');
    }
  }

  Future<void> removeShare(String taskId, String shareId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$taskId/$shareId'),
      headers: await _getHeaders(),
    );
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Lỗi thu hồi quyền');
    }
  }
}