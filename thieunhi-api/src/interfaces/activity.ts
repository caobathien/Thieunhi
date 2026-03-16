export interface IActivity {
    id?: number;
    title: string;
    summary: string;
    content: string;
    image_url?: string;
    start_time?: Date;
    location?: string;
    is_featured: boolean;
    is_public: boolean;
    priority: number;
    created_at?: Date;
}