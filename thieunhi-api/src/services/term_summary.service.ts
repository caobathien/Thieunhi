import TermSummaryModel from '../models/term_summary';
import { ITermSummary } from '../interfaces/term_summary';

class TermSummaryService {
    async generateSummary(data: { class_id: number; term: string; academic_year: string }) {
        const { class_id, term, academic_year } = data;

        // 1. Gọi Model để chạy vòng lặp tính toán (Học tập + Điểm danh) / 2
        const classSummaries = await TermSummaryModel.calculateClassSummary(class_id, term, academic_year);

        // 2. Xếp loại dựa trên điểm tổng đã chia 2
        const finalResults = [];
        for (const summary of classSummaries) {
            const final_result = this.determineAcademicRank(summary.avg_score);
            
            // Cập nhật xếp loại vào DB
            const updated = await TermSummaryModel.updateManualInfo(summary.id, { final_result });
            finalResults.push(updated);
        }

        return finalResults;
    }

    private determineAcademicRank(gpa: number): string {
        const score = Number(gpa);
        if (score >= 9.0) return 'Xuất sắc';
        if (score >= 8.0) return 'Giỏi';
        if (score >= 6.5) return 'Khá';
        if (score >= 5.0) return 'Trung bình';
        return 'Yếu';
    }

    /**
     * 2. Lấy dữ liệu tổng kết cá nhân kèm nhận xét hệ thống
     */
    async getStudentFullSummary(childId: string, year: string) {
        const summaries = await TermSummaryModel.findSummary(childId, year);
        const absenceDates = await TermSummaryModel.getAbsenceDates(childId, year);
        
        if (!summaries || summaries.length === 0) {
            throw new Error('Chưa có dữ liệu tổng kết cho thiếu nhi này trong năm học được chọn');
        }

        const formattedSummaries = summaries.map(s => ({
            ...s,
            attendance_rate: s.attendance_count > 0 
                ? `${((s.attendance_count / (s.attendance_count + s.absence_count)) * 100).toFixed(1)}%`
                : '0%'
        }));
    }

    /**
     * 3. Huynh trưởng cập nhật lời phê và hạnh kiểm
     */
    async updateTeacherEvaluations(id: number, evaluationData: Partial<ITermSummary>) {
        // Kiểm tra nếu bản ghi đã bị khóa (đã chốt sổ) thì không cho sửa
        const existing = await TermSummaryModel.updateManualInfo(id, {}); // Lấy dữ liệu hiện tại
        if (existing?.is_locked) {
            throw new Error('Bản ghi tổng kết này đã bị khóa, không thể chỉnh sửa lời phê');
        }

        return await TermSummaryModel.updateManualInfo(id, evaluationData);
    }

    async getClassFullSummary(classId: number, year: string, term: string) {
    // 1. Lấy dữ liệu tổng kết từ Model (đã lọc theo term)
    const summaries = await TermSummaryModel.findSummariesWithStudentInfo(classId, year, term);
    
    if (!summaries || summaries.length === 0) {
        throw new Error('Chưa có dữ liệu tổng kết cho lớp này trong năm học được chọn');
    }

    // 2. Format lại dữ liệu để hiển thị
    return summaries.map(s => ({
        ...s,
        child_id: s.child_id,
        first_name: s.first_name,
        last_name: s.last_name,
        full_name: `${s.last_name || ''} ${s.first_name || ''}`.trim(),
        baptismal_name: s.baptismal_name,
        term: s.term || 'Chưa có',
        avg_score: s.avg_score || '0.00',
        final_result: s.final_result || 'Chưa xét',
        conduct_grade: s.conduct_grade || '---',
        attendance_count: s.attendance_count || 0,
        absence_count: s.absence_count || 0,
        // Giữ lại các đầu điểm chi tiết từ Model
        midterm_score_k1: s.midterm_score_k1,
        final_score_k1: s.final_score_k1,
        midterm_score_k2: s.midterm_score_k2,
        final_score_k2: s.final_score_k2,
        attendance_rate: s.attendance_count > 0 
            ? `${((Number(s.attendance_count) / (Number(s.attendance_count) + Number(s.absence_count))) * 100).toFixed(1)}%`
            : '0%'
    }));
}
}

export default new TermSummaryService();