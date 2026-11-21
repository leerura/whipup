package com.whipup;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class WhipupApplication {

	public static void main(String[] args) {
		SpringApplication.run(WhipupApplication.class, args);
	}

}
