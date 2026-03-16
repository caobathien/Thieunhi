export interface ITermSummary {
    id?: number;
    child_id: string;
    class_id: number;
    academic_year: string;
    term: 'HK1' | 'HK2' | 'Cả Năm';
    avg_score?: number;
    rank_in_class?: number;
    attendance_count?: number;
    absence_count?: number;
    conduct_grade?: string;
    final_result?: string;
    teacher_remarks?: string;
    is_locked?: boolean;
    updated_at?: Date;
}