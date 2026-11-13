class TaskShare {
  final String id;
  final String userId;
  final String fullName;
  final String email;
  final String permission;

  TaskShare({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.permission,
  });

  factory TaskShare.fromJson(Map<String, dynamic> json) {
    final user = json['sharedWithUserId'];
    return TaskShare(
      id: json['_id'] ?? '',
      userId: user is Map ? (user['_id'] ?? '') : '',
      fullName: user is Map ? (user['fullName'] ?? 'Người dùng') : 'Người dùng',
      email: user is Map ? (user['email'] ?? '') : '',
      permission: json['permission'] ?? 'view',
    );
  }
}