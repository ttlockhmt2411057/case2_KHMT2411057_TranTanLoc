class Task {
  final String id;
  final String title;
  final String description;
  final String createdByName;
  final String createdById;
  final DateTime startDate;
  final DateTime dueDate;
  final String priority;
  final String status;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.createdByName,
    required this.createdById,
    required this.startDate,
    required this.dueDate,
    required this.priority,
    required this.status,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    final creator = json['createdBy'];
    return Task(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      createdById: creator is Map ? (creator['_id'] ?? '') : (creator ?? ''),
      createdByName: creator is Map ? (creator['fullName'] ?? 'Không rõ') : 'Tôi',
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      dueDate: DateTime.tryParse(json['dueDate'] ?? '') ?? DateTime.now(),
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'todo',
    );
  }
}