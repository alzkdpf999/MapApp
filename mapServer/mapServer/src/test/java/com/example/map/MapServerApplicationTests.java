package com.example.map;

import java.util.List;

import javax.transaction.Transactional;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import com.example.map.entity.Place;
import com.example.map.repository.JpaPlaceRepository;
import com.example.map.repository.JpaUserRepository;
import com.example.map.service.PlaceService;
import com.example.map.service.UserService;

import lombok.extern.slf4j.Slf4j;

@SpringBootTest
@Transactional
@Slf4j
class MapServerApplicationTests {
	@Autowired
	private UserService u;
	@Autowired
	private JpaUserRepository j;
	@Autowired
	private PlaceService p;
	@Autowired
	private JpaPlaceRepository jp;

	@Test
	void contextLoads() {
//		User user = User.builder().email("ksa@ac.kr").name("ksa").platform("google").imgUrl("update?").name("asd")
//				.build();
//		log.info("{}", j.save(user));
		List<Place> asd = jp.findAllByUserId(35L);
		for (int i = 0; i < asd.size(); i++) {
			log.info("{}asdasd", asd.get(i).getPlaceName());
			log.info("{}asdasd", asd.get(i).getCreateDate());
		}

	}

}
