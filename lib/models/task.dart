class Task {
  final int? id;
  final String title;
  final String? description;
  final int? assignedTo; // Foreign key referencing User.id
  final String priority;
  final String deadline;
  final String status;
  final String slaStatus;

  Task({
    this.id,
    required this.title,
    this.description,
    this.assignedTo,
    required this.priority,
    required this.deadline,
    required this.status,
    required this.slaStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'assigned_to': assignedTo,
      'priority': priority,
      'deadline': deadline,
      'status': status,
      'sla_status': slaStatus,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      assignedTo: map['assigned_to'] as int?,
      priority: map['priority'] as String,
      deadline: map['deadline'] as String,
      status: map['status'] as String,
      slaStatus: map['sla_status'] as String,
    );
  }
}
