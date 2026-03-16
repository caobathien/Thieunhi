export interface IFeedback {
    id?: number;
    user_id: string;
    class_id?: number;
    title: string;
    content: string;
    rating: number; // 1-5
    category: 'Học tập' | 'Cơ sở vật chất' | 'Sự kiện' | 'Góp ý chung';
    image_url?: string;
    status: 'pending' | 'processing' | 'resolved';
    admin_note?: string;
    is_anonymous: boolean;
    created_at?: Date;
}