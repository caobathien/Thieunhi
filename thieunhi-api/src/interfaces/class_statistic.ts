export interface IClassStatistic {
    id?: number;
    class_id: number;
    academic_year: string;
    term: string;
    total_students: number;
    class_gpa: number;
    excellence_count: number;
    weak_students_count: number;
    average_attendance_rate: number;
    rank_in_block?: number;
    last_updated?: Date;
}