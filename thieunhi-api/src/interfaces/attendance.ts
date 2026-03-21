export interface IAttendance {
    id?: number;
    child_id: string;
    class_id: number;
    attendance_date?: string | Date;
    check_in_time?: string;
    is_present: boolean;
    status: 'Có mặt' | 'Vắng có phép' | 'Vắng không phép' | 'Muộn';
    reason?: string;
    marked_by: string;
    lesson_topic?: string;
    updated_at?: Date;
}