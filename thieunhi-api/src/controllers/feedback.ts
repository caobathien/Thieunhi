import { Request, Response } from 'express';
import FeedbackService from '../services/feedback.service';
import { sendSuccess, sendError } from '../utils/response';
import NotificationService from '../services/notification.service';

class FeedbackController {
    async submitFeedback(req: Request, res: Response) {
        try {
            const user_id = (req as any).user.id;
            const feedback = await FeedbackService.createFeedback({ ...req.body, user_id });

            // Thông báo cho Admin
            NotificationService.sendAdminFeedbackNotify(feedback);

            return sendSuccess(res, 'Gửi phản hồi thành công', feedback, 201);
        } catch (error: any) {
            return sendError(res, error.message, 400);
        }
    }

    // Xem phản hồi của chính mình
    async getMyFeedbacks(req: Request, res: Response) {
        try {
            const user_id = (req as any).user.id;
            const feedbacks = await FeedbackService.getMyFeedbackHistory(user_id);
            return sendSuccess(res, 'Lấy danh sách phản hồi thành công', feedbacks);
        } catch (error: any) {
            return sendError(res, error.message, 500);
        }
    }

    async getAllFeedbacks(req: Request, res: Response) {
        try {
            const role = (req as any).user.role;
            const processedData = await FeedbackService.getProcessedFeedbacks(role);
            return sendSuccess(res, 'Lấy danh sách phản hồi thành công', processedData);
        } catch (error: any) {
            return sendError(res, error.message, 500);
        }
    }

    async respondFeedback(req: Request, res: Response) {
        try {
            const { id } = req.params;
            const { status, admin_note } = req.body;
            const updated = await FeedbackService.processFeedbackResponse(
                Number(id), 
                status, 
                admin_note
            );
            return sendSuccess(res, 'Đã cập nhật phản hồi', updated);
        } catch (error: any) {
            return sendError(res, error.message, 400);
        }
    }
}

export default new FeedbackController();