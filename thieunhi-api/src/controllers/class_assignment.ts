import { Request, Response } from 'express';
import ClassAssignmentService from '../services/class_assignment.service';
import { sendSuccess, sendError } from '../utils/response';

class ClassAssignmentController {
    // Thêm Huynh trưởng vào lớp
    async assignLeader(req: Request, res: Response) {
        try {
            const assignment = await ClassAssignmentService.assignLeaderToClass(req.body);
            return sendSuccess(res, 'Phân công Huynh trưởng thành công', assignment, 201);
        } catch (error: any) {
            return sendError(res, error.message, 400);
        }
    }

    // Lấy tất cả phân công (kèm info lớp và leader)
    async getAllAssignments(req: Request, res: Response) {
        try {
            const { year } = req.query; // Ví dụ: ?year=2025-2026
            const assignments = await ClassAssignmentService.getAssignments(year as string);
            return sendSuccess(res, 'Lấy danh sách phân công thành công', assignments);
        } catch (error: any) {
            return sendError(res, error.message, 400);
        }
    }

    // Xem danh sách Huynh trưởng trong lớp
    async getLeadersByClass(req: Request, res: Response) {
        try {
            const { classId } = req.params;
            const { year } = req.query; // Ví dụ: ?year=2025-2026
            
            const leaders = await ClassAssignmentService.getAssignmentsByClass(
                Number(classId), 
                year as string
            );
            return sendSuccess(res, 'Lấy danh sách phân công thành công', leaders);
        } catch (error: any) {
            return sendError(res, error.message, 400);
        }
    }

    // Gỡ Huynh trưởng khỏi lớp
    async removeAssignment(req: Request, res: Response) {
        try {
            const { id } = req.params;
            await ClassAssignmentService.removeAssignment(Number(id));
            return sendSuccess(res, 'Đã gỡ phân công thành công');
        } catch (error: any) {
            return sendError(res, error.message, 404);
        }
    }
    async exportExcel(req: Request, res: Response) {
    try {
        const { classId } = req.params;
        const { year } = req.query;

        if (!year) {
            return sendError(res, 'Vui lòng cung cấp niên học (?year=...)', 400);
        }

        const workbook = await ClassAssignmentService.exportAssignmentsToExcel(
            Number(classId), 
            year as string
        );

        const fileName = `PhanCong_Lop${classId}_${year}.xlsx`;

        // Thiết lập Header
        res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        res.setHeader('Content-Disposition', `attachment; filename="${fileName}"`);

        // Ghi trực tiếp vào response stream
        await workbook.xlsx.write(res);
        res.status(200).end();
    } catch (error: any) {
        // Lưu ý: Nếu đã set Header mà gặp lỗi, bạn không thể dùng sendError thông thường
        if (!res.headersSent) {
            return sendError(res, error.message);
        }
    }
}
}

export default new ClassAssignmentController();