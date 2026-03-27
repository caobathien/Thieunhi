import 'package:flutter/material.dart';
import '../../services/grade_service.dart';
import '../../theme/app_theme.dart';

class GradeFormScreen extends StatefulWidget {
  final dynamic childData;
  final dynamic gradeData;

  const GradeFormScreen({super.key, required this.childData, this.gradeData});

  @override
  State<GradeFormScreen> createState() => _GradeFormScreenState();
}

class _GradeFormScreenState extends State<GradeFormScreen> {
  final _gradeService = GradeService();
  late TextEditingController _gk1, _ck1, _gk2, _ck2, _remarks;

  @override
  void initState() {
    super.initState();
    _gk1 = TextEditingController(text: widget.gradeData['midterm_score_k1']?.toString() ?? '0');
    _ck1 = TextEditingController(text: widget.gradeData['final_score_k1']?.toString() ?? '0');
    _gk2 = TextEditingController(text: widget.gradeData['midterm_score_k2']?.toString() ?? '0');
    _ck2 = TextEditingController(text: widget.gradeData['final_score_k2']?.toString() ?? '0');
    _remarks = TextEditingController(text: widget.gradeData['remarks'] ?? '');
  }

  Future<void> _handleSave() async {
    final data = {
      "midterm_score_k1": double.tryParse(_gk1.text) ?? 0,
      "final_score_k1": double.tryParse(_ck1.text) ?? 0,
      "midterm_score_k2": double.tryParse(_gk2.text) ?? 0,
      "final_score_k2": double.tryParse(_ck2.text) ?? 0,
      "remarks": _remarks.text,
    };

    final res = await _gradeService.updateGrade(widget.gradeData['grade_id'].toString(), data);
    if (res['success']) {
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24, right: 24, top: 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Cập nhật điểm số", style: AppTextStyles.titleMedium),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "${widget.childData['last_name']} ${widget.childData['first_name']}",
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 24),

          // ── Semester 1 ──
          Text("HỌC KỲ 1", style: AppTextStyles.labelLarge.copyWith(fontSize: 11, color: AppColors.primary)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildPointField(_gk1, "Giữa kỳ")),
              const SizedBox(width: 12),
              Expanded(child: _buildPointField(_ck1, "Cuối kỳ")),
            ],
          ),
          const SizedBox(height: 24),

          // ── Semester 2 ──
          Text("HỌC KỲ 2", style: AppTextStyles.labelLarge.copyWith(fontSize: 11, color: AppColors.secondary)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildPointField(_gk2, "Giữa kỳ")),
              const SizedBox(width: 12),
              Expanded(child: _buildPointField(_ck2, "Cuối kỳ")),
            ],
          ),
          const SizedBox(height: 24),

          TextField(
            controller: _remarks,
            maxLines: 2,
            decoration: AppDecorations.inputDecoration(
              label: "Nhận xét / Ghi chú",
              prefixIcon: Icons.notes_outlined,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: AppDecorations.primaryButton,
              onPressed: _handleSave,
              child: const Text("CẬP NHẬT", style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.0)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPointField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: AppDecorations.inputDecoration(
        label: label,
      ),
    );
  }
}