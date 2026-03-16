import AttendanceModel from '../models/attendance';
import pool from '../config/database';
import { IAttendance } from '../interfaces/attendance';

class AttendanceService {
    async scanQRCode(ma_qr: string, class_id: number, marked_by: string) {
        // 1. Lấy thông tin trẻ em và giờ bắt đầu của lớp
        const infoResult = await pool.query(`
            SELECT c.id as child_id, cl.start_time 
            FROM children c, classes cl 
            WHERE c.ma_qr = $1 AND cl.id = $2
        `, [ma_qr, class_id]);

        if (infoResult.rows.length === 0) {
            throw new Error('Thông tin mã QR hoặc lớp học không chính xác');
        }

        const { child_id, start_time } = infoResult.rows[0];

        // 2. Tính toán trạng thái Muộn/Có mặt
        const status = this.calculateStatus(start_time);

        // 3. Lưu vào DB
        const attendanceData: IAttendance = {
            child_id,
            class_id,
            is_present: true,
            status,
            marked_by
        };

        return await AttendanceModel.markAttendance(attendanceData);
    }

    private calculateStatus(startTimeStr: string): 'Có mặt' | 'Muộn' {
        const now = new Date();
        
        // Chuyển đổi start_time (HH:mm:ss) từ DB thành object Date để so sánh
        const [startHour, startMinute] = startTimeStr.split(':').map(Number);
        const attendanceDeadline = new Date();
        attendanceDeadline.setHours(startHour, startMinute, 0);

        // Cho phép trễ 15 phút
        // attendanceDeadline.setMinutes(attendanceDeadline.getMinutes() + 15);

        return now > attendanceDeadline ? 'Muộn' : 'Có mặt';
    }

    // Điểm danh bằng tay
    async markManual(data: any, marked_by: string) {
        const attendanceData: IAttendance = {
            ...data,
            // Nếu status là 'Vắng...' thì is_present = false, ngược lại true
            is_present: !data.status.includes('Vắng'),
            marked_by
        };
        // data.attendance_date sẽ tự động đi vào nhờ toán tử spread (nếu có truyền từ Client)
        return await AttendanceModel.markAttendance(attendanceData);
    }
    // xem điểm danh theo lớp 
    async getClassReport(classId: number, date?: string) {
        // Nếu không có date, lấy ngày hiện tại (YYYY-MM-DD)
        const reportDate = date || new Date().toISOString().split('T')[0];
        return await AttendanceModel.getClassAttendance(classId, reportDate);
    }
    // lọc theo ngày 
    async getClassReportByDate(classId: number, dateQuery?: string) {
        // Nếu có dateQuery thì dùng, không thì lấy ngày hiện tại định dạng YYYY-MM-DD
        const targetDate = dateQuery || new Date().toISOString().split('T')[0];
        
        return await AttendanceModel.getReportByFilter(classId, targetDate);
    }
    // đanh sách các em điểm danh
    async getManualList(classId: number, date?: string) {
        const targetDate = date || new Date().toISOString().split('T')[0];
        return await AttendanceModel.getStudentListForManual(classId, targetDate);
    }

    // thống kê nhiều ngày
    async getStats(classId: number, startDate: string, endDate: string) {
        return await AttendanceModel.getAttendanceStats(classId, startDate, endDate);
    }
}
export default new AttendanceService();