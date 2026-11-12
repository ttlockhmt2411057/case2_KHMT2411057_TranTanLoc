import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import 'task_edit_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final TaskService _taskService = TaskService();
  Task? _task;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => _isLoading = true);
    try {
      final task = await _taskService.getTaskDetail(widget.taskId);
      setState(() => _task = task);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTask() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa công việc này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await _taskService.deleteTask(widget.taskId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa công việc')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết công việc'),
        actions: [
          if (_task != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TaskEditScreen(task: _task!)),
                );
                _loadDetail();
              },
            ),
          if (_task != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteTask,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _task == null
          ? const Center(child: Text('Không có dữ liệu'))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(_task!.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Người tạo: ${_task!.createdByName}'),
            const SizedBox(height: 8),
            Text('Bắt đầu: ${_task!.startDate.day}/${_task!.startDate.month}/${_task!.startDate.year}'),
            Text('Hạn hoàn thành: ${_task!.dueDate.day}/${_task!.dueDate.month}/${_task!.dueDate.year}'),
            const SizedBox(height: 8),
            Text('Ưu tiên: ${_task!.priority.toUpperCase()}'),
            const Divider(height: 24),
            const Text('Cập nhật nhanh trạng thái:', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _task!.status,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'todo', child: Text('Chưa thực hiện')),
                DropdownMenuItem(value: 'in_progress', child: Text('Đang thực hiện')),
                DropdownMenuItem(value: 'completed', child: Text('Đã hoàn thành')),
              ],
              onChanged: (newStatus) async {
                if (newStatus == null) return;
                await _taskService.updateStatus(_task!.id, newStatus);
                _loadDetail();
              },
            ),
            const Divider(height: 24),
            const Text('Mô tả:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(_task!.description.isEmpty ? 'Không có mô tả' : _task!.description),
          ],
        ),
      ),
    );
  }
}