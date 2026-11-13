import 'package:flutter/material.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';
import '../tasks/task_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService();
  List<AppNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final list = await _notificationService.getNotifications();
      setState(() => _notifications = list);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onTapNotification(AppNotification item) async {
    if (!item.isRead) {
      await _notificationService.markAsRead(item.id);
    }
    if (!mounted) return;
    if (item.taskId.isNotEmpty) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: item.taskId)),
      );
    }
    _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          TextButton(
            onPressed: () async {
              await _notificationService.markAllAsRead();
              _loadNotifications();
            },
            child: const Text('Đọc tất cả'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? const Center(child: Text('Chưa có thông báo nào'))
          : RefreshIndicator(
        onRefresh: _loadNotifications,
        child: ListView.builder(
          itemCount: _notifications.length,
          itemBuilder: (context, index) {
            final item = _notifications[index];
            return Container(
              color: item.isRead ? null : Colors.blue.withOpacity(0.08),
              child: ListTile(
                leading: Icon(
                  item.isRead ? Icons.notifications_none : Icons.notifications_active,
                  color: item.isRead ? Colors.grey : Colors.blue,
                ),
                title: Text(
                  item.title,
                  style: TextStyle(
                    fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${item.message}\n${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year} ${item.createdAt.hour}:${item.createdAt.minute.toString().padLeft(2, '0')}',
                ),
                isThreeLine: true,
                onTap: () => _onTapNotification(item),
              ),
            );
          },
        ),
      ),
    );
  }
}