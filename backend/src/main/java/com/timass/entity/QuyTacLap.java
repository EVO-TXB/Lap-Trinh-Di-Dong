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
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(
    name = "quy_tac_lap",
    indexes = {
        @Index(name = "idx_quy_tac_lap_ma_nguoi_dung", columnList = "ma_nguoi_dung")
    }
)
public class QuyTacLap {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ma_nguoi_dung", nullable = false)
    private NguoiDung nguoiDung;

    @Column(name = "ten_cong_viec", nullable = false, length = 255)
    private String tenCongViec;

    @Column(name = "la_thiet_yeu", nullable = false)
    private Boolean laThietYeu = false;

    @Column(name = "gio_bat_dau", nullable = false)
    private LocalTime gioBatDau;

    @Column(name = "gio_ket_thuc", nullable = false)
    private LocalTime gioKetThuc;

    @Column(name = "dia_diem", length = 255)
    private String diaDiem;

    @Column(name = "cac_ngay_trong_tuan", nullable = false, length = 50)
    private String cacNgayTrongTuan; // Ví dụ: "2,4,6"

    @Column(name = "ngay_bat_dau", nullable = false)
    private LocalDate ngayBatDau;

    @Column(name = "ngay_ket_thuc", nullable = false)
    private LocalDate ngayKetThuc;

    @Column(name = "nhac_nho_truoc_phut", nullable = false)
    private Integer nhacNhoTruocPhut = 15;

    @Column(name = "ngay_tao", nullable = false, updatable = false)
    private LocalDateTime ngayTao;

    @JsonIgnore
    @OneToMany(mappedBy = "quyTacLap", cascade = CascadeType.ALL, orphanRemoval = false, fetch = FetchType.LAZY)
    private List<CongViec> danhSachCongViec = new ArrayList<>();

    public QuyTacLap() {
    }

    public QuyTacLap(Long id, NguoiDung nguoiDung, String tenCongViec, Boolean laThietYeu,
                     LocalTime gioBatDau, LocalTime gioKetThuc, String diaDiem,
                     String cacNgayTrongTuan, LocalDate ngayBatDau, LocalDate ngayKetThuc,
                     Integer nhacNhoTruocPhut, LocalDateTime ngayTao) {
        this.id = id;
        this.nguoiDung = nguoiDung;
        this.tenCongViec = tenCongViec;
        this.laThietYeu = laThietYeu != null ? laThietYeu : false;
        this.gioBatDau = gioBatDau;
        this.gioKetThuc = gioKetThuc;
        this.diaDiem = diaDiem;
        this.cacNgayTrongTuan = cacNgayTrongTuan;
        this.ngayBatDau = ngayBatDau;
        this.ngayKetThuc = ngayKetThuc;
        this.nhacNhoTruocPhut = nhacNhoTruocPhut != null ? nhacNhoTruocPhut : 15;
        this.ngayTao = ngayTao;
    }

    @PrePersist
    public void prePersist() {
        if (this.ngayTao == null) {
            this.ngayTao = LocalDateTime.now();
        }
        if (this.laThietYeu == null) {
            this.laThietYeu = false;
        }
        if (this.nhacNhoTruocPhut == null) {
            this.nhacNhoTruocPhut = 15;
        }
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public NguoiDung getNguoiDung() {
        return nguoiDung;
    }

    public void setNguoiDung(NguoiDung nguoiDung) {
        this.nguoiDung = nguoiDung;
    }

    public String getTenCongViec() {
        return tenCongViec;
    }

    public void setTenCongViec(String tenCongViec) {
        this.tenCongViec = tenCongViec;
    }

    public Boolean getLaThietYeu() {
        return laThietYeu;
    }

    public void setLaThietYeu(Boolean laThietYeu) {
        this.laThietYeu = laThietYeu;
    }

    public LocalTime getGioBatDau() {
        return gioBatDau;
    }

    public void setGioBatDau(LocalTime gioBatDau) {
        this.gioBatDau = gioBatDau;
    }

    public LocalTime getGioKetThuc() {
        return gioKetThuc;
    }

    public void setGioKetThuc(LocalTime gioKetThuc) {
        this.gioKetThuc = gioKetThuc;
    }

    public String getDiaDiem() {
        return diaDiem;
    }

    public void setDiaDiem(String diaDiem) {
        this.diaDiem = diaDiem;
    }

    public String getCacNgayTrongTuan() {
        return cacNgayTrongTuan;
    }

    public void setCacNgayTrongTuan(String cacNgayTrongTuan) {
        this.cacNgayTrongTuan = cacNgayTrongTuan;
    }

    public LocalDate getNgayBatDau() {
        return ngayBatDau;
    }

    public void setNgayBatDau(LocalDate ngayBatDau) {
        this.ngayBatDau = ngayBatDau;
    }

    public LocalDate getNgayKetThuc() {
        return ngayKetThuc;
    }

    public void setNgayKetThuc(LocalDate ngayKetThuc) {
        this.ngayKetThuc = ngayKetThuc;
    }

    public Integer getNhacNhoTruocPhut() {
        return nhacNhoTruocPhut;
    }

    public void setNhacNhoTruocPhut(Integer nhacNhoTruocPhut) {
        this.nhacNhoTruocPhut = nhacNhoTruocPhut;
    }

    public LocalDateTime getNgayTao() {
        return ngayTao;
    }

    public void setNgayTao(LocalDateTime ngayTao) {
        this.ngayTao = ngayTao;
    }

    public List<CongViec> getDanhSachCongViec() {
        return danhSachCongViec;
    }

    public void setDanhSachCongViec(List<CongViec> danhSachCongViec) {
        this.danhSachCongViec = danhSachCongViec;
    }
}
