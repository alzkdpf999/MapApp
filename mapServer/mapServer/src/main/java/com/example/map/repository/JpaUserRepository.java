package com.example.map.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.map.entity.User;

public interface JpaUserRepository extends JpaRepository<User, Long> {
	// 유저 확인
	public Optional<User> findByEmailAndPlatform(String email, String platform);
}
