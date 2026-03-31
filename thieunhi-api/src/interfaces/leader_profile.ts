export interface ILeaderProfile {
    id?: number;
    user_id: string; // UUID liên kết với bảng users
    christian_name: string;
    full_name?: string;
    phone?: string;
    gmail?: string;
    birth_date?: string;
    rank: string;      // Cấp bậc: Dự trưởng, Cấp 1, 2, 3...
    position: string;  // Chức vụ: Trưởng khối, Thư ký, GLV...
    join_date?: string;
    status: 'Đang công tác' | 'Tạm nghỉ' | 'Nghỉ hẳn';
    avatar_url?: string;
    award_notes?: string;
    notes?: string;
    assigned_class?: string;
    assigned_class_id?: number;
}