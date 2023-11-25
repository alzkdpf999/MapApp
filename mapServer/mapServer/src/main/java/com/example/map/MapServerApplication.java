package com.example.map;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;


@EnableJpaAuditing
@SpringBootApplication
public class MapServerApplication {

	public static void main(String[] args) {
		SpringApplication.run(MapServerApplication.class, args);
	}

}
