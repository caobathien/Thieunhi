export interface IChild {
    id?: string;
    class_id?: number;
    first_name: string;      // Thay cho full_name
    last_name: string;       // Thay cho full_name
    baptismal_name?: string;
    birth_date?: Date;
    gender?: string;
    avatar_url?: string;
    address?: string;
    ten_thanh_bo?: string;   // Khớp DB
    ho_va_ten_bo?: string;   // Khớp DB
    sdt_bo?: string;         // Khớp DB
    ten_thanh_me?: string;   // Khớp DB
    ho_va_ten_me?: string;   // Khớp DB
    sdt_me?: string;         // Khớp DB
    emergency_phone?: string;
    ma_qr?: string;          // Khớp DB (trong ảnh là ma_qr, không phải maqr)
    status?: string;
    join_date?: Date;
    notes?: string;
}