export interface IUser {
    id?: string; // UUID
    username: string;
    password_hash: string;
    full_name?: string;
    gmail?: string;
    phone?: string;
    role: 'admin' | 'leader' | 'teacher' | 'user';
    avatar_url?: string;
    is_active?: boolean;
    status?: 'active' | 'locked' | 'pending';
    lock_reason?: string;
    locked_at?: Date;
    login_attempts?: number;
    last_login?: Date;
    reset_password_token?: string;
    token_expires_at?: Date;
    created_at?: Date;
    notes?: string;
}