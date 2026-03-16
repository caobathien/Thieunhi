export interface IClass {
    id?: number;
    class_name: string;
    room_number?: string;
    academic_year: string;
    total_capacity?: number;
    main_leader_id?: string; // UUID của Huynh trưởng
    status: 'active' | 'inactive' | 'closed';
    description?: string;
    created_at?: Date;
}