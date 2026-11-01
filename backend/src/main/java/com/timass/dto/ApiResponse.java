package com.timass.dto;

public class ApiResponse<T> {
    private int maTrangThai; // 200, 400, 401, 403, 500
    private String thongBao;
    private T duLieu;

    public ApiResponse() {
    }

    public ApiResponse(int maTrangThai, String thongBao, T duLieu) {
        this.maTrangThai = maTrangThai;
        this.thongBao = thongBao;
        this.duLieu = duLieu;
    }

    public static <T> ApiResponse<T> thanhCong(T duLieu, String thongBao) {
        return new ApiResponse<>(200, thongBao, duLieu);
    }

    public static <T> ApiResponse<T> thanhCong(T duLieu) {
        return thanhCong(duLieu, "Thành công");
    }

    public static <T> ApiResponse<T> thatBai(int maTrangThai, String thongBao) {
        return new ApiResponse<>(maTrangThai, thongBao, null);
    }

    public int getMaTrangThai() {
        return maTrangThai;
    }

    public void setMaTrangThai(int maTrangThai) {
        this.maTrangThai = maTrangThai;
    }

    public String getThongBao() {
        return thongBao;
    }

    public void setThongBao(String thongBao) {
        this.thongBao = thongBao;
    }

    public T getDuLieu() {
        return duLieu;
    }

    public void setDuLieu(T duLieu) {
        this.duLieu = duLieu;
    }
}
