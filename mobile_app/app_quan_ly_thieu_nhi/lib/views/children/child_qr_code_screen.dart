import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ChildQRCodeScreen extends StatelessWidget {
  final Map<String, dynamic> childData;

  const ChildQRCodeScreen({super.key, required this.childData});

  @override
  Widget build(BuildContext context) {
    // Lấy mã QR từ cột ma_qr trong SQL
    final String qrData = childData['ma_qr'] ?? "NO_DATA";
    final String fullName = "${childData['baptismal_name'] ?? ''} ${childData['last_name'] ?? ''} ${childData['first_name'] ?? ''}";

    return Scaffold(
      appBar: AppBar(title: const Text("Mã QR Thiếu nhi")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            // Tạo ảnh QR từ mã qr lấy trong SQL
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 250.0,
              gapless: false,
              embeddedImage: const AssetImage('assets/images/logo_church.png'), // Tùy chọn chèn logo đoàn
              embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(40, 40)),
            ),
            const SizedBox(height: 20),
            Text("Mã số: $qrData", style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
