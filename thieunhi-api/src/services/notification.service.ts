import nodemailer from 'nodemailer';
import dotenv from 'dotenv';

dotenv.config();

class NotificationService {
    private transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        // Nó sẽ lấy giá trị từ file .env tương ứng
        user: process.env.EMAIL_USER, 
        pass: process.env.EMAIL_PASS
    }
});

    async sendAdminFeedbackNotify(feedbackData: any) {
    // Kiểm tra dữ liệu đầu vào để tránh email trống
    const title = feedbackData.title || 'Không có tiêu đề';
    const content = feedbackData.content || 'Không có nội dung';
    const category = feedbackData.category || 'Góp ý chung';
    const rating = feedbackData.rating || 0;

    const mailOptions = {
        from: `"Hệ thống Thiếu Nhi" <${process.env.EMAIL_USER}>`,
        to: process.env.ADMIN_EMAIL,
        subject: `🔔 PHẢN HỒI MỚI: ${title}`,
        html: `
            <div style="font-family: sans-serif; max-width: 600px; border: 1px solid #eee; padding: 20px;">
                <h2 style="color: #2e59d9;">📩 Phản hồi mới từ hệ thống</h2>
                <p><strong>Loại:</strong> ${category}</p>
                <p><strong>Tiêu đề:</strong> ${title}</p>
                <p><strong>Nội dung:</strong></p>
                <div style="background: #f9f9f9; padding: 15px; border-radius: 5px;">
                    ${content}
                </div>
                <p><strong>Đánh giá:</strong> ${'⭐'.repeat(rating)}</p>
                <hr>
                <p style="font-size: 12px; color: #999;">Gửi lúc: ${new Date().toLocaleString('vi-VN')}</p>
            </div>
        `
    };

    try {
        await this.transporter.sendMail(mailOptions);
        console.log('✅ Đã gửi email thông báo thành công!');
    } catch (error) {
        console.error('❌ Lỗi gửi email:', error);
    }
}
}

export default new NotificationService();