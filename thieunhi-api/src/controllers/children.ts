import { NextFunction, Request, Response } from 'express';
import ChildService from '../services/children';
import { sendSuccess, sendError } from '../utils/response';
import ClassAssignmentModel from '../models/class_assignment';

class ChildController {
    async getByClass(req: Request, res: Response) {
        try {
            const classId = parseInt(req.params.classId as string);
            const currentUser = (req as any).user;

            // Authorization
            if (currentUser.role === 'leader') {
                const isAssigned = await ClassAssignmentModel.isUserAssignedToClass(currentUser.id, classId);
                if (!isAssigned) return sendError(res, 'Bạn không có quyền xem dữ liệu lớp này', 403);
            }

            const children = await ChildService.getChildrenByClass(classId);
            return sendSuccess(res, 'Lấy danh sách theo lớp thành công', children);
        } catch (error: any) {
            return sendError(res, error.message);
        }
    }
    async getAll(req: Request, res: Response) {
        try {
            const currentUser = (req as any).user;
            let children: any[] = [];

            if (currentUser.role === 'leader') {
                const assignment = await ClassAssignmentModel.findByUserId(currentUser.id);
                if (assignment) {
                    children = await ChildService.getChildrenByClass(assignment.class_id);
                } else {
                    children = [];
                }
            } else {
                children = await ChildService.getAllChildren();
            }

            return sendSuccess(res, 'Lấy danh sách thành công', children);
        } catch (error: any) {
            return sendError(res, error.message);
        }
    }

    async create(req: Request, res: Response) {
        try {
            const { class_id } = req.body;
            const currentUser = (req as any).user;

            // Authorization
            if (currentUser.role === 'leader') {
                const isAssigned = await ClassAssignmentModel.isUserAssignedToClass(currentUser.id, Number(class_id));
                if (!isAssigned) return sendError(res, 'Bạn không có quyền thêm thiếu nhi vào lớp này', 403);
            }

            const newChild = await ChildService.addChild(req.body);
            return sendSuccess(res, 'Thêm thiếu nhi thành công', newChild, 201);
        } catch (error: any) {
            console.error("Lỗi thật sự từ DB là:", error);
            return sendError(res, error.message, 500);
        }
    }

    async update(req: Request, res: Response) {
        try {
            const childId = req.params.id as string;
            const currentUser = (req as any).user;

            // Authorization check for leader
            if (currentUser.role === 'leader') {
                const child = await ChildService.getChildDetail(childId);
                if (!child.class_id) return sendError(res, 'Thiếu nhi này chưa có lớp', 400);
                const isAssigned = await ClassAssignmentModel.isUserAssignedToClass(currentUser.id, child.class_id as number);
                if (!isAssigned) return sendError(res, 'Bạn không có quyền cập nhật thông tin thiếu nhi này', 403);
            }

            const updatedChild = await ChildService.updateChild(childId, req.body);
            return sendSuccess(res, 'Cập nhật thành công', updatedChild);
        } catch (error: any) {
            return sendError(res, error.message);
        }
    }

    async delete(req: Request, res: Response) {
        try {
            const childId = req.params.id as string;
            const currentUser = (req as any).user;

            // Authorization check for leader
            if (currentUser.role === 'leader') {
                const child = await ChildService.getChildDetail(childId);
                if (!child.class_id) return sendError(res, 'Thiếu nhi này chưa có lớp', 400);
                const isAssigned = await ClassAssignmentModel.isUserAssignedToClass(currentUser.id, child.class_id as number);
                if (!isAssigned) return sendError(res, 'Bạn không có quyền xóa thiếu nhi này', 403);
            }

            const deleted = await ChildService.removeChild(childId);
            if (!deleted) {
                return sendError(res, 'Không tìm thấy thiếu nhi để xóa');
            }
            return sendSuccess(res, 'Xóa thành công');
        } catch (error: any) {
            return sendError(res, error.message);
        }
    }
    async exportExcel(req: Request, res: Response) {
        try {
            const buffer = await ChildService.exportToExcel();
            
            res.setHeader(
                'Content-Type',
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
            );
            res.setHeader(
                'Content-Disposition',
                'attachment; filename=DanhSachThieuNhi.xlsx'
            );

            res.send(buffer);
        } catch (error: any) {
            return sendError(res, error.message);
        }
    }

    async exportByClass(req: Request, res: Response) {
        try {
            const classId = parseInt(req.params.classId as string);
            const buffer = await ChildService.exportToExcel(classId);
            
            res.setHeader(
                'Content-Type',
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
            );
            res.setHeader(
                'Content-Disposition',
                `attachment; filename=DanhSachLop_${classId}.xlsx`
            );

            res.send(buffer);
        } catch (error: any) {
            return sendError(res, error.message);
        }
    }

    async importExcel(req: Request, res: Response) {
        try {
            const classId = parseInt(req.params.classId as string);
            const currentUser = (req as any).user;

            // Authorization
            if (currentUser.role === 'leader') {
                const isAssigned = await ClassAssignmentModel.isUserAssignedToClass(currentUser.id, classId);
                if (!isAssigned) return sendError(res, 'Bạn không có quyền thực hiện hành động này cho lớp này', 403);
            }

            if (!req.file) {
                return sendError(res, 'Vui lòng chọn file Excel để tải lên');
            }
            const results = await ChildService.importFromExcel(req.file.buffer, classId);
            return sendSuccess(res, 'Nhập dữ liệu thành công', results);
        } catch (error: any) {
            return sendError(res, error.message);
        }
    }
}

export default new ChildController();