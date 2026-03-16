export interface IGrade {
    id?: number;
    child_id: string;
    class_id: number;
    teacher_id: string;
    
    // Các đầu điểm cố định (Mặc định khi khởi tạo nên là 0)
    midterm_score_k1: number; 
    final_score_k1: number;   
    midterm_score_k2: number; 
    final_score_k2: number;   

    academic_year: string;
    remarks?: string;
    created_at?: Date;
    updated_at?: Date;
}