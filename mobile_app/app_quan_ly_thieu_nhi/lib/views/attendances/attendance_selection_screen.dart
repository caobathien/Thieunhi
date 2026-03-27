import 'package:flutter/material.dart';
import '../../services/class_service.dart';
import '../../theme/app_theme.dart';
import 'attendance_qr_screen.dart';
import 'attendance_manual_screen.dart';

class AttendanceSelectionScreen extends StatefulWidget {
  final String? userRole;
  final Map<String, dynamic>? userProfile;

  const AttendanceSelectionScreen({super.key, this.userRole, this.userProfile});

  @override
  State<AttendanceSelectionScreen> createState() => _AttendanceSelectionScreenState();
}

class _AttendanceSelectionScreenState extends State<AttendanceSelectionScreen> {
  final ClassService _classService = ClassService();
  List<dynamic> _classes = [];
  String? _selectedClassId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  @override
  void didUpdateWidget(covariant AttendanceSelectionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userProfile != oldWidget.userProfile || widget.userRole != oldWidget.userRole) {
      _applyAutoSelection();
    }
  }

  void _applyAutoSelection() {
    if (widget.userRole == 'leader' && widget.userProfile != null) {
      final assignedId = widget.userProfile!['assigned_class_id']?.toString();
      if (assignedId != null && _classes.isNotEmpty) {
        final exists = _classes.any((c) => c['id'].toString() == assignedId);
        if (exists) {
          setState(() {
            _selectedClassId = assignedId;
          });
        }
      }
    }
  }

  Future<void> _fetchClasses() async {
    final result = await _classService.getAllClasses();
    if (result['success'] == true) {
      if (mounted) {
        setState(() {
          _classes = result['data'] ?? [];
          _isLoading = false;
        });
        _applyAutoSelection();
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Cấu hình Điểm danh"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Configuration Section ──
                  Text("Thông tin buổi học", style: AppTextStyles.sectionHeader),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: AppDecorations.card,
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedClassId,
                          decoration: AppDecorations.inputDecoration(
                            label: 'Lớp học',
                            prefixIcon: Icons.school_outlined,
                          ),
                          // Chặn chọn lớp khác nếu là Leader thường
                          items: _classes.map((c) => DropdownMenuItem<String>(
                            value: c['id'].toString(),
                            child: Text(c['class_name'] ?? "Lớp học"),
                          )).toList(),
                          onChanged: (widget.userRole == 'admin' || widget.userRole == 'leader-vip') 
                              ? (v) => setState(() => _selectedClassId = v)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2024),
                              lastDate: DateTime(2100),
                            );
                            if (d != null) setState(() => _selectedDate = d);
                          },
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: InputDecorator(
                            decoration: AppDecorations.inputDecoration(
                              label: 'Ngày điểm danh',
                              prefixIcon: Icons.calendar_today_outlined,
                            ),
                            child: Text(
                              '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                              style: AppTextStyles.bodyLarge,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Methods Section ──
                  Text("Phương thức thực hiện", style: AppTextStyles.sectionHeader),
                  const SizedBox(height: 16),
                  _buildMethodCard(
                    icon: Icons.qr_code_scanner_rounded,
                    title: "Quét mã QR",
                    subtitle: "Sử dụng camera để quét thẻ định danh",
                    color: AppColors.primary,
                    onTap: () => _navigateTo("qr"),
                  ),
                  const SizedBox(height: 12),
                  _buildMethodCard(
                    icon: Icons.checklist_rtl_rounded,
                    title: "Điểm danh thủ công",
                    subtitle: "Đánh dấu trạng thái trực tiếp từ danh sách",
                    color: AppColors.secondary,
                    onTap: () => _navigateTo("manual"),
                  ),
                ],
              ),
            ),
    );
  }

  void _navigateTo(String mode) {
    if (_selectedClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn lớp học")),
      );
      return;
    }
    Widget screen = mode == "qr"
        ? AttendanceQRScreen(classId: _selectedClassId!, date: _selectedDate)
        : AttendanceManualScreen(classId: _selectedClassId!, date: _selectedDate);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Widget _buildMethodCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppDecorations.card,
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleSmall),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}