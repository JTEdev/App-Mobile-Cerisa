package com.cerisa.api.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * Configuración para servir archivos estáticos (imágenes subidas)
 * desde el directorio de uploads del sistema de archivos local.
 */
@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

  @Value("${app.upload.dir}")
  private String uploadDir;

  @Override
  public void addResourceHandlers(ResourceHandlerRegistry registry) {
    Path uploadPath = Paths.get(uploadDir).toAbsolutePath().normalize();
    String resourceLocation = uploadPath.toUri().toString();

    registry.addResourceHandler("/uploads/products/**")
        .addResourceLocations(resourceLocation);
  }
}
