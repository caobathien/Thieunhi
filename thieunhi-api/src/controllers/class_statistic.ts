import { Request, Response } from 'express';
import ClassStatisticService from '../services/class_statistic.service';
import { sendSuccess, sendError } from '../utils/response';

class ClassStatisticController {
    // Chạy tính toán thống kê
    async runClassStats(req: Request, res: Response) {
        try {
            const { class_id, term, academic_year } = req.body;
            const stats = await ClassStatisticService.syncClassStatistics(
                class_id, 
                term, 
                academic_year
            );
            return sendSuccess(res, 'Cập nhật thống kê lớp thành công', stats);
        } catch (error: any) {
            return sendError(res, error.message, 400);
        }
    }

    // Lấy lịch sử thống kê
    async getClassStats(req: Request, res: Response) {
        try {
            const { classId } = req.params;
            const stats = await ClassStatisticService.getClassPerformanceHistory(Number(classId));
            return sendSuccess(res, 'Lấy lịch sử thống kê lớp thành công', stats);
        } catch (error: any) {
            return sendError(res, error.message, 404);
        }
    }
    async exportExcel(req: Request, res: Response) {
        try {
            const { classId } = req.params;
            const workbook = await ClassStatisticService.exportStatisticsExcel(Number(classId));

            // Thiết lập Header tải file
            res.setHeader(
                'Content-Type',
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
            );
            res.setHeader(
                'Content-Disposition',
                `attachment; filename=ThongKe_Lop_${classId}.xlsx`
            );

            await workbook.xlsx.write(res);
            res.end();
        } catch (error: any) {
            return sendError(res, error.message, 400);
        }
    }
}

export default new ClassStatisticController();