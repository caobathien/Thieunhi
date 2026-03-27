import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../theme/app_theme.dart';

class ChildQRView extends StatefulWidget {
  final Map<String, dynamic> childData;
  const ChildQRView({super.key, required this.childData});

  @override
  State<ChildQRView> createState() => _ChildQRViewState();
}

class _ChildQRViewState extends State<ChildQRView> {
  final GlobalKey _qrKey = GlobalKey();

  Future<void> _downloadQR() async {
    try {
      var status = await Permission.photos.request();
      if (status.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Vui lòng cấp quyền trong cài đặt để lưu ảnh")),
          );
        }
        openAppSettings();
        return;
      }

      RenderRepaintBoundary boundary = _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      await Gal.putImageBytes(pngBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("✅ Đã lưu mã QR vào bộ sưu tập ảnh!"),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Lỗi khi lưu ảnh: $e"),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String qrCodeString = widget.childData['ma_qr'] ?? "NO_CODE";
    final String fullName = "${widget.childData['baptismal_name'] ?? ''} ${widget.childData['last_name'] ?? ''} ${widget.childData['first_name'] ?? ''}".trim();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Tải Mã QR"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RepaintBoundary(
              key: _qrKey,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: AppShadows.card,
                ),
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      fullName.toUpperCase(),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                    const SizedBox(height: 15),
                    QrImageView(
                      data: qrCodeString,
                      version: QrVersions.auto,
                      size: 220.0,
                      gapless: false,
                      eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Mã định danh: $qrCodeString",
                      style: AppTextStyles.caption.copyWith(letterSpacing: 1.2),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: 250,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _downloadQR,
                icon: const Icon(Icons.download_for_offline_rounded),
                label: const Text("LƯU VỀ ĐIỆN THOẠI", style: TextStyle(fontWeight: FontWeight.w700)),
                style: AppDecorations.primaryButton.copyWith(
                  padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Ảnh sẽ được lưu trực tiếp vào Album của bạn",
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}