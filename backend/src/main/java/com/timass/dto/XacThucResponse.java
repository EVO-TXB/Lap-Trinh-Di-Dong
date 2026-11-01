package com.timass.dto;

public class XacThucResponse {

    private String token;
    private String loaiToken = "Bearer";
    private long thoiGianHetHan; // Tinh bang giay (86400s = 24h)
    private NguoiDungDto nguoiDung;

    public XacThucResponse() {
    }

    public XacThucResponse(String token, String loaiToken, long thoiGianHetHan, NguoiDungDto nguoiDung) {
        this.token = token;
        this.loaiToken = loaiToken;
        this.thoiGianHetHan = thoiGianHetHan;
        this.nguoiDung = nguoiDung;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public String getLoaiToken() {
        return loaiToken;
    }

    public void setLoaiToken(String loaiToken) {
        this.loaiToken = loaiToken;
    }

    public long getThoiGianHetHan() {
        return thoiGianHetHan;
    }

    public void setThoiGianHetHan(long thoiGianHetHan) {
        this.thoiGianHetHan = thoiGianHetHan;
    }

    public NguoiDungDto getNguoiDung() {
        return nguoiDung;
    }

    public void setNguoiDung(NguoiDungDto nguoiDung) {
        this.nguoiDung = nguoiDung;
    }
}

