import FeedbackModel from '../models/feedback';
import { IFeedback } from '../interfaces/feedback';

class FeedbackService {
    /**
     * 1. Gửi phản hồi mới
     */
    async createFeedback(data: IFeedback) {
        // Kiểm tra logic đánh giá (Phải từ 1 đến 5 sao)
        if (data.rating < 1 || data.rating > 5) {
            throw new Error('Đánh giá phải nằm trong khoảng từ 1 đến 5 sao');
        }

        // Kiểm tra nội dung tối thiểu
        if (!data.content || data.content.trim().length < 10) {
            throw new Error('Nội dung phản hồi quá ngắn, vui lòng mô tả chi tiết hơn');
        }

        // Gọi Model để lưu vào Database
        return await FeedbackModel.create(data);
    }

    /**
     * 2. Lấy danh sách phản hồi và xử lý quyền xem thông tin ẩn danh
     */
    async getProcessedFeedbacks(currentUserRole: string) {
        const feedbacks = await FeedbackModel.findAll();

        // Xử lý bảo mật thông tin dựa trên vai trò
        return feedbacks.map(fb => {
            const feedbackData = { ...fb };

            // Nếu feedback được đánh dấu ẩn danh VÀ người xem KHÔNG PHẢI là admin
            // (Chỉ Admin tuyệt đối mới thấy được danh tính người gửi ẩn danh)
            if (feedbackData.is_anonymous && currentUserRole !== 'admin') {
                feedbackData.sender_name = "Người dùng ẩn danh";
                feedbackData.user_id = null;
                feedbackData.image_url = feedbackData.image_url ? "hidden" : null; // Giấu ảnh nếu cần bảo mật cao
            }

            return feedbackData;
        });
    }

    /**
     * 3. Xử lý phản hồi từ phía Admin
     */
    async processFeedbackResponse(id: number, status: string, adminNote: string) {
        const validStatuses = ['pending', 'processing', 'resolved'];
        if (!validStatuses.includes(status)) {
            throw new Error('Trạng thái phản hồi không hợp lệ');
        }

        const updated = await FeedbackModel.updateStatus(id, status, adminNote);
        if (!updated) {
            throw new Error('Không tìm thấy phản hồi để cập nhật');
        }

        return updated;
    }

    /**
     * 4. Lấy lịch sử phản hồi của cá nhân
     */
    async getMyFeedbackHistory(userId: string) {
        return await FeedbackModel.findByUserId(userId);
    }
}

export default new FeedbackService();