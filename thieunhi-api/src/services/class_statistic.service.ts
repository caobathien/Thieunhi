import ExcelJS from 'exceljs';
import ClassStatisticModel from '../models/class_statistic';

class ClassStatisticService {
    /**
     * Đồng bộ và tính toán thống kê cho lớp học
     * Thường được gọi sau khi kết thúc một học kỳ hoặc năm học
     */
    async syncClassStatistics(classId: number, term: string, academicYear: string) {
        // 1. Kiểm tra đầu vào
        if (!classId || !term || !academicYear) {
            throw new Error('Thiếu thông tin lớp, học kỳ hoặc niên học để tính toán thống kê');
        }

        // 2. Kiểm tra định dạng niên học (YYYY-YYYY)
        const yearRegex = /^\d{4}-\d{4}$/;
        if (!yearRegex.test(academicYear)) {
            throw new Error('Niên học không đúng định dạng YYYY-YYYY');
        }

        // 3. Gọi Model để thực hiện tính toán (Upsert logic)
        const stats = await ClassStatisticModel.calculateClassStat(classId, term, academicYear);

        // 4. Bổ sung logic nhận xét tự động dựa trên kết quả
        let feedback = "";
        if (stats.average_attendance_rate > 90) {
            feedback = "Tỷ lệ chuyên cần rất tốt.";
        } else if (stats.average_attendance_rate < 70) {
            feedback = "Cần lưu ý nhắc nhở các em đi học đầy đủ hơn.";
        }

        return {
            ...stats,
            system_feedback: feedback
        };
    }

    /**
     * Lấy lịch sử thống kê của một lớp để xem sự tiến bộ
     */
    async getClassPerformanceHistory(classId: number) {
        const history = await ClassStatisticModel.getClassHistory(classId);
        
        if (!history || history.length === 0) {
            throw new Error('Chưa có dữ liệu thống kê cho lớp này');
        }

        return history;
    }

    /**
     * So sánh hiệu quả giữa các học kỳ (Ví dụ: HK1 vs HK2)
     */
    async compareTerms(classId: number, academicYear: string) {
        const history = await ClassStatisticModel.getClassHistory(classId);
        const yearStats = history.filter(h => h.academic_year === academicYear);
        
        if (yearStats.length < 2) {
            return { message: "Cần dữ liệu của ít nhất 2 học kỳ để so sánh" };
        }

        return {
            year: academicYear,
            stats: yearStats
        };
    }
    async exportStatisticsExcel(classId: number) {
        const history = await ClassStatisticModel.getClassHistory(classId);
        
        if (!history || history.length === 0) {
            throw new Error('Không có dữ liệu thống kê để xuất file');
        }

        const workbook = new ExcelJS.Workbook();
        const worksheet = workbook.addWorksheet('Thống kê lớp học');

        // 1. Định dạng tiêu đề cột
        worksheet.columns = [
            { header: 'Niên học', key: 'academic_year', width: 15 },
            { header: 'Học kỳ', key: 'term', width: 10 },
            { header: 'Sỹ số', key: 'total_students', width: 10 },
            { header: 'ĐTB Lớp', key: 'class_gpa', width: 12 },
            { header: 'Học sinh Giỏi', key: 'excellence_count', width: 15 },
            { header: 'Học sinh Yếu', key: 'weak_students_count', width: 15 },
            { header: 'Tỷ lệ chuyên cần (%)', key: 'average_attendance_rate', width: 20 },
            { header: 'Cập nhật cuối', key: 'last_updated', width: 20 }
        ];

        // 2. Thêm dữ liệu vào các dòng
        history.forEach(stat => {
            worksheet.addRow({
                academic_year: stat.academic_year,
                term: stat.term,
                total_students: stat.total_students,
                class_gpa: Number(stat.class_gpa).toFixed(2),
                excellence_count: stat.excellence_count,
                weak_students_count: stat.weak_students_count,
                average_attendance_rate: `${Number(stat.average_attendance_rate).toFixed(1)}%`,
                last_updated: new Date(stat.last_updated).toLocaleString('vi-VN')
            });
        });

        // 3. Định dạng Header (In đậm, màu nền)
        worksheet.getRow(1).eachCell((cell) => {
            cell.font = { bold: true, color: { argb: 'FFFFFFFF' } };
            cell.fill = {
                type: 'pattern',
                pattern: 'solid',
                fgColor: { argb: 'FF4F81BD' } // Màu xanh dương đậm
            };
            cell.alignment = { horizontal: 'center' };
        });

        // 4. Kẻ bảng (Borders) cho tất cả các ô có dữ liệu
        worksheet.eachRow((row) => {
            row.eachCell((cell) => {
                cell.border = {
                    top: { style: 'thin' },
                    left: { style: 'thin' },
                    bottom: { style: 'thin' },
                    right: { style: 'thin' }
                };
            });
        });

        return workbook;
    }
}

export default new ClassStatisticService();