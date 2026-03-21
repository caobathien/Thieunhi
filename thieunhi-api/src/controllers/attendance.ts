import { Request, Response } from 'express';
import AttendanceService from '../services/attendance';
import { sendSuccess, sendError } from '../utils/response';
import ClassAssignmentModel from '../models/class_assignment';

class AttendanceController {
    async scanQR(req: Request, res: Response) {
        try {
            const { ma_qr, class_id } = req.body;
            const currentUser = req.user;
            const marked_by = currentUser?.id;

            if (!ma_qr || !class_id) {
                return sendError(res, 'Thiếu mã QR hoặc mã lớp', 400);
            }

            // Authorization
            if (!currentUser) return sendError(res, 'Chưa đăng nhập', 401);

            if (currentUser.role === 'admin' || currentUser.role === 'leader-vip') {
                // Admin/Leader-VIP can do anything
            } else if (currentUser.role === 'leader') {
                const isAssigned = await ClassAssignmentModel.isUserAssignedToClass(currentUser.id, Number(class_id));
                if (!isAssigned) {
                    return sendError(res, 'Bạn không được phân công phụ trách lớp này', 403);
                }
            } else {
                return sendError(res, 'Bạn không có quyền điểm danh', 403);
            }

            const result = await AttendanceService.scanQRCode(ma_qr, Number(class_id), marked_by as string);
            return sendSuccess(res, 'Điểm danh thành công', result);
        } catch (error: any) {
            return sendError(res, error.message);
        }
    }
    async manualMark(req: Request, res: Response) {
        try {
            const { child_id, class_id, status, reason, attendance_date, lesson_topic } = req.body;
            const currentUser = req.user;
            const marked_by = currentUser?.id;

            if (!child_id || !class_id || !status) {
                return sendError(res, 'Vui lòng cung cấp đủ thông tin', 400);
            }

            // Authorization
            if (!currentUser) return sendError(res, 'Chưa đăng nhập', 401);

            if (currentUser.role === 'admin' || currentUser.role === 'leader-vip') {
                // Admin/Leader-VIP can do anything
            } else if (currentUser.role === 'leader') {
                const isAssigned = await ClassAssignmentModel.isUserAssignedToClass(currentUser.id, Number(class_id));
                if (!isAssigned) {
                    return sendError(res, 'Bạn không được phân công phụ trách lớp này', 403);
                }
            } else {
                return sendError(res, 'Bạn không có quyền điểm danh', 403);
            }

            const result = await AttendanceService.markManual(
                { child_id, class_id, status, reason, attendance_date, lesson_topic },
                marked_by as string
            );
            return sendSuccess(res, 'Cập nhật thành công', result);
        } catch (error: any) {
            return sendError(res, error.message);
        }
    }
    // xem điểm danh theo lớp 
    async getClassReport(req: Request, res: Response) {
        try {
            const { class_id } = req.params;
            const { date } = req.query; // Ví dụ: /?date=2023-10-25
            const currentUser = req.user;

            if (!class_id) {
                return sendError(res, 'Thiếu mã lớp học', 400);
            }

            // Authorization
            if (!currentUser) return sendError(res, 'Chưa đăng nhập', 401);
            if (currentUser.role === 'admin' || currentUser.role === 'leader-vip') {
                // OK
            } else if (currentUser.role === 'leader') {
                const isAssigned = await ClassAssignmentModel.isUserAssignedToClass(currentUser.id, Number(class_id));
                if (!isAssigned) return sendError(res, 'Bạn không có quyền xem dữ liệu lớp này', 403);
            } else {
                return sendError(res, 'Bạn không có quyền thực hiện hành động này', 403);
            }

            const result = await AttendanceService.getClassReport(
                Number(class_id), 
                date as string
            );
            
            return sendSuccess(res, 'Lấy danh sách điểm danh thành công', result);
        } catch (error: any) {
            return sendError(res, error.message);
        }
    }
    // lọc theo ngày 
    async getReport(req: Request, res: Response) {
        try {
            const classId = Number(req.params.class_id);
            const { date } = req.query; // Lấy từ ?date=...
            const currentUser = req.user;

            if (!classId) {
                return sendError(res, 'Mã lớp không hợp lệ', 400);
            }

            // Authorization
            if (!currentUser) return sendError(res, 'Chưa đăng nhập', 401);
            if (currentUser.role === 'admin' || currentUser.role === 'leader-vip') {
                // OK
            } else if (currentUser.role === 'leader') {
                const isAssigned = await ClassAssignmentModel.isUserAssignedToClass(currentUser.id, classId);
                if (!isAssigned) return sendError(res, 'Bạn không có quyền xem dữ liệu lớp này', 403);
            } else {
                return sendError(res, 'Bạn không có quyền thực hiện hành động này', 403);
            }

            const data = await AttendanceService.getClassReportByDate(classId, date as string);
            
            return sendSuccess(res, `Danh sách điểm danh ngày ${date || 'hôm nay'}`, data);
        } catch (error: any) {
            return sendError(res, error.message);
        }
    }
    // danh sách các em điểm danh
    async getManualList(req: Request, res: Response) {
        try {
            const { class_id } = req.params;
            const { date } = req.query;
            const currentUser = req.user;

            const classId = Number(class_id);
            // Authorization
            if (!currentUser) return sendError(res, 'Chưa đăng nhập', 401);
            if (currentUser.role === 'admin' || currentUser.role === 'leader-vip') {
                // OK
            } else if (currentUser.role === 'leader') {
                const isAssigned = await ClassAssignmentModel.isUserAssignedToClass(currentUser.id, classId);
                if (!isAssigned) return sendError(res, 'Bạn không có quyền xem dữ liệu lớp này', 403);
            } else {
                return sendError(res, 'Bạn không có quyền thực hiện hành động này', 403);
            }

            const students = await AttendanceService.getManualList(
                classId, 
                date as string
            );

            return sendSuccess(res, 'Lấy danh sách lớp thành công', students);
        } catch (error: any) {
            return sendError(res, error.message);
        }
    }

    // lấy báo cáo thống kê cho khoảng thời gian
    async getStats(req: Request, res: Response) {
        try {
            const { class_id } = req.params;
            const { startDate, endDate } = req.query;
            const currentUser = req.user;

            if (!class_id || !startDate || !endDate) {
                return sendError(res, 'Thiếu thông tin class_id, startDate hoặc endDate', 400);
            }

            const classId = Number(class_id);
            // Authorization
            if (!currentUser) return sendError(res, 'Chưa đăng nhập', 401);
            if (currentUser.role === 'admin' || currentUser.role === 'leader-vip') {
                // OK
            } else if (currentUser.role === 'leader') {
                const isAssigned = await ClassAssignmentModel.isUserAssignedToClass(currentUser.id, classId);
                if (!isAssigned) return sendError(res, 'Bạn không có quyền xem dữ liệu lớp này', 403);
            } else {
                return sendError(res, 'Bạn không có quyền thực hiện hành động này', 403);
            }

            const stats = await AttendanceService.getStats(
                classId, 
                startDate as string, 
                endDate as string
            );

            return sendSuccess(res, 'Lấy thông kê thành công', stats);
        } catch (error: any) {
            return sendError(res, error.message);
        }
    }
}

export default new AttendanceController();