package com.example.map.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.example.map.entity.Place;

public interface JpaPlaceRepository extends JpaRepository<Place, Long> {
//	SELECT DISTINCT p FROM Place p JOIN p.user u WHERE u.userId = :userId  AND ROWNUM < 6 ORDER BY p.createDate DESC
	@Query(value = "SELECT  p.* "
			+ "FROM (SELECT ROW_NUMBER() OVER (PARTITION BY place.place_id ORDER BY place.create_date DESC ) "
			+ "AS R, place.* FROM place WHERE place.user_id = :userId)  p"
			+ " WHERE R = 1 AND ROWNUM < 6 ORDER BY p.create_date DESC, p.id DESC", nativeQuery = true)
	public List<Place> findAllByUserId(@Param("userId") Long userId);
}
