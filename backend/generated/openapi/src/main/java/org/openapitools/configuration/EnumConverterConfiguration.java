package org.openapitools.configuration;

import java.math.BigDecimal;
import java.net.URI;
import java.util.UUID;

import com.whipup.generated.model.RecommendationMode;

import jakarta.annotation.Generated;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.convert.converter.Converter;

/**
 * This class provides Spring Converter beans for the enum models in the OpenAPI specification.
 *
 * By default, Spring only converts primitive types to enums using Enum::valueOf, which can prevent
 * correct conversion if the OpenAPI specification is using an `enumPropertyNaming` other than
 * `original` or the specification has an integer enum.
 */
@Generated(value = "org.openapitools.codegen.languages.SpringCodegen", comments = "Generator version: 7.25.0")
@Configuration(value = "org.openapitools.configuration.enumConverterConfiguration")
public class EnumConverterConfiguration {

    @Bean(name = "org.openapitools.configuration.EnumConverterConfiguration.recommendationModeConverter")
    Converter<String, RecommendationMode> recommendationModeConverter() {
        return new Converter<String, RecommendationMode>() {
            @Override
            public RecommendationMode convert(String source) {
                return RecommendationMode.fromValue(source);
            }
        };
    }

}
