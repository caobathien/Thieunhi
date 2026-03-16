export interface IClassAssignment {
    id?: number;
    user_id: string;      // UUID của Huynh trưởng
    class_id: number;     // ID của lớp học
    assignment_role: string; // Trưởng lớp, Phụ tá 1, Phụ tá 2...
    academic_year: string;   // Niên học (2025-2026)
    assigned_at?: Date;
}