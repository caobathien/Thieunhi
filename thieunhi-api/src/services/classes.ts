import ClassModel from '../models/class';
import ChirdModel from '../models/child';
import { IClass } from '../interfaces/class';

class ClassService {
    // 1. Lấy toàn bộ danh sách lớp học
    async fetchAllClasses() {
        const classes = await ClassModel.findAll();
        return classes;
    }
    async fetchAllChird() {
        const chirdren = await ChirdModel.findAll();
        return chirdren;
    }

    // 2. Tạo lớp học mới với các kiểm tra nghiệp vụ
    async createNewClass(classData: IClass) {
        // Kiểm tra logic: Sỹ số phải lớn hơn 0
        if (classData.total_capacity && classData.total_capacity <= 0) {
            throw new Error('Sỹ số tối đa của lớp phải lớn hơn 0');
        }

        // Kiểm tra niên khóa: Định dạng YYYY-YYYY
        const yearRegex = /^\d{4}-\d{4}$/;
        if (classData.academic_year && !yearRegex.test(classData.academic_year)) {
            throw new Error('Niên khóa phải có định dạng YYYY-YYYY (VD: 2025-2026)');
        }

        const newClass = await ClassModel.create(classData);
        return newClass;
    }

    // 3. Cập nhật thông tin lớp
    async updateClassInfo(id: number, updateData: Partial<IClass>) {
        const updatedClass = await ClassModel.update(id, updateData);
        
        if (!updatedClass) {
            throw new Error('Không tìm thấy lớp học để cập nhật');
        }

        return updatedClass;
    }

    // 4. Xóa lớp học
    async removeClass(id: number) {
        const isDeleted = await ClassModel.delete(id);
        
        if (!isDeleted) {
            throw new Error('Không tìm thấy lớp học hoặc lớp học đã bị xóa trước đó');
        }
        
        return true;
    }

    // 5. Lấy danh sách thiếu nhi trong lớp học
    async fetchStudentsByClass(classId: number) {
        const chirdren = await ChirdModel.findByClass(classId);
        return chirdren;
    }
}

export default new ClassService();