import ExcelJS from 'exceljs';
import { IChild } from '../interfaces/child';
import { IGrade } from '../interfaces/grade';

class ExcelService {
    async exportChildren(children: any[]): Promise<Buffer> {
        const workbook = new ExcelJS.Workbook();
        const worksheet = workbook.addWorksheet('Students');

        worksheet.columns = [
            { header: 'ID', key: 'id', width: 10 },
            { header: 'Class ID', key: 'class_id', width: 10 },
            { header: 'Tên Thánh', key: 'baptismal_name', width: 15 },
            { header: 'Họ', key: 'last_name', width: 20 },
            { header: 'Tên', key: 'first_name', width: 15 },
            { header: 'Ngày sinh', key: 'birth_date', width: 15 },
            { header: 'Giới tính', key: 'gender', width: 10 },
            { header: 'Địa chỉ', key: 'address', width: 30 },
            { header: 'Tên Thánh Bố', key: 'ten_thanh_bo', width: 15 },
            { header: 'Họ và tên Bố', key: 'ho_va_ten_bo', width: 20 },
            { header: 'SĐT Bố', key: 'sdt_bo', width: 15 },
            { header: 'Tên Thánh Mẹ', key: 'ten_thanh_me', width: 15 },
            { header: 'Họ và tên Mẹ', key: 'ho_va_ten_me', width: 20 },
            { header: 'SĐT Mẹ', key: 'sdt_me', width: 15 },
            { header: 'Trạng thái', key: 'status', width: 10 },
        ];

        children.forEach(child => {
            worksheet.addRow(child);
        });

        return await workbook.xlsx.writeBuffer() as any as Buffer;
    }

    async importChildren(buffer: Buffer): Promise<Partial<IChild>[]> {
        const workbook = new ExcelJS.Workbook();
        await workbook.xlsx.load(buffer as any);
        const worksheet = workbook.getWorksheet(1);
        const children: Partial<IChild>[] = [];

        worksheet?.eachRow((row, rowNumber) => {
            if (rowNumber === 1) return; // Skip header

            const child: any = {
                id: row.getCell(1).value?.toString(),
                class_id: Number(row.getCell(2).value),
                baptismal_name: row.getCell(3).value?.toString(),
                last_name: row.getCell(4).value?.toString(),
                first_name: row.getCell(5).value?.toString(),
                birth_date: row.getCell(6).value ? new Date(row.getCell(6).value as any) : undefined,
                gender: row.getCell(7).value?.toString(),
                address: row.getCell(8).value?.toString(),
                ten_thanh_bo: row.getCell(9).value?.toString(),
                ho_va_ten_bo: row.getCell(10).value?.toString(),
                sdt_bo: row.getCell(11).value?.toString(),
                ten_thanh_me: row.getCell(12).value?.toString(),
                ho_va_ten_me: row.getCell(13).value?.toString(),
                sdt_me: row.getCell(14).value?.toString(),
                status: row.getCell(15).value?.toString() || 'active',
            };
            children.push(child);
        });

        return children;
    }

    async exportGrades(grades: any[]): Promise<Buffer> {
        const workbook = new ExcelJS.Workbook();
        const worksheet = workbook.addWorksheet('Grades');

        worksheet.columns = [
            { header: 'Grade ID', key: 'grade_id', width: 10 },
            { header: 'Child ID', key: 'child_id', width: 10 },
            { header: 'Tên Thánh', key: 'baptismal_name', width: 15 },
            { header: 'Họ và tên', key: 'full_name', width: 25 },
            { header: 'GK K1', key: 'midterm_score_k1', width: 10 },
            { header: 'CK K1', key: 'final_score_k1', width: 10 },
            { header: 'GK K2', key: 'midterm_score_k2', width: 10 },
            { header: 'CK K2', key: 'final_score_k2', width: 10 },
            { header: 'Niên học', key: 'academic_year', width: 15 },
            { header: 'Ghi chú', key: 'remarks', width: 30 },
        ];

        grades.forEach(grade => {
            worksheet.addRow({
                ...grade,
                full_name: `${grade.last_name || ''} ${grade.first_name || ''}`.trim()
            });
        });

        return await workbook.xlsx.writeBuffer() as any as Buffer;
    }

    async importGrades(buffer: Buffer, class_id: number, teacher_id: string): Promise<Partial<IGrade>[]> {
        const workbook = new ExcelJS.Workbook();
        await workbook.xlsx.load(buffer as any);
        const worksheet = workbook.getWorksheet(1);
        const grades: Partial<IGrade>[] = [];

        worksheet?.eachRow((row, rowNumber) => {
            if (rowNumber === 1) return; // Skip header

            const grade: any = {
                id: row.getCell(1).value ? Number(row.getCell(1).value) : undefined,
                child_id: row.getCell(2).value?.toString(),
                class_id: class_id,
                teacher_id: teacher_id,
                midterm_score_k1: Number(row.getCell(5).value || 0),
                final_score_k1: Number(row.getCell(6).value || 0),
                midterm_score_k2: Number(row.getCell(7).value || 0),
                final_score_k2: Number(row.getCell(8).value || 0),
                academic_year: row.getCell(9).value?.toString() || '2024-2025',
                remarks: row.getCell(10).value?.toString(),
            };
            grades.push(grade);
        });

        return grades;
    }
}

export default new ExcelService();
