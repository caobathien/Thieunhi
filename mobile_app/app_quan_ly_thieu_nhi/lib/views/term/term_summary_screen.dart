import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/term_summary_service.dart';
import '../../services/class_service.dart';
import '../../services/token_service.dart';
import '../../theme/app_theme.dart';

class TermSummaryScreen extends StatefulWidget {
  const TermSummaryScreen({super.key});

  @override
  State<TermSummaryScreen> createState() => _TermSummaryScreenState();
}

class _TermSummaryScreenState extends State<TermSummaryScreen> {
  final TermSummaryService _summaryService = TermSummaryService();
  final ClassService _classService = ClassService();
  final TokenService _tokenService = TokenService();

  List<dynamic> _classes = [];
  List<dynamic> _summaries = [];
  String? _selectedClassId;
  String _selectedTerm = "HK1";
  String _searchQuery = "";
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _userRole;

  final List<Map<String, String>> _termOptions = [
    {"value": "HK1", "label": "Học kỳ 1"},
    {"value": "HK2", "label": "Học kỳ 2"},
    {"value": "CaNam", "label": "Cả năm"},
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    _userRole = await _tokenService.getUserRole();
    final classesRes = await _classService.getAllClasses();
    if (classesRes['success'] == true) {
      _classes = classesRes['data'] ?? [];
      if (_classes.isNotEmpty) {
        _selectedClassId = _classes[0]['id'].toString();
        await _fetchSummary();
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _fetchSummary() async {
    if (_selectedClassId == null) return;
    setState(() => _isLoading = true);
    final res = await _summaryService.getClassSummary(int.parse(_selectedClassId!));
    if (res['success'] == true) {
      setState(() => _summaries = res['data'] ?? []);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _handleProcess() async {
    if (_selectedClassId == null) return;
    setState(() => _isProcessing = true);

    final res = await _summaryService.processSummary(
      int.parse(_selectedClassId!),
      _selectedTerm,
    );

    setState(() => _isProcessing = false);

    if (mounted) {
      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tổng kết thành công!")),
        );
        _fetchSummary();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? "Lỗi tổng kết"), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _exportExcel() async {
    if (_summaries.isEmpty) return;

    var excel = Excel.createExcel();
    Sheet sheet = excel['TongKet'];
    excel.delete('Sheet1');

    sheet.appendRow([
      TextCellValue('Hạng'),
      TextCellValue('Họ và Tên'),
      TextCellValue('GPA'),
      TextCellValue('Hạnh kiểm'),
      TextCellValue('Vắng'),
      TextCellValue('Kết quả'),
    ]);

    for (var item in _summaries) {
      sheet.appendRow([
        IntCellValue(item['rank_in_class'] ?? 0),
        TextCellValue(item['full_name'] ?? ''),
        DoubleCellValue(double.tryParse(item['avg_score'].toString()) ?? 0.0),
        TextCellValue(item['conduct_grade'] ?? ''),
        IntCellValue(item['absence_count'] ?? 0),
        TextCellValue(item['final_result'] ?? ''),
      ]);
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/TongKet_Lop_${_selectedClassId}_$_selectedTerm.xlsx")
      ..createSync(recursive: true)
      ..writeAsBytesSync(excel.encode()!);

    await Share.shareXFiles([XFile(file.path)], text: 'Báo cáo tổng kết $_selectedTerm');
  }

  bool get _canProcess => _userRole?.toLowerCase() == 'admin' || _userRole?.toLowerCase() == 'leader-vip';

  @override
  Widget build(BuildContext context) {
    final filteredData = _summaries.where((s) {
      final matchesSearch = s['full_name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesTerm = s['term'] == _selectedTerm;
      return matchesSearch && matchesTerm;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Tổng kết học tập"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: _exportExcel,
            tooltip: "Xuất báo cáo",
          ),
        ],
      ),
      body: _isLoading && _classes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilterHeader(),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView(
                          padding: const EdgeInsets.all(24),
                          children: [
                            if (filteredData.isNotEmpty) ...[
                              _buildStatsOverview(filteredData),
                              const SizedBox(height: 32),
                              _buildBarChart(filteredData),
                              const SizedBox(height: 32),
                              Text("Danh sách chi tiết", style: AppTextStyles.sectionHeader),
                              const SizedBox(height: 16),
                              _buildSummaryList(filteredData),
                            ] else
                              _buildEmptyState(),
                          ],
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedClassId,
                  decoration: AppDecorations.inputDecoration(label: "Lớp học", prefixIcon: Icons.class_outlined),
                  items: _classes.map((c) => DropdownMenuItem(
                    value: c['id'].toString(),
                    child: Text(c['class_name'] ?? "N/A"),
                  )).toList(),
                  onChanged: (val) {
                    setState(() => _selectedClassId = val);
                    _fetchSummary();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedTerm,
                  decoration: AppDecorations.inputDecoration(label: "Kỳ học", prefixIcon: Icons.calendar_today_rounded),
                  items: _termOptions.map((t) => DropdownMenuItem(
                    value: t['value']!,
                    child: Text(t['label']!),
                  )).toList(),
                  onChanged: (val) {
                    setState(() => _selectedTerm = val!);
                    _fetchSummary();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: AppDecorations.inputDecoration(label: "Tìm kiếm thiếu nhi", prefixIcon: Icons.search_rounded),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              if (_canProcess) ...[
                const SizedBox(width: 12),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    onPressed: _isProcessing ? null : _handleProcess,
                    child: _isProcessing
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text("TỔNG KẾT", style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(List<dynamic> data) {
    final int total = data.length;
    final int passed = data.where((s) => (s['final_result'] ?? '').toString().toLowerCase().contains('đạt')).length;
    final double avgScore = data.isEmpty 
        ? 0 
        : data.map((s) => double.tryParse(s['avg_score'].toString()) ?? 0.0).reduce((a, b) => a + b) / data.length;

    return Row(
      children: [
        Expanded(child: _statCard("Sĩ số", "$total", Icons.people_outline, AppColors.primary)),
        const SizedBox(width: 12),
        Expanded(child: _statCard("Đạt", "$passed", Icons.check_circle_outline, AppColors.success)),
        const SizedBox(width: 12),
        Expanded(child: _statCard("Điểm TB", avgScore.toStringAsFixed(1), Icons.trending_up_rounded, AppColors.warning)),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(value, style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<dynamic> data) {
    final topData = (List.from(data)
      ..sort((a, b) => (double.tryParse(b['avg_score'].toString()) ?? 0)
          .compareTo(double.tryParse(a['avg_score'].toString()) ?? 0)))
        .take(5)
        .toList();

    return Container(
      height: 240,
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Top 5 học tập", style: AppTextStyles.titleSmall),
          const SizedBox(height: 24),
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: 10,
                barGroups: topData.asMap().entries.map((e) => BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: double.tryParse(e.value['avg_score'].toString()) ?? 0,
                      color: AppColors.primary,
                      width: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                )).toList(),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        if (val.toInt() >= topData.length || val < 0) return const SizedBox();
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(topData[val.toInt()]['first_name'] ?? "", style: AppTextStyles.caption),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(enabled: true),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryList(List<dynamic> data) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length,
      separatorBuilder: (c, i) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = data[index];
        final double score = double.tryParse(item['avg_score'].toString()) ?? 0;
        final String result = item['final_result'] ?? '';
        final bool isPassed = result.toLowerCase().contains('đạt');

        return Container(
          decoration: AppDecorations.card,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: isPassed ? AppColors.success.withAlpha(30) : AppColors.error.withAlpha(30),
              child: Text(
                score.toStringAsFixed(1),
                style: TextStyle(color: isPassed ? AppColors.success : AppColors.error, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            title: Text(item['full_name'] ?? "N/A", style: AppTextStyles.titleSmall),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text("Hạnh kiểm: ${item['conduct_grade'] ?? 'N/A'}", style: AppTextStyles.bodySmall),
                Text("Vắng: ${item['absence_count'] ?? 0} buổi", style: AppTextStyles.bodySmall),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("Hạng: ${item['rank_in_class'] ?? '?'}", style: AppTextStyles.titleSmall.copyWith(color: AppColors.primary)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isPassed ? AppColors.success.withAlpha(20) : AppColors.error.withAlpha(20),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    result,
                    style: TextStyle(color: isPassed ? AppColors.success : AppColors.error, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          children: [
            Icon(Icons.query_stats_rounded, size: 64, color: AppColors.primaryLight),
            const SizedBox(height: 24),
            Text("Chưa có dữ liệu tổng kết", style: AppTextStyles.bodyMedium),
            if (_canProcess) ...[
              const SizedBox(height: 16),
              TextButton(onPressed: _handleProcess, child: const Text("Bắt đầu tổng kết")),
            ],
          ],
        ),
      ),
    );
  }
}