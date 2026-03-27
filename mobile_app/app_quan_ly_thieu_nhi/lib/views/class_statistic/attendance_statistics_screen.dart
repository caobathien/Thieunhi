import 'package:flutter/material.dart';
import '../../services/class_service.dart';
import '../../services/class_statistic_service.dart';
import '../../theme/app_theme.dart';
import 'class_statistics_detail_screen.dart';

class AttendanceStatisticsScreen extends StatefulWidget {
  const AttendanceStatisticsScreen({super.key});

  @override
  State<AttendanceStatisticsScreen> createState() => _AttendanceStatisticsScreenState();
}

class _AttendanceStatisticsScreenState extends State<AttendanceStatisticsScreen> {
  final ClassService _classService = ClassService();
  final ClassStatisticService _statService = ClassStatisticService();

  List<dynamic> _classes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final result = await _classService.getAllClasses();
    if (result['success'] == true) {
      setState(() => _classes = result['data'] ?? []);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _syncData() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Đang đồng bộ dữ liệu thống kê..."),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    final result = await _statService.syncStats();
    if (result['success'] == true) {
      _fetchData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.success,
            content: const Text("Đồng bộ thành công!"),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Thống kê Điểm danh"),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.titleMedium,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded, color: AppColors.primary),
            onPressed: _syncData,
            tooltip: "Đồng bộ thống kê",
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _fetchData,
              color: AppColors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _classes.length,
                itemBuilder: (context, index) {
                  final item = _classes[index];
                  return _buildClassStatCard(item);
                },
              ),
            ),
    );
  }

  Widget _buildClassStatCard(dynamic classItem) {
    // BUG FIX: Sử dụng 'class_name' thay vì 'name'
    final className = classItem['class_name'] ?? 'Lớp không tên';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: AppDecorations.cardSubtle,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ClassStatisticsDetailScreen(
              classId: classItem['id'],
              className: className,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.analytics_outlined, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(className, style: AppTextStyles.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                      "Sĩ số: ${classItem['student_count'] ?? 0} thiếu nhi",
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.navInactive),
            ],
          ),
        ),
      ),
    );
  }
}