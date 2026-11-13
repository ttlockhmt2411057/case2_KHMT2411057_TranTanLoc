import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskService {
  static const String baseUrl = 'http://10.0.2.2:3000/api/tasks';

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Task>> getTasks({
    String? scope,
    String? status,
    String? priority,
    String? query,
    String sortBy = 'createdAt',
    String order = 'desc',
  }) async {
    final queryParams = <String, String>{
      'sortBy': sortBy,
      'order': order,
      if (scope != null && scope.isNotEmpty) 'scope': scope,
      if (status != null && status.isNotEmpty) 'status': status,
      if (priority != null && priority.isNotEmpty) 'priority': priority,
      if (query != null && query.isNotEmpty) 'q': query,
    };

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Task.fromJson(e)).toList();
    } else {
      throw Exception('Lỗi tải danh sách công việc');
    }
  }

  Future<Task> getTaskDetail(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'), headers: await _getHeaders());
    if (response.statusCode == 200) {
      return Task.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Không tải được chi tiết công việc');
    }
  }

  Future<void> createTask(Map<String, dynamic> taskData) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: await _getHeaders(),
      body: jsonEncode(taskData),
    );
    if (response.statusCode != 201) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Lỗi tạo công việc');
    }
  }

  Future<void> updateTask(String id, Map<String, dynamic> taskData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: await _getHeaders(),
      body: jsonEncode(taskData),
    );
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Lỗi cập nhật công việc');
    }
  }

  Future<void> updateStatus(String id, String status) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$id/status'),
      headers: await _getHeaders(),
      body: jsonEncode({'status': status}),
    );
    if (response.statusCode != 200) {
      throw Exception('Lỗi đổi trạng thái');
    }
  }

  Future<void> deleteTask(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'), headers: await _getHeaders());
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Lỗi xóa công việc');
    }
  }
}
