package com.timass.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.OneToMany;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(
    name = "nguoi_dung",
    indexes = {
        @Index(name = "uk_nguoi_dung_so_dien_thoai", columnList = "so_dien_thoai", unique = true)
    }
)
public class NguoiDung {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "so_dien_thoai", nullable = false, unique = true, length = 20)
    private String soDienThoai;

    @Column(name = "mat_khau", nullable = false, length = 255)
    private String matKhau;

    @Column(name = "ho_ten", length = 100)
    private String hoTen;

    @Column(name = "ngay_tao", nullable = false, updatable = false)
    private LocalDateTime ngayTao;

    @JsonIgnore
    @OneToMany(mappedBy = "nguoiDung", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    private List<QuyTacLap> danhSachQuyTacLap = new ArrayList<>();

    @JsonIgnore
    @OneToMany(mappedBy = "nguoiDung", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    private List<CongViec> danhSachCongViec = new ArrayList<>();

    public NguoiDung() {
    }

    public NguoiDung(Long id, String soDienThoai, String matKhau, String hoTen, LocalDateTime ngayTao) {
        this.id = id;
        this.soDienThoai = soDienThoai;
        this.matKhau = matKhau;
        this.hoTen = hoTen;
        this.ngayTao = ngayTao;
    }

    @PrePersist
    public void prePersist() {
        if (this.ngayTao == null) {
            this.ngayTao = LocalDateTime.now();
        }
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

    public String getMatKhau() {
        return matKhau;
    }

    public void setMatKhau(String matKhau) {
        this.matKhau = matKhau;
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

    public List<QuyTacLap> getDanhSachQuyTacLap() {
        return danhSachQuyTacLap;
    }

    public void setDanhSachQuyTacLap(List<QuyTacLap> danhSachQuyTacLap) {
        this.danhSachQuyTacLap = danhSachQuyTacLap;
    }

    public List<CongViec> getDanhSachCongViec() {
        return danhSachCongViec;
    }

    public void setDanhSachCongViec(List<CongViec> danhSachCongViec) {
        this.danhSachCongViec = danhSachCongViec;
    }
}
