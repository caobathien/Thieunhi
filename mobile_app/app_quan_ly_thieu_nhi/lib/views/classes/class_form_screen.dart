import 'package:flutter/material.dart';
import '../../services/class_service.dart';
import '../../theme/app_theme.dart';

class ClassFormScreen extends StatefulWidget {
  final Map<String, dynamic>? classData;
  const ClassFormScreen({super.key, this.classData});

  @override
  State<ClassFormScreen> createState() => _ClassFormScreenState();
}

class _ClassFormScreenState extends State<ClassFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ClassService _classService = ClassService();

  late TextEditingController _className, _roomNumber, _academicYear;
  late TextEditingController _capacity, _description;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final d = widget.classData;
    _className = TextEditingController(text: d?['class_name'] ?? '');
    _roomNumber = TextEditingController(text: d?['room_number'] ?? '');
    _academicYear = TextEditingController(text: d?['academic_year'] ?? '2025-2026');
    _capacity = TextEditingController(text: d?['total_capacity']?.toString() ?? '40');
    _description = TextEditingController(text: d?['description'] ?? '');
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    bool isEdit = widget.classData != null && widget.classData?['id'] != null;
    final data = {
      "class_name": _className.text.trim(),
      "room_number": _roomNumber.text.trim(),
      "academic_year": _academicYear.text.trim(),
      "total_capacity": int.tryParse(_capacity.text) ?? 40,
      "description": _description.text.trim(),
    };

    final result = isEdit
        ? await _classService.updateClass(widget.classData!['id'], data)
        : await _classService.createClass(data);

    setState(() => _isSubmitting = false);

    if (result['success'] && mounted) {
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Có lỗi xảy ra, vui lòng thử lại'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.classData != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEdit ? "Sửa thông tin lớp" : "Tạo lớp mới"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.white),
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 10),
                        child: Text("THÔNG TIN LỚP HỌC", style: AppTextStyles.sectionHeader.copyWith(color: AppColors.primary)),
                      ),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: AppDecorations.cardSubtle,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _className,
                              decoration: AppDecorations.inputDecoration(label: "Tên lớp", prefixIcon: Icons.class_rounded),
                              validator: (v) => v!.isEmpty ? "Bắt buộc" : null,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _roomNumber,
                                    decoration: AppDecorations.inputDecoration(label: "Phòng học", prefixIcon: Icons.meeting_room_outlined),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _academicYear,
                                    decoration: AppDecorations.inputDecoration(label: "Niên khóa", prefixIcon: Icons.calendar_today_rounded),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return "Bắt buộc";
                                      if (!RegExp(r'^\d{4}-\d{4}$').hasMatch(v)) {
                                        return "Định dạng: 2025-2026";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _capacity,
                              keyboardType: TextInputType.number,
                              decoration: AppDecorations.inputDecoration(label: "Sĩ số tối đa", prefixIcon: Icons.people_rounded),
                              validator: (v) {
                                if (v == null || v.isEmpty) return "Bắt buộc";
                                final n = int.tryParse(v);
                                if (n == null || n <= 0) return "Phải lớn hơn 0";
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _description,
                              maxLines: 3,
                              decoration: AppDecorations.inputDecoration(label: "Mô tả", prefixIcon: Icons.notes_rounded),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      style: AppDecorations.primaryButton,
                      onPressed: _submitForm,
                      child: Text(
                        isEdit ? "CẬP NHẬT" : "TẠO LỚP",
                        style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15, letterSpacing: 1.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}