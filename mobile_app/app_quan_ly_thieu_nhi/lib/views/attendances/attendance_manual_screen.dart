import 'package:flutter/material.dart';
import '../../services/child_service.dart';
import '../../services/attendance_service.dart';
import '../../theme/app_theme.dart';

class AttendanceManualScreen extends StatefulWidget {
  final String classId;
  final DateTime date;

  const AttendanceManualScreen({super.key, required this.classId, required this.date});

  @override
  State<AttendanceManualScreen> createState() => _AttendanceManualScreenState();
}

class _AttendanceManualScreenState extends State<AttendanceManualScreen> {
  final ChildService _childService = ChildService();
  final AttendanceService _attendanceService = AttendanceService();
  List<dynamic> _children = [];
  bool _isLoading = true;
  bool _allSelected = false;
  final Map<String, bool> _attendanceMap = {};
  final TextEditingController _lessonTopicController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchChildren();
  }

  Future<void> _fetchChildren() async {
    final result = await _childService.getChildrenByClass(widget.classId);
    if (result['success'] == true) {
      setState(() {
        _children = result['data'] ?? [];
        for (var child in _children) {
          _attendanceMap[child['id'].toString()] = false;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAttendance() async {
    if (_lessonTopicController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập nội dung bài dạy hôm nay!"),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    int successCount = 0;

    try {
      for (var entry in _attendanceMap.entries) {
        final res = await _attendanceService.manualMark(
          childId: entry.key,
          classId: int.parse(widget.classId),
          isPresent: entry.value,
          status: entry.value ? "Có mặt" : "Vắng không phép",
          lessonTopic: _lessonTopicController.text.trim(),
        );
        if (res['success'] == true) successCount++;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Thành công! Đã lưu điểm danh cho $successCount em."),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi lưu dữ liệu: $e"), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Điểm danh thủ công'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.surface,
                  child: Column(
                    children: [
                      TextField(
                        controller: _lessonTopicController,
                        decoration: AppDecorations.inputDecoration(
                          label: "Nội dung bài dạy hôm nay (bắt buộc)",
                          prefixIcon: Icons.menu_book_rounded,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Tổng sĩ số: ${_children.length}", style: AppTextStyles.titleSmall),
                          Row(
                            children: [
                              const Text("Tích tất cả", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              Checkbox(
                                value: _allSelected,
                                activeColor: AppColors.primary,
                                onChanged: (v) {
                                  setState(() {
                                    _allSelected = v!;
                                    for (var child in _children) {
                                      _attendanceMap[child['id'].toString()] = _allSelected;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: _children.length,
                    separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.divider),
                    itemBuilder: (context, index) {
                      final child = _children[index];
                      final id = child['id'].toString();
                      final fullName = "${child['baptismal_name'] ?? ''} ${child['last_name'] ?? ''} ${child['first_name'] ?? ''}".trim();

                      return CheckboxListTile(
                        secondary: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              child['first_name'] != null ? child['first_name'][0].toUpperCase() : "?",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                          ),
                        ),
                        title: Text(fullName, style: AppTextStyles.titleSmall),
                        subtitle: Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _attendanceMap[id]! ? AppColors.success.withAlpha(15) : AppColors.error.withAlpha(15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _attendanceMap[id]! ? 'Hiện diện ✓' : 'Vắng ✗',
                            style: TextStyle(
                              color: _attendanceMap[id]! ? AppColors.success : AppColors.error,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        value: _attendanceMap[id],
                        activeColor: AppColors.primary,
                        onChanged: (v) => setState(() => _attendanceMap[id] = v!),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: AppDecorations.primaryButton,
                      onPressed: _isLoading ? null : _saveAttendance,
                      child: const Text(
                        'LƯU ĐIỂM DANH',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 1.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}