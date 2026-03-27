import 'package:flutter/material.dart';
import '../../services/attendance_service.dart';
import '../../theme/app_theme.dart';

class AttendanceReportScreen extends StatefulWidget {
  final String classId;
  const AttendanceReportScreen({super.key, required this.classId});

  @override
  State<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  List<dynamic> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    final res = await _attendanceService.getClassReport(int.parse(widget.classId));
    if (res['success']) {
      setState(() {
        _reports = res['data'] ?? [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Báo cáo điểm danh"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _reports.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.assignment_outlined, size: 52, color: AppColors.navInactive),
                      const SizedBox(height: 12),
                      const Text("Chưa có dữ liệu điểm danh", style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reports.length,
                  itemBuilder: (context, index) {
                    final item = _reports[index];
                    final bool isPresent = item['is_present'] == true;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: AppDecorations.cardSubtle,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isPresent ? AppColors.success.withAlpha(20) : AppColors.error.withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isPresent ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            color: isPresent ? AppColors.success : AppColors.error,
                            size: 22,
                          ),
                        ),
                        title: Text(
                          "${item['last_name']} ${item['first_name']}",
                          style: AppTextStyles.titleSmall,
                        ),
                        subtitle: Text("Trạng thái: ${item['status']}", style: AppTextStyles.bodyMedium),
                        trailing: Text(
                          item['check_in_time'] ?? "--:--",
                          style: AppTextStyles.titleSmall.copyWith(color: AppColors.primary),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}