import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/class_statistic_service.dart';
import '../../theme/app_theme.dart';

class ClassStatisticsDetailScreen extends StatefulWidget {
  final int classId;
  final String className;

  const ClassStatisticsDetailScreen({super.key, required this.classId, required this.className});

  @override
  State<ClassStatisticsDetailScreen> createState() => _ClassStatisticsDetailScreenState();
}

class _ClassStatisticsDetailScreenState extends State<ClassStatisticsDetailScreen> {
  final ClassStatisticService _statService = ClassStatisticService();
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final result = await _statService.getClassStats(widget.classId);
    if (result['success'] == true) {
      setState(() {
        _stats = result['data'];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Thống kê ${widget.className}"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSummaryGrid(),
                  const SizedBox(height: 20),
                  _buildAttendanceChart(),
                  const SizedBox(height: 20),
                  _buildExportButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildAttendanceChart() {
    List<double> chartData = [85, 90, 75, 95, 88, 92];

    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Xu hướng chuyên cần (6 tuần gần nhất)",
            style: AppTextStyles.titleSmall),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, _) => Text("T${val.toInt() + 1}", style: AppTextStyles.caption),
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 4,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withAlpha(25),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _statCard("Tổng buổi", _stats?['total_sessions']?.toString() ?? "0", Icons.event, AppColors.primary),
        _statCard("Hiện diện", "${_stats?['attendance_rate'] ?? 0}%", Icons.check_circle, AppColors.success),
        _statCard("Nghỉ trung bình", _stats?['avg_absent']?.toString() ?? "0", Icons.cancel, AppColors.error),
        _statCard("Khen thưởng", _stats?['reward_count']?.toString() ?? "0", Icons.emoji_events, AppColors.warning),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: AppDecorations.cardSubtle,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(title, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          elevation: 0,
        ),
        icon: const Icon(Icons.description),
        label: const Text("XUẤT FILE EXCEL THỐNG KÊ", style: TextStyle(fontWeight: FontWeight.w700)),
        onPressed: () async {
          final path = await _statService.exportExcel(widget.classId);
          if (path != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Đã lưu tại: $path"),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }
}