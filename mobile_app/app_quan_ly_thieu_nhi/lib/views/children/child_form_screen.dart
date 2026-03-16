import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/child_service.dart';
import '../../theme/app_theme.dart';

class ChildFormScreen extends StatefulWidget {
  final Map<String, dynamic>? childData;
  const ChildFormScreen({super.key, this.childData});

  @override
  State<ChildFormScreen> createState() => _ChildFormScreenState();
}

class _ChildFormScreenState extends State<ChildFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ChildService _childService = ChildService();
  bool _isSubmitting = false;

  late TextEditingController _firstName, _lastName, _baptismalName, _address;
  late TextEditingController _fatherName, _fatherPhone, _fatherSaint;
  late TextEditingController _motherName, _motherPhone, _motherSaint;
  late TextEditingController _notes;

  bool _gender = true;
  String _status = "active";
  DateTime _birthDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final d = widget.childData;

    _firstName = TextEditingController(text: d?['first_name'] ?? '');
    _lastName = TextEditingController(text: d?['last_name'] ?? '');
    _baptismalName = TextEditingController(text: d?['baptismal_name'] ?? '');
    _address = TextEditingController(text: d?['address'] ?? '');
    _fatherName = TextEditingController(text: d?['ho_va_ten_bo'] ?? '');
    _fatherPhone = TextEditingController(text: d?['sdt_bo'] ?? '');
    _fatherSaint = TextEditingController(text: d?['ten_thanh_bo'] ?? '');
    _motherName = TextEditingController(text: d?['ho_va_ten_me'] ?? '');
    _motherPhone = TextEditingController(text: d?['sdt_me'] ?? '');
    _motherSaint = TextEditingController(text: d?['ten_thanh_me'] ?? '');
    _notes = TextEditingController(text: d?['notes'] ?? '');

    if (d != null) {
      _gender = d['gender'].toString().toLowerCase() == 'true';
      _status = d['status'] ?? "active";
      if (d['birth_date'] != null) _birthDate = DateTime.parse(d['birth_date']);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    bool isEdit = widget.childData != null && widget.childData!['id'] != null;

    final Map<String, dynamic> data = {
      "class_id": widget.childData?['class_id'] ?? 1,
      "first_name": _firstName.text.trim(),
      "last_name": _lastName.text.trim(),
      "baptismal_name": _baptismalName.text.trim(),
      "birth_date": _birthDate.toIso8601String(),
      "gender": _gender,
      "address": _address.text.trim(),
      "ten_thanh_bo": _fatherSaint.text.trim(),
      "ho_va_ten_bo": _fatherName.text.trim(),
      "sdt_bo": _fatherPhone.text.trim(),
      "ten_thanh_me": _motherSaint.text.trim(),
      "ho_va_ten_me": _motherName.text.trim(),
      "sdt_me": _motherPhone.text.trim(),
      "status": _status,
      "notes": _notes.text.trim(),
    };

    final result = isEdit
        ? await _childService.updateChild(widget.childData!['id'].toString(), data)
        : await _childService.createChild(data);

    setState(() => _isSubmitting = false);
    if (result['success']) {
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.childData != null && widget.childData!['id'] != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEdit ? "Hồ sơ thiếu nhi" : "Thêm mới thiếu nhi"),
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
                  _buildCardGroup("THÔNG TIN CÁ NHÂN", [
                    _buildInput(_baptismalName, "Tên Thánh", Icons.star_outline_rounded),
                    Row(
                      children: [
                        Expanded(child: _buildInput(_lastName, "Họ và tên lót", Icons.person_outline, req: true)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildInput(_firstName, "Tên", null, req: true)),
                      ],
                    ),
                    _buildGenderAndBirth(),
                    _buildInput(_address, "Địa chỉ liên lạc", Icons.map_outlined),
                  ]),
                  const SizedBox(height: 16),
                  _buildCardGroup("THÔNG TIN GIA ĐÌNH", [
                    _buildParentInput(_fatherSaint, _fatherName, _fatherPhone, "Thông tin Cha", Icons.male),
                    const Divider(height: 32, color: AppColors.divider),
                    _buildParentInput(_motherSaint, _motherName, _motherPhone, "Thông tin Mẹ", Icons.female),
                  ]),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      style: AppDecorations.primaryButton,
                      onPressed: _submitForm,
                      child: Text(
                        isEdit ? "CẬP NHẬT HỒ SƠ" : "LƯU HỒ SƠ",
                        style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15, letterSpacing: 1.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildCardGroup(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(title, style: AppTextStyles.sectionHeader.copyWith(color: AppColors.primary)),
        ),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: AppDecorations.cardSubtle,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label, IconData? icon, {bool req = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        decoration: AppDecorations.inputDecoration(label: label, prefixIcon: icon),
        validator: req ? (v) => (v == null || v.isEmpty) ? "Không được để trống" : null : null,
      ),
    );
  }

  Widget _buildGenderAndBirth() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<bool>(
            initialValue: _gender,
            decoration: AppDecorations.inputDecoration(label: "Giới tính", prefixIcon: Icons.wc_rounded),
            items: const [
              DropdownMenuItem(value: true, child: Text("Nam")),
              DropdownMenuItem(value: false, child: Text("Nữ")),
            ],
            onChanged: (v) => setState(() => _gender = v!),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _birthDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _birthDate = picked);
            },
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: InputDecorator(
              decoration: AppDecorations.inputDecoration(
                label: "Ngày sinh",
                prefixIcon: Icons.cake_rounded,
              ),
              child: Text(DateFormat('dd/MM/yyyy').format(_birthDate), style: AppTextStyles.bodyLarge),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParentInput(TextEditingController saint, TextEditingController name,
      TextEditingController phone, String label, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.titleSmall),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(flex: 2, child: _buildInput(saint, "Tên Thánh", null)),
            const SizedBox(width: 8),
            Expanded(flex: 3, child: _buildInput(name, "Họ và tên", null)),
          ],
        ),
        _buildInput(phone, "Số điện thoại liên lạc", Icons.phone_android, req: false),
      ],
    );
  }
}