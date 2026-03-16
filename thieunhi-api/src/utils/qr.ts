import QRCode from 'qrcode';

export const generateQRCode = async (text: string): Promise<string> => {
    try {
        // Trả về chuỗi Base64 để App Mobile có thể hiển thị trực tiếp trong thẻ Image
        const qrImage = await QRCode.toDataURL(text);
        return qrImage;
    } catch (err) {
        console.error('Lỗi tạo mã QR:', err);
        throw new Error('Không thể tạo mã QR');
    }
};