class ClassAssignment {
  final int? id;
  final String userId;
  final int classId;
  final String? leaderName;
  final String? christianName;
  final String? className;
  final String? role;
  final String? academicYear;
  final DateTime? assignedAt;

  ClassAssignment({
    this.id,
    required this.userId,
    required this.classId,
    this.leaderName,
    this.christianName,
    this.className,
    this.role,
    this.academicYear,
    this.assignedAt,
  });

  factory ClassAssignment.fromJson(Map<String, dynamic> json) {
    return ClassAssignment(
      id: json['id'],
      userId: json['user_id'] ?? '',
      classId: json['class_id'] ?? 0,
      leaderName: json['full_name'], // Backend often returns full_name as leader name
      christianName: json['christian_name'],
      className: json['class_name'],
      role: json['assignment_role'],
      academicYear: json['academic_year'],
      assignedAt: json['assigned_at'] != null ? DateTime.parse(json['assigned_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'class_id': classId,
      'assignment_role': role,
      'academic_year': academicYear,
    };
  }
}
