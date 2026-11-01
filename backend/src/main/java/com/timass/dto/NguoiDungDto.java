package com.timass.dto;

import java.time.LocalDateTime;

public class NguoiDungDto {

    private Long id;
    private String soDienThoai;
    private String hoTen;
    private LocalDateTime ngayTao;

    public NguoiDungDto() {
    }

    public NguoiDungDto(Long id, String soDienThoai, String hoTen, LocalDateTime ngayTao) {
        this.id = id;
        this.soDienThoai = soDienThoai;
        this.hoTen = hoTen;
        this.ngayTao = ngayTao;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getSoDienThoai() {
        return soDienThoai;
    }

    public void setSoDienThoai(String soDienThoai) {
        this.soDienThoai = soDienThoai;
    }

    public String getHoTen() {
        return hoTen;
    }

    public void setHoTen(String hoTen) {
        this.hoTen = hoTen;
    }

    public LocalDateTime getNgayTao() {
        return ngayTao;
    }

    public void setNgayTao(LocalDateTime ngayTao) {
        this.ngayTao = ngayTao;
    }
}

