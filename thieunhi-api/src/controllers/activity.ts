import { Request, Response } from 'express';
import ActivityModel from '../models/activity';
import { sendSuccess, sendError } from '../utils/response';

class ActivityController {
    async getActivities(req: Request, res: Response) {
        try {
            const activities = await ActivityModel.findPublic();
            return sendSuccess(res, 'Lấy danh sách hoạt động thành công', activities);
        } catch (error: any) {
            return sendError(res, error.message);
        }
    }

    async createActivity(req: Request, res: Response) {
        try {
            const newActivity = await ActivityModel.create(req.body);
            return sendSuccess(res, 'Đăng thông báo thành công', newActivity, 201);
        } catch (error: any) {
            return sendError(res, error.message);
        }
    }

    async deleteActivity(req: Request, res: Response) {
        try {
            const { id } = req.params;
            await ActivityModel.delete(Number(id));
            return sendSuccess(res, 'Đã xóa thông báo');
        } catch (error: any) {
            return sendError(res, error.message);
        }
    }

    async updateActivity(req: Request, res: Response) {
        try {
            const { id } = req.params;
            const updatedActivity = await ActivityModel.update(Number(id), req.body);
            if (!updatedActivity) {
                return sendError(res, 'Không tìm thấy thông báo để cập nhật', 404);
            }
            return sendSuccess(res, 'Cập nhật thông báo thành công', updatedActivity);
        } catch (error: any) {
            return sendError(res, error.message);
        }
    }
}

export default new ActivityController();