class LeaderProfile {
  final int? id;
  final String userId;
  final String christianName;
  final String? fullName;
  final String? phone;
  final String? gmail;
  final DateTime? dob;
  final String rank;
  final String position;
  final DateTime? joinDate;
  final String status;
  final String? avatarUrl;
  final String? awardNotes;
  final String? notes;
  final String? username;
  final String? accountFullName;
  final String? accountPhone;
  final String? accountGmail;
  final String? accountRole;

  LeaderProfile({
    this.id,
    required this.userId,
    required this.christianName,
    this.fullName,
    this.phone,
    this.gmail,
    this.dob,
    required this.rank,
    required this.position,
    this.joinDate,
    required this.status,
    this.avatarUrl,
    this.awardNotes,
    this.notes,
    this.username,
    this.accountFullName,
    this.accountPhone,
    this.accountGmail,
    this.accountRole,
  });

  factory LeaderProfile.fromJson(Map<String, dynamic> json) {
    return LeaderProfile(
      id: json['id'],
      userId: json['user_id'],
      christianName: json['christian_name'] ?? '',
      fullName: json['full_name'],
      phone: json['phone'],
      gmail: json['gmail'],
      dob: json['dob'] != null ? DateTime.parse(json['dob']) : null,
      rank: json['rank'] ?? 'Dự trưởng',
      position: json['position'] ?? 'Giáo lý viên',
      joinDate: json['join_date'] != null ? DateTime.parse(json['join_date']) : null,
      status: json['status'] ?? 'Đang công tác',
      avatarUrl: json['avatar_url'],
      awardNotes: json['award_notes'],
      notes: json['notes'],
      username: json['username'],
      accountFullName: json['account_full_name'],
      accountPhone: json['account_phone'],
      accountGmail: json['account_gmail'],
      accountRole: json['account_role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'christian_name': christianName,
      'full_name': fullName,
      'phone': phone,
      'gmail': gmail,
      if (dob != null) 'dob': dob!.toIso8601String().substring(0, 10),
      'rank': rank,
      'position': position,
      if (joinDate != null) 'join_date': joinDate!.toIso8601String().substring(0, 10),
      'status': status,
      'avatar_url': avatarUrl,
      'award_notes': awardNotes,
      'notes': notes,
      'username': username,
      'account_full_name': accountFullName,
      'account_phone': accountPhone,
      'account_gmail': accountGmail,
      'account_role': accountRole,
    };
  }
}
