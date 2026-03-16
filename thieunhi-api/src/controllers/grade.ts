import { Request, Response } from 'express';
import GradeService from '../services/grade.service';
import { sendSuccess, sendError } from '../utils/response';

class GradeController {
    /**
     * POST: Khởi tạo bảng điểm cho thiếu nhi
     */
    async inputGrade(req: Request, res: Response) {
        try {
            const teacher_id = (req as any).user.id; // Lấy ID người dùng từ token
            const newGrade = await GradeService.addGrade({ 
                ...req.body, 
                teacher_id 
            });
            return sendSuccess(res, 'Khởi tạo bảng điểm thành công', newGrade, 201);
        } catch (error: any) {
            return sendError(res, error.message, 400);
        }
    }

    /**
     * GET: Lấy bảng điểm cá nhân
     */
    async getStudentGrades(req: Request, res: Response) {
        try {
            const { childId } = req.params;
            const { year } = req.query;

            const transcript = await GradeService.getStudentTranscript(
                childId as string,
                year as string
            );

            return sendSuccess(res, 'Lấy bảng điểm thành công', transcript);
        } catch (error: any) {
            return sendError(res, error.message, 404);
        }
    }

    /**
     * PUT: Cập nhật điểm (Chỉ sửa các cột điểm cần thiết)
     */
    async updateGrade(req: Request, res: Response) {
        try {
            const { id } = req.params;
            const updated = await GradeService.updateExistingGrade(id as string, req.body);
            return sendSuccess(res, 'Cập nhật điểm thành công', updated);
        } catch (error: any) {
            return sendError(res, error.message, 400);
        }
    }

    /**
     * GET: Lấy bảng điểm của tất cả thiếu nhi trong lớp
     */
    async getClassGrades(req: Request, res: Response) {
        try {
            const { classId } = req.params;
            if (!classId) {
                return sendError(res, 'Thiếu mã lớp học', 400);
            }

            const data = await GradeService.getClassGrades(Number(classId));
            return sendSuccess(res, 'Lấy danh sách điểm lớp thành công', data);
        } catch (error: any) {
            return sendError(res, error.message);
        }
    }

    async exportExcel(req: Request, res: Response) {
        try {
            const { classId } = req.params;
            const buffer = await GradeService.exportToExcel(Number(classId));
            
            res.setHeader(
                'Content-Type',
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
            );
            res.setHeader(
                'Content-Disposition',
                `attachment; filename=BangDiemLop_${classId}.xlsx`
            );

            res.send(buffer);
        } catch (error: any) {
            return sendError(res, error.message);
        }
    }

    async importExcel(req: Request, res: Response) {
        try {
            const { classId } = req.params;
            const teacher_id = (req as any).user.id;
            if (!req.file) {
                return sendError(res, 'Vui lòng chọn file Excel để tải lên');
            }
            const results = await GradeService.importFromExcel(req.file.buffer, Number(classId), teacher_id);
            return sendSuccess(res, 'Nhập dữ liệu điểm thành công', results);
        } catch (error: any) {
            return sendError(res, error.message);
        }
    }
}

export default new GradeController();