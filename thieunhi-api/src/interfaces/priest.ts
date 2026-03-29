export interface IPriest {
    id?: number;
    christian_name: string;
    full_name: string;
    birth_date?: Date | string;
    ordination_date?: Date | string;
    appointment_date?: Date | string;
    image_url?: string;
    favorite_verse?: string;
    created_at?: Date;
    updated_at?: Date;
}
