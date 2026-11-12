import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import 'task_create_screen.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TaskService _taskService = TaskService();
  final TextEditingController _searchController = TextEditingController();

  List<Task> _tasks = [];
  bool _isLoading = true;
  String _selectedScope = '';
  String _selectedStatus = '';
  String _selectedPriority = '';
  String _sortBy = 'createdAt';

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    setState(() => _isLoading = true);
    try {
      final tasks = await _taskService.getTasks(
        scope: _selectedScope,
        status: _selectedStatus,
        priority: _selectedPriority,
        query: _searchController.text.trim(),
        sortBy: _sortBy,
      );
      setState(() => _tasks = tasks);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'in_progress':
        return 'Đang làm';
      case 'completed':
        return 'Hoàn thành';
      default:
        return 'Chưa làm';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý công việc'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sắp xếp',
            onSelected: (val) {
              setState(() => _sortBy = val);
              _fetchTasks();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'createdAt', child: Text('Sắp xếp: Mới nhất')),
              PopupMenuItem(value: 'dueDate', child: Text('Sắp xếp: Hạn hoàn thành')),
              PopupMenuItem(value: 'priority', child: Text('Sắp xếp: Mức độ ưu tiên')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên công việc...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _fetchTasks();
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onSubmitted: (_) => _fetchTasks(),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: _selectedScope,
                  items: const [
                    DropdownMenuItem(value: '', child: Text('Tất cả việc')),
                    DropdownMenuItem(value: 'created', child: Text('Tôi tạo')),
                    DropdownMenuItem(value: 'assigned', child: Text('Được giao')),
                  ],
                  onChanged: (v) {
                    setState(() => _selectedScope = v!);
                    _fetchTasks();
                  },
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedStatus,
                  items: const [
                    DropdownMenuItem(value: '', child: Text('Mọi trạng thái')),
                    DropdownMenuItem(value: 'todo', child: Text('Chưa thực hiện')),
                    DropdownMenuItem(value: 'in_progress', child: Text('Đang thực hiện')),
                    DropdownMenuItem(value: 'completed', child: Text('Đã hoàn thành')),
                  ],
                  onChanged: (v) {
                    setState(() => _selectedStatus = v!);
                    _fetchTasks();
                  },
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedPriority,
                  items: const [
                    DropdownMenuItem(value: '', child: Text('Mọi ưu tiên')),
                    DropdownMenuItem(value: 'low', child: Text('Thấp')),
                    DropdownMenuItem(value: 'medium', child: Text('Trung bình')),
                    DropdownMenuItem(value: 'high', child: Text('Cao')),
                  ],
                  onChanged: (v) {
                    setState(() => _selectedPriority = v!);
                    _fetchTasks();
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tasks.isEmpty
                ? const Center(child: Text('Chưa có công việc nào'))
                : RefreshIndicator(
              onRefresh: _fetchTasks,
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        'Hạn: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year} • ${_statusLabel(task.status)}',
                      ),
                      trailing: Chip(
                        label: Text(
                          task.priority.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                        ),
                        backgroundColor: _priorityColor(task.priority),
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TaskDetailScreen(taskId: task.id),
                          ),
                        );
                        _fetchTasks();
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TaskCreateScreen()),
          );
          _fetchTasks();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}