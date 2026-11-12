package com.whipup.auth.apple;

import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnableConfigurationProperties(AppleProperties.class)
public class AppleConfiguration {
}
