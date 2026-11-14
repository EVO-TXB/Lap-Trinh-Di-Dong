package com.timass.repository;

import com.timass.entity.QuyTacLap;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface QuyTacLapRepository extends JpaRepository<QuyTacLap, Long> {

    List<QuyTacLap> findByNguoiDungId(Long maNguoiDung);
}

