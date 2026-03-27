import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/attendance_service.dart';
import '../../services/class_service.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationScreen extends StatefulWidget {
  final Map<String, dynamic>? userProfile;
  final String? userRole;

  const NotificationScreen({super.key, this.userProfile, this.userRole});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  final ClassService _classService = ClassService();
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _atRiskStudents = [];
  String? _assignedClassId;
  String? _assignedClassName;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    _assignedClassId = widget.userProfile?['assigned_class_id']?.toString();
    String? role = widget.userRole?.toLowerCase();
    
    if (_assignedClassId != null) {
      _assignedClassName = "Lớp phụ trách"; 
      final result = await _attendanceService.getAtRiskStudents(int.parse(_assignedClassId!));
      setState(() {
        _atRiskStudents = result;
        _isLoading = false;
      });
    } else if (role == 'admin' || role == 'leader-vip') {
      // Admin/VIP without assigned class: List ALL for now or show choosing UI
      // For now, let's fetch summary of all classes (conceptual)
      // or just show empty but with a message
      _assignedClassName = "Tất cả các lớp (Admin)";
      // To implement correctly, we'd need a multi-class fetcher
      // For this fix, let's just avoid the "pick first class" trap
      setState(() {
        _atRiskStudents = []; 
        _isLoading = false;
      });
    } else {
      setState(() {
        _atRiskStudents = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Navy Gradient AppBar ──
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text("Thông báo", style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontSize: 18)),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F2440), Color(0xFF1E3A5F), Color(0xFF2E5A8F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
            )
          else if (_atRiskStudents.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _assignedClassId == null ? Icons.info_outline_rounded : Icons.notifications_off_outlined,
                          size: 56,
                          color: AppColors.primary.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _assignedClassId == null ? "Chưa chọn lớp" : "Không có thông báo mới",
                        style: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _assignedClassId == null
                            ? "Vui lòng kiểm tra lại thông tin phân công của bạn để xem danh sách vắng."
                            : "Hiện tại không có thiếu nhi nào vắng quá 3 buổi trong lớp của bạn.",
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.accentLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.warning_amber_rounded, color: AppColors.accent, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Cảnh báo vắng học (${_atRiskStudents.length})",
                              style: AppTextStyles.sectionHeader.copyWith(color: AppColors.textSecondary, fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    }
                    return _buildNotificationCard(_atRiskStudents[index - 1]);
                  },
                  childCount: _atRiskStudents.length + 1,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: AppDecorations.card,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Icon Container ──
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accentLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.person_off_rounded, color: AppColors.accent, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "${student['baptismal_name']} ${student['full_name']}",
                              style: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimary, fontSize: 15),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppRadius.full),
                            ),
                            child: Text(
                              "Vắng ${student['absence_count']}",
                              style: AppTextStyles.caption.copyWith(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Em đã nghỉ học quá 3 buổi trong niên khóa này. Cần liên hệ gia đình để trao đổi.",
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.5),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textLight),
                          const SizedBox(width: 4),
                          Text(
                            "Vắng gần nhất: ${student['last_absence']}",
                            style: AppTextStyles.caption.copyWith(color: AppColors.textLight),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () => _launchPhone(),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Liên hệ",
                                style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchPhone() async {
    final Uri uri = Uri.parse('tel:');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
