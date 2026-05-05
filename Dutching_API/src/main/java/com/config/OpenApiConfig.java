package com.config;

import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.info.Info;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;


@Configuration
@EnableJpaRepositories(basePackages = "com.repositories.jpa")
@OpenAPIDefinition(
        info = @Info(
                title = "Dutching_API",
                version = "1.0",
                description = "Test for Film database w SpringBoot"
        )
)
public class OpenApiConfig {

}
