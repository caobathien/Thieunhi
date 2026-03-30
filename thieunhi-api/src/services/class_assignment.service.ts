    import ClassAssignmentModel from '../models/class_assignment';
    import { IClassAssignment } from '../interfaces/class_assignment';
    import ExcelJS from 'exceljs';

    class ClassAssignmentService {
        // 1. Phân công Giáo lý viên/Huynh trưởng vào lớp
        async assignLeaderToClass(data: IClassAssignment) {
            // Kiểm tra định dạng niên học (YYYY-YYYY)
            const yearRegex = /^\d{4}-\d{4}$/;
            if (!yearRegex.test(data.academic_year)) {
                throw new Error('Niên học không đúng định dạng YYYY-YYYY (VD: 2025-2026)');
            }

            // Kiểm tra vai trò phân công
            const validRoles = ['Trưởng lớp', 'Phụ tá 1', 'Phụ tá 2', 'Phụ tá 3'];
            if (data.assignment_role && !validRoles.includes(data.assignment_role)) {
                // Bạn có thể tùy chỉnh danh sách vai trò này theo quy định của nhà thờ
                console.warn(`Cảnh báo: Vai trò '${data.assignment_role}' nằm ngoài danh mục chuẩn.`);
            }

            // Gọi Model thực hiện (Model của bạn đã có sẵn logic kiểm tra trùng lớp)
            return await ClassAssignmentModel.create(data);
        }

        // 2. Lấy danh sách phân công theo lớp và niên khóa
        async getAssignmentsByClass(classId: number, academicYear: string) {
            if (!classId || !academicYear) {
                throw new Error('Thiếu thông tin lớp học hoặc niên khóa');
            }

            const leaders = await ClassAssignmentModel.findByClass(classId, academicYear);
            return leaders;
        }

        // 3. Lấy tất cả phân công (kèm info lớp và leader)
        async getAssignments(academicYear: string) {
            if (!academicYear) {
                throw new Error('Thiếu thông tin niên khóa');
            }
            return await ClassAssignmentModel.findAll(academicYear);
        }

        // 4. Gỡ phân công
        async removeAssignment(id: number) {
            const isDeleted = await ClassAssignmentModel.delete(id);
            
            if (!isDeleted) {
                throw new Error('Không tìm thấy bản ghi phân công để gỡ bỏ');
            }
            
            return true;
        }

        async getAssignmentDetail(id: number) {
            const assignment = await ClassAssignmentModel.findById(id);
            if (!assignment) {
                throw new Error('Không tìm thấy bản ghi phân công');
            }
            return assignment;
        }
        async exportAssignmentsToExcel(classId: number, academicYear: string) {
            const leaders = await ClassAssignmentModel.findByClass(classId, academicYear);
            
            if (!leaders || leaders.length === 0) {
                throw new Error('Không có dữ liệu để xuất file');
            }

            const workbook = new ExcelJS.Workbook();
            const worksheet = workbook.addWorksheet('Danh sách Phân công');

            // Định dạng tiêu đề cột
            worksheet.columns = [
                { header: 'STT', key: 'stt', width: 5 },
                { header: 'Tên Thánh', key: 'christian_name', width: 15 },
                { header: 'Họ và Tên', key: 'full_name', width: 25 },
                { header: 'Vai trò', key: 'assignment_role', width: 15 },
                { header: 'Số điện thoại', key: 'phone', width: 15 },
                { header: 'Niên học', key: 'academic_year', width: 15 }
            ];

            // Thêm dữ liệu vào bảng
            leaders.forEach((leader, index) => {
                worksheet.addRow({
                    stt: index + 1,
                    christian_name: leader.christian_name || '',
                    full_name: leader.full_name,
                    assignment_role: leader.assignment_role,
                    phone: leader.phone || '',
                    academic_year: leader.academic_year
                });
            });

            // Định dạng header (in đậm, nền xám)
            worksheet.getRow(1).font = { bold: true };
            worksheet.getRow(1).alignment = { vertical: 'middle', horizontal: 'center' };

            return workbook;
        }
    }

    export default new ClassAssignmentService();