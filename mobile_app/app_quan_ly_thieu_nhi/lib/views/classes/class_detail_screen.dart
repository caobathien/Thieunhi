import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/class_service.dart';
import '../../services/child_service.dart';
import '../../theme/app_theme.dart';
import '../children/child_form_screen.dart';
import '../children/child_detail_screen.dart';
import '../grade/grade_list_screen.dart';
import '../attendances/attendance_stats_screen.dart';
import '../../services/token_service.dart';

class ClassDetailScreen extends StatefulWidget {
  final int classId;
  final String className;

  const ClassDetailScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  final ClassService _classService = ClassService();
  final ChildService _childService = ChildService();
  final TokenService _tokenService = TokenService();

  List<dynamic> _allStudents = [];
  List<dynamic> _filteredStudents = [];
  bool _isLoading = true;
  String _userRole = 'user';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _fetchStudents();
  }

  Future<void> _loadUserRole() async {
    final role = await _tokenService.getUserRole();
    if (mounted) {
      setState(() => _userRole = role?.toLowerCase() ?? 'user');
    }
  }

  Future<void> _exportExcel() async {
    await _childService.exportChildren(widget.classId.toString());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã xuất file Excel")),
      );
    }
  }

  Future<void> _importExcel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      final res = await _childService.importChildren(widget.classId.toString(), file);
      if (res['success'] == true) {
        _fetchStudents();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Nhập dữ liệu thành công")),
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

  Future<void> _fetchStudents() async {
    setState(() => _isLoading = true);
    final response = await _classService.getchirdrenByClass(widget.classId);
    if (response['success'] == true) {
      setState(() {
        _allStudents = response['data'] ?? [];
        _filteredStudents = List.from(_allStudents);
        _isLoading = false;
      });
    } else {
      setState(() {
        _allStudents = [];
        _filteredStudents = [];
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredStudents = _allStudents.where((s) {
        final baptismal = s['baptismal_name'] ?? '';
        final first = s['first_name'] ?? '';
        final last = s['last_name'] ?? '';
        final fullName = "$baptismal $last $first".toLowerCase();
        return fullName.contains(query.toLowerCase());
      }).toList();
    });
  }

  void _confirmDeleteChild(dynamic student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Xác nhận xóa", style: AppTextStyles.titleMedium),
        content: Text("Xóa em ${student['full_name']} khỏi danh sách?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("HỦY", style: AppTextStyles.labelLarge.copyWith(color: AppColors.textLight)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              await _childService.deleteChild(student['id'].toString());
              if (!context.mounted) return;
              Navigator.pop(context);
              _fetchStudents();
            },
            child: const Text("XÓA"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canEdit = _userRole == 'admin' || _userRole == 'leader';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.className, style: AppTextStyles.titleSmall),
            Text("Sĩ số: ${_allStudents.length} em", style: AppTextStyles.bodySmall),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard_outlined),
            tooltip: "Xem điểm",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => GradeListScreen(childData: null, classId: widget.classId)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: "Chuyên cần",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => AttendanceStatsScreen(classId: widget.classId, className: widget.className)),
            ),
          ),
          if (canEdit)
            PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'add') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => ChildFormScreen(childData: {'class_id': widget.classId})),
                  ).then((_) => _fetchStudents());
                } else if (val == 'export') {
                  _exportExcel();
                } else if (val == 'import') {
                  _importExcel();
                }
              },
              icon: const Icon(Icons.more_vert),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'add',
                  child: Row(children: [Icon(Icons.person_add_outlined, size: 18), SizedBox(width: 10), Text("Thêm mới")]),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'export',
                  child: Row(children: [Icon(Icons.file_download_outlined, size: 18), SizedBox(width: 10), Text("Xuất Excel")]),
                ),
                const PopupMenuItem(
                  value: 'import',
                  child: Row(children: [Icon(Icons.file_upload_outlined, size: 18), SizedBox(width: 10), Text("Nhập Excel")]),
                ),
              ],
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ── Search & Filter ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: AppTextStyles.bodyLarge,
                decoration: InputDecoration(
                  hintText: "Tìm kiếm thiếu nhi...",
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
              ),
            ),
          ),

          // ── Data List ──
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : _filteredStudents.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _filteredStudents.length,
                        itemBuilder: (context, index) => _buildStudentItem(_filteredStudents[index], canEdit),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentItem(dynamic student, bool canEdit) {
    String baptismalName = student['baptismal_name'] ?? '';
    String fullName = "${student['last_name'] ?? ''} ${student['first_name'] ?? ''}".trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => ChildDetailScreen(childData: student)),
          ),
          onLongPress: canEdit ? () => _confirmDeleteChild(student) : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      baptismalName.isNotEmpty ? baptismalName[0].toUpperCase() : "TN",
                      style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$baptismalName $fullName",
                        style: AppTextStyles.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone_android_outlined, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            student['sdt_bo'] ?? student['sdt_me'] ?? 'Chưa cập nhật',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.navInactive),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: AppColors.textLight.withAlpha(50)),
          const SizedBox(height: 16),
          Text("Không tìm thấy kết quả", style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
