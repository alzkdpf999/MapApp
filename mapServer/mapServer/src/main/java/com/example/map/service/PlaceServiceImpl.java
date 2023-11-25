package com.example.map.service;

import java.util.List;
import java.util.Optional;

import javax.transaction.Transactional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.map.entity.Place;
import com.example.map.entity.User;
import com.example.map.repository.JpaPlaceRepository;
import com.example.map.repository.JpaUserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
@RequiredArgsConstructor
public class PlaceServiceImpl implements PlaceService {
	@Autowired
	private final JpaPlaceRepository placeRepository;
	private final JpaUserRepository userRepository;

	// 알람 설정한 가게들 저장하기
	@Transactional
	public void insertPlace(Place place, Long userId) {
		log.info("{}asdasd", userId);

		Optional<User> user = userRepository.findById(userId);
		place.setUser(user.get());

		placeRepository.save(place);
	}

	public List<Place> findPlaces(Long userId) {
		List<Place> places = placeRepository.findAllByUserId(userId);
		return places;
	}
}
