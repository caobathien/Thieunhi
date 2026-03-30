import { Request, Response } from 'express';
import TermSummaryService from '../services/term_summary.service';
import { sendSuccess, sendError } from '../utils/response';
import ClassAssignmentModel from '../models/class_assignment';

class TermSummaryController {
    // Chạy lệnh tổng kết dữ liệu
    async processSummary(req: Request, res: Response) {
        try {
            const currentUser = (req as any).user;
            const { classId } = req.body;

            if (currentUser.role === 'leader') {
                const isAssigned = await ClassAssignmentModel.isUserAssignedToClass(currentUser.id, Number(classId));
                if (!isAssigned) return sendError(res, 'Bạn không có quyền thực hiện hành động này cho lớp này', 403);
            } else if (currentUser.role !== 'admin' && currentUser.role !== 'leader-vip') {
                return sendError(res, 'Bạn không có quyền thực hiện hành động này', 403);
            }

            const summary = await TermSummaryService.generateSummary(req.body);
            return sendSuccess(res, 'Tổng kết dữ liệu thành công', summary);
        } catch (error: any) {
            return sendError(res, error.message, 400);
        }
    }

    // Xem tổng kết của một em
    async getStudentSummary(req: Request, res: Response) {
        try {
            const { childId } = req.params;
            const { year } = req.query;
            const summaries = await TermSummaryService.getStudentFullSummary(childId as string, year as string);
            return sendSuccess(res, 'Lấy dữ liệu tổng kết thành công', summaries);
        } catch (error: any) {
            return sendError(res, error.message, 404);
        }
    }
    async getClassSummary(req: Request, res: Response) {
        try {
            const { classId } = req.params;
            const { year, term } = req.query;
            const currentUser = (req as any).user;

            if (!classId || !year) {
                return sendError(res, 'Thiếu mã lớp hoặc niên học', 400);
            }

            if (currentUser.role !== 'admin' && currentUser.role !== 'leader-vip' && currentUser.role !== 'leader' && currentUser.role !== 'user') {
                return sendError(res, 'Bạn không có quyền thực hiện hành động này', 403);
            }

            const data = await TermSummaryService.getClassFullSummary(
                Number(classId), 
                year as string,
                (term as string) || 'HK1'
            );
            
            return sendSuccess(res, 'Lấy dữ liệu tổng kết cả lớp thành công', data);
        } catch (error: any) {
            return sendError(res, error.message, 404);
        }
    }
}

export default new TermSummaryController();