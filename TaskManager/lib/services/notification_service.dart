import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

class NotificationService {
  static const String baseUrl = 'http://10.0.2.2:3000/api/notifications';

  Future _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<AppNotification>> getNotifications() async {
    final response = await http.get(Uri.parse(baseUrl), headers: await _getHeaders());
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => AppNotification.fromJson(e)).toList();
    } else {
      throw Exception('Lỗi tải thông báo');
    }
  }

  Future<int> getUnreadCount() async {
    final response = await http.get(Uri.parse('$baseUrl/unread-count'), headers: await _getHeaders());
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['unreadCount'] ?? 0;
    }
    return 0;
  }

  Future<void> markAsRead(String id) async {
    await http.patch(Uri.parse('$baseUrl/$id/read'), headers: await _getHeaders());
  }

  Future<void> markAllAsRead() async {
    await http.patch(Uri.parse('$baseUrl/read-all'), headers: await _getHeaders());
  }
}