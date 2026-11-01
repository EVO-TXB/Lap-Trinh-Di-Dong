package com.timass.repository;

import com.timass.entity.NguoiDung;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface NguoiDungRepository extends JpaRepository<NguoiDung, Long> {

    Optional<NguoiDung> findBySoDienThoai(String soDienThoai);

    boolean existsBySoDienThoai(String soDienThoai);
}

