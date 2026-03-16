import GradeModel from '../models/grade';
import { IGrade } from '../interfaces/grade';
import ExcelService from './excel';

class GradeService {
    /**
     * 1. Khởi tạo bản ghi điểm (Mặc định các đầu điểm là 0)
     */
    // Trong GradeService.ts
    async addGrade(data: IGrade) {
        const yearRegex = /^\d{4}-\d{4}$/;
        if (!yearRegex.test(data.academic_year)) {
            throw new Error('Niên học không đúng định dạng YYYY-YYYY');
        }
        return await GradeModel.create(data);
    }

    /**
     * 2. Lấy bảng điểm cá nhân và tự động tính trung bình
     */
    async getStudentTranscript(childId: string, academicYear: string) {
    const grades = await GradeModel.findByChild(childId, academicYear);

    // Tính toán GPA cho từng bản ghi điểm tìm được
    const formattedGrades = grades.map((g: any) => ({
        ...g,
        grade_id: g.id, // Đổi id thành grade_id để khớp với API lớp
        gpa_hk1: ((Number(g.midterm_score_k1) + Number(g.final_score_k1)) / 2).toFixed(2),
        gpa_hk2: ((Number(g.midterm_score_k2) + Number(g.final_score_k2)) / 2).toFixed(2)
    }));

    return {
        child_id: childId,
        grades: formattedGrades
    };
}

    /**
     * 3. Cập nhật điểm số (Chỉ cho phép sửa, không cần nhập tên bài thi)
     */
    async updateExistingGrade(id: string, data: Partial<IGrade>) {
        // Kiểm tra các đầu điểm gửi lên phải từ 0-10
        const scoresToValidate = [
            data.midterm_score_k1, 
            data.final_score_k1, 
            data.midterm_score_k2, 
            data.final_score_k2
        ];

        for (const score of scoresToValidate) {
            if (score !== undefined && (score < 0 || score > 10)) {
                throw new Error('Điểm số không hợp lệ. Phải nằm trong khoảng từ 0 đến 10');
            }
        }

        const updated = await GradeModel.update(id, data);
        if (!updated) {
            throw new Error('Không tìm thấy bản ghi điểm để cập nhật');
        }

        return updated;
    }

    /**
     * 4. Lấy danh sách điểm cả lớp cho giáo viên
     */
    async getClassGrades(classId: number) {
        const rawData = await GradeModel.findByClass(classId);
        
        return rawData.map((student: any) => ({
            ...student,
            gpa_hk1: this.calculateAverage(student.midterm_score_k1, student.final_score_k1),
            gpa_hk2: this.calculateAverage(student.midterm_score_k2, student.final_score_k2)
        }));
    }

    /**
     * Hàm phụ: Tính trung bình cộng (Giả định hệ số 1:1)
     */
    private calculateAverage(midterm: number, final: number) {
        const m = Number(midterm) || 0;
        const f = Number(final) || 0;
        return ((m + f) / 2).toFixed(2);
    }

    async exportToExcel(classId: number) {
        const grades = await this.getClassGrades(classId);
        return await ExcelService.exportGrades(grades);
    }

    async importFromExcel(buffer: Buffer, class_id: number, teacher_id: string) {
        const gradesData = await ExcelService.importGrades(buffer, class_id, teacher_id);
        const results = [];

        for (const data of gradesData) {
            if (data.id) {
                const updated = await this.updateExistingGrade(data.id.toString(), data);
                results.push(updated);
            } else {
                const newGrade = await this.addGrade(data as IGrade);
                results.push(newGrade);
            }
        }
        return results;
    }
}

export default new GradeService();