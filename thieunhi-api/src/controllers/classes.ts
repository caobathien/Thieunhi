import { Request, Response } from 'express';
import { sendSuccess, sendError } from '../utils/response';
import ClassService from '../services/classes';
import ClassAssignmentModel from '../models/class_assignment';

class ClassController {
    async getAllClasses(req: Request, res: Response) {
        try {
            const currentUser = (req as any).user;
            let classes: any[] = [];

            if (currentUser.role === 'leader') {
                const assignment = await ClassAssignmentModel.findByUserId(currentUser.id);
                if (assignment) {
                    const all = await ClassService.fetchAllClasses();
                    classes = all.filter(c => c.id === assignment.class_id);
                }
            } else {
                classes = await ClassService.fetchAllClasses();
            }

            return sendSuccess(res, 'Lấy danh sách lớp thành công', classes);
        } catch (error: any) {
            return sendError(res, error.message);
        }
    }

    async createClass(req: Request, res: Response) {
        try {
            const newClass = await ClassService.createNewClass(req.body);
            return sendSuccess(res, 'Tạo lớp học mới thành công', newClass, 201);
        } catch (error: any) {
            return sendError(res, error.message, 400); // Thêm mã lỗi 400 cho lỗi logic
        }
    }

    async updateClass(req: Request, res: Response) {
        try {
            const id = parseInt(req.params.id as string);
            
            // Gọi Service để xử lý logic cập nhật
            const updated = await ClassService.updateClassInfo(id, req.body);
            
            return sendSuccess(res, 'Cập nhật lớp học thành công', updated);
        } catch (error: any) {
            // Trả về lỗi 404 nếu không tìm thấy, hoặc 400 nếu lỗi dữ liệu
            const statusCode = error.message.includes('không tìm thấy') ? 404 : 400;
            return sendError(res, error.message, statusCode);
        }
    }
    async deleteClass(req: Request, res: Response) {
        try {
            const id = parseInt(req.params.id as string);
            
            // Gọi Service để thực hiện xóa
            await ClassService.removeClass(id);
            
            return sendSuccess(res, 'Đã xóa lớp học thành công');
        } catch (error: any) {
            // Xử lý lỗi vi phạm ràng buộc khóa ngoại (lớp đang có thiếu nhi/điểm danh)
            // Mã lỗi '23503' thường đến từ thư viện pg khi có ràng buộc Database
            if (error.code === '23503' || error.message.includes('foreign key')) {
                return sendError(
                    res, 
                    'Không thể xóa lớp này vì đang có dữ liệu thiếu nhi hoặc điểm danh liên quan. Hãy chuyển thiếu nhi sang lớp khác trước.', 
                    400
                );
            }
            
            return sendError(res, error.message, 400);
        }
    }
    // hiển thị danh sách theieus nhi trong lớp
    async getStudentsInClass(req: Request, res: Response) {
    try {
        const classId = parseInt(req.params.id as string);
        
        const students = await ClassService.fetchStudentsByClass(classId);
        
        return sendSuccess(
            res, 
            `Lấy danh sách thiếu nhi của lớp thành công`, 
            students
        );
    } catch (error: any) {
        const statusCode = error.message.includes('không tìm thấy') ? 404 : 400;
        return sendError(res, error.message, statusCode);
    }
}
}

export default new ClassController();   