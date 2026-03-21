import AttendanceModel from '../models/attendance';
import pool from '../config/database';
import { IAttendance } from '../interfaces/attendance';
import NotificationService from './notification.service';
import ClassAssignmentModel from '../models/class_assignment';

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

        const result = await AttendanceModel.markAttendance(attendanceData);
        
        // 4. Kiểm tra vắng mặt liên tiếp (chỉ khi có mặt mới reset vắng, nhưng ở đây đang mark "Có mặt")
        // Nếu em này vừa được quét QR tức là có mặt, không cần check vắng.
        
        return result;
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
        const isAbsent = data.status.includes('Vắng');
        const attendanceData: IAttendance = {
            ...data,
            // Nếu status là 'Vắng...' thì is_present = false, ngược lại true
            is_present: !isAbsent,
            marked_by
        };
        // data.attendance_date sẽ tự động đi vào nhờ toán tử spread (nếu có truyền từ Client)
        const result = await AttendanceModel.markAttendance(attendanceData);

        // Nếu là vắng mặt, kiểm tra xem có vắng liên tiếp không
        if (isAbsent) {
            this.checkAndNotifyAbsences(attendanceData.child_id, attendanceData.class_id);
        }

        return result;
    }

    private async checkAndNotifyAbsences(childId: any, classId: number) {
        try {
            // 1. Kiểm tra 3 buổi gần nhất
            const recentAbsences = await AttendanceModel.getConsecutiveAbsences(childId, classId, 3);
            
            // Nếu đủ 3 bản ghi và tất cả đều vắng
            if (recentAbsences.length === 3 && recentAbsences.every((a: any) => !a.is_present)) {
                // 2. Xác định niên khóa
                const academicYear = this.getAcademicYear();

                // 3. Lấy thông tin GV/HT của lớp
                const leaders = await ClassAssignmentModel.findByClass(classId, academicYear);

                // 4. Lấy thông tin chi tiết thiếu nhi và lớp
                const childInfoResult = await pool.query(`
                    SELECT c.id, c.first_name, c.last_name, c.baptismal_name, cl.class_name 
                    FROM children c
                    JOIN classes cl ON c.class_id = cl.id
                    WHERE c.id = $1
                `, [childId]);
                
                if (childInfoResult.rows.length > 0) {
                    const childInfo = childInfoResult.rows[0];
                    const absenteeDates = recentAbsences.map((a: any) => 
                        new Date(a.attendance_date).toLocaleDateString('vi-VN')
                    );

                    // 5. Gửi thông báo Email
                    await NotificationService.sendAbsenteeAlert(leaders, childInfo, absenteeDates);
                }
            }
        } catch (error) {
            console.error('❌ Lỗi trong quá trình kiểm tra vắng học liên tiếp:', error);
        }
    }

    private getAcademicYear(): string {
        const now = new Date();
        const year = now.getFullYear();
        const month = now.getMonth() + 1;

        if (month >= 8) { // Bắt đầu từ tháng 8 hoặc 9
            return `${year}-${year + 1}`;
        } else {
            return `${year - 1}-${year}`;
        }
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