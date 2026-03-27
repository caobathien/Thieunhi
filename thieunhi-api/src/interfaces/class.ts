export interface IClass {
    id?: number;
    class_name: string;
    room_number?: string;
    academic_year: string;
    academic_year_id?: number; // Liên kết tới bảng academic_years
    total_capacity?: number;
    main_leader_id?: string; // UUID của Huynh trưởng
    status: 'active' | 'inactive' | 'closed';
    description?: string;
    created_at?: Date;
}