import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/statistics_service.dart';
import '../../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final StatisticsService _statsService = StatisticsService();
  Map<String, dynamic>? _stats;
  String _userName = '';
  String _userEmail = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final stats = await _statsService.getOverview();
      setState(() {
        _userName = prefs.getString('fullName') ?? 'Người dùng';
        _userEmail = prefs.getString('email') ?? '';
        _stats = Map<String, dynamic>.from(stats);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MyApp()),
          (route) => false,
    );
  }

  Widget _buildStatCard(String label, int count, Color color, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              '$count',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cá nhân & Thống kê'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: 'Đăng xuất',
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  radius: 26,
                  child: Text(
                    _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  _userName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Text(_userEmail),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Thống kê tiến độ công việc',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (_stats != null)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.35,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildStatCard('Tổng công việc', (_stats!['total'] ?? 0) as int, Colors.blue, Icons.list_alt),
                  _buildStatCard('Hoàn thành', (_stats!['completed'] ?? 0) as int, Colors.green, Icons.check_circle_outline),
                  _buildStatCard('Đang thực hiện', (_stats!['inProgress'] ?? 0) as int, Colors.orange, Icons.timelapse),
                  _buildStatCard('Chưa thực hiện', (_stats!['todo'] ?? 0) as int, Colors.grey, Icons.pending_actions),
                  _buildStatCard('Sắp đến hạn (48h)', (_stats!['dueSoon'] ?? 0) as int, Colors.amber.shade800, Icons.warning_amber),
                  _buildStatCard('Đã quá hạn', (_stats!['overdue'] ?? 0) as int, Colors.red, Icons.error_outline),
                ],
              ),
          ],
        ),
      ),
    );
  }
}