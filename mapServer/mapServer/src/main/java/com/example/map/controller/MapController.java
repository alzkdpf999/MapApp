package com.example.map.controller;

import java.io.IOException;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import com.example.map.dto.ResponseDto;
import com.example.map.entity.Place;
import com.example.map.entity.User;
import com.example.map.service.PlaceService;
import com.example.map.service.UserService;

import lombok.extern.slf4j.Slf4j;

@RestController
@Slf4j
@RequestMapping("/map")
public class MapController {
	@Autowired
	private UserService userService;
	@Autowired
	private PlaceService placeService;

	// 로그인해서 가게 리스트 보내주기
	@ResponseBody
	@PostMapping("/login")
	public ResponseDto Login(@RequestBody User user) throws IOException {
		Long userId = userService.insertUsser(user);
		List<Place> places = placeService.findPlaces(userId);
		ResponseDto responseDto = ResponseDto.builder().userId(userId).place(places).build();
		return responseDto;
	}

	// 자동 로그인 시
	@GetMapping("/login/{userId}")
	public ResponseDto AutoLogin(@PathVariable Long userId) throws IOException {
		List<Place> places = placeService.findPlaces(userId);
		ResponseDto httpDto = ResponseDto.builder().userId(userId).place(places).build();
		return httpDto;
	}

	// 알람 설정한 가게들 저장하는 용
	@ResponseBody
	@PostMapping("/{userId}")
	public void registPlace(@PathVariable Long userId, @RequestBody Place place) throws IOException {
		log.info("userId{}", userId);
		placeService.insertPlace(place, userId);
	}

	@GetMapping
	public String test() {
		return "hello";
	}
}
