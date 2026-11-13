import 'package:flutter/material.dart';
import '../../models/task_share.dart';
import '../../services/share_service.dart';

class TaskShareScreen extends StatefulWidget {
  final String taskId;
  final String taskTitle;

  const TaskShareScreen({
    super.key,
    required this.taskId,
    required this.taskTitle,
  });

  @override
  State<TaskShareScreen> createState() => _TaskShareScreenState();
}

class _TaskShareScreenState extends State<TaskShareScreen> {
  final ShareService _shareService = ShareService();
  final TextEditingController _emailController = TextEditingController();

  List<TaskShare> _shares = [];
  String _selectedPermission = 'view';
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadShares();
  }

  Future<void> _loadShares() async {
    setState(() => _isLoading = true);
    try {
      final list = await _shareService.getTaskShares(widget.taskId);
      setState(() => _shares = list);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleShare() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập email người nhận')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _shareService.shareTask(widget.taskId, email, _selectedPermission);
      _emailController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã chia sẻ công việc thành công')),
        );
      }
      _loadShares();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleRemove(String shareId) async {
    try {
      await _shareService.removeShare(widget.taskId, shareId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thu hồi quyền chia sẻ')),
        );
      }
      _loadShares();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giao việc & Chia sẻ')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Công việc: ${widget.taskTitle}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email thành viên',
                hintText: 'Nhập email người cần giao việc...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedPermission,
                    decoration: const InputDecoration(
                      labelText: 'Quyền hạn',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'view', child: Text('Chỉ xem (View)')),
                      DropdownMenuItem(value: 'edit', child: Text('Chỉnh sửa (Edit)')),
                    ],
                    onChanged: (val) => setState(() => _selectedPermission = val!),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _handleShare,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Giao việc'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            const Text(
              'Danh sách thành viên được chia sẻ:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _shares.isEmpty
                  ? const Center(child: Text('Chưa chia sẻ công việc này cho ai'))
                  : ListView.builder(
                itemCount: _shares.length,
                itemBuilder: (context, index) {
                  final item = _shares[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(item.fullName.isNotEmpty ? item.fullName[0].toUpperCase() : '?'),
                      ),
                      title: Text(item.fullName),
                      subtitle: Text(
                        '${item.email}\nQuyền: ${item.permission == 'edit' ? 'Được chỉnh sửa' : 'Chỉ xem'}',
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        tooltip: 'Thu hồi quyền',
                        onPressed: () => _handleRemove(item.id),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}