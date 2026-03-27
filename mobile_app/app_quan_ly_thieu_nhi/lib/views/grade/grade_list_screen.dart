import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/grade_service.dart';
import '../../theme/app_theme.dart';
import 'grade_form_screen.dart';
import '../../services/token_service.dart';

class GradeListScreen extends StatefulWidget {
  final dynamic childData;
  final int? classId;

  const GradeListScreen({super.key, this.childData, this.classId});

  @override
  State<GradeListScreen> createState() => _GradeListScreenState();
}

class _GradeListScreenState extends State<GradeListScreen> {
  final GradeService _gradeService = GradeService();
  final TokenService _tokenService = TokenService();
  List<dynamic> _displayList = [];
  bool _isLoading = true;
  String _userRole = 'user';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _fetchData();
  }

  Future<void> _loadUserRole() async {
    final role = await _tokenService.getUserRole();
    if (mounted) {
      setState(() => _userRole = role?.toLowerCase() ?? 'user');
    }
  }

  Future<void> _exportExcel() async {
    if (widget.classId != null) {
      await _gradeService.exportGrades(widget.classId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã lưu file Excel vào thư mục Documents")),
        );
      }
    }
  }

  Future<void> _importExcel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null && widget.classId != null) {
      File file = File(result.files.single.path!);
      final res = await _gradeService.importGrades(widget.classId!, file);
      if (res['success'] == true) {
        _fetchData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Nhập dữ liệu điểm thành công")),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Lỗi: ${res['message']}")),
          );
        }
      }
    }
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final result = widget.childData != null
        ? await _gradeService.getStudentGrades(widget.childData['id'].toString())
        : await _gradeService.getClassGrades(widget.classId ?? 1);

    if (result['success'] == true) {
      _displayList = widget.childData != null ? result['data']['grades'] : result['data'];
    }
    setState(() => _isLoading = false);
  }

  String _calculateTotal(dynamic gk, dynamic ck) {
    double v1 = double.tryParse(gk?.toString() ?? '0') ?? 0;
    double v2 = double.tryParse(ck?.toString() ?? '0') ?? 0;
    if (v1 == 0 && v2 == 0) return "-";
    return ((v1 + v2) / 2).toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    bool isStudentView = widget.childData != null;
    final bool isAdmin = _userRole == 'admin' || _userRole == 'leader';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isStudentView ? "Bảng điểm cá nhân" : "Quản lý Điểm số"),
        actions: [
          if (isAdmin)
            PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'export') _exportExcel();
                if (val == 'import') _importExcel();
              },
              icon: const Icon(Icons.more_vert_rounded),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.file_download_outlined, size: 20, color: AppColors.primary),
                      SizedBox(width: 12),
                      Text("Xuất file Excel"),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'import',
                  child: Row(
                    children: [
                      Icon(Icons.file_upload_outlined, size: 20, color: AppColors.secondary),
                      SizedBox(width: 12),
                      Text("Nhập từ Excel"),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : Column(
              children: [
                _buildSummaryHeader(),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: _displayList.length,
                    separatorBuilder: (c, i) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _buildGradeCard(_displayList[index]),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.childData != null
                ? "Kết quả học tập: ${widget.childData['last_name']} ${widget.childData['first_name']}"
                : "Danh sách điểm lớp học",
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            "Cập nhật trạng thái điểm định kỳ HK1 & HK2",
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildGradeCard(dynamic item) {
    String total1 = _calculateTotal(item['midterm_score_k1'], item['final_score_k1']);
    String total2 = _calculateTotal(item['midterm_score_k2'], item['final_score_k2']);
    final bool isAdmin = _userRole == 'admin' || _userRole == 'leader';

    return Container(
      decoration: AppDecorations.card,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isAdmin ? () => _showEditDialog(item) : null,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          (item['first_name'] ?? 'T').toString().isNotEmpty ? (item['first_name'] ?? 'T')[0].toUpperCase() : 'T',
                          style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "${item['last_name']} ${item['first_name']}",
                        style: AppTextStyles.titleSmall,
                      ),
                    ),
                    if (isAdmin)
                      const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 24),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildSemesterCol("HỌC KỲ 1", item['midterm_score_k1'], item['final_score_k1'], total1, AppColors.primary),
                    Container(width: 1, height: 40, color: AppColors.border, margin: const EdgeInsets.symmetric(horizontal: 16)),
                    _buildSemesterCol("HỌC KỲ 2", item['midterm_score_k2'], item['final_score_k2'], total2, AppColors.secondary),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSemesterCol(String title, dynamic mid, dynamic fin, String total, Color accent) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.labelLarge.copyWith(fontSize: 10, color: AppColors.textLight)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildScoreItem("GK", mid),
              const SizedBox(width: 12),
              _buildScoreItem("CK", fin),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withAlpha(15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(total, style: AppTextStyles.titleSmall.copyWith(color: accent, fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, dynamic score) {
    double s = double.tryParse(score?.toString() ?? '0') ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textLight)),
        Text(s == 0 ? "-" : s.toString(), style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  void _showEditDialog(dynamic item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GradeFormScreen(childData: item, gradeData: item),
    ).then((value) {
      if (value == true) _fetchData();
    });
  }
}