package com.cerisa.api.controller;

import com.cerisa.api.entity.Product;
import com.cerisa.api.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import jakarta.annotation.PostConstruct;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

/**
 * Controlador para subir imágenes de productos.
 * <p>
 * Almacena las imágenes en el sistema de archivos local y actualiza
 * la URL de imagen del producto en la base de datos.
 * </p>
 */
@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
public class FileUploadController {

  private final ProductRepository productRepository;

  @Value("${app.upload.dir}")
  private String uploadDir;

  /** Extensiones permitidas para imágenes. */
  private static final Set<String> ALLOWED_EXTENSIONS = Set.of("jpg", "jpeg", "png", "webp", "gif");

  /** Tamaño máximo: 10 MB */
  private static final long MAX_FILE_SIZE = 10 * 1024 * 1024;

  @PostConstruct
  public void init() throws IOException {
    Files.createDirectories(Paths.get(uploadDir));
  }

  /**
   * Sube una imagen para un producto existente.
   *
   * @param id   ID del producto
   * @param file archivo de imagen (multipart)
   * @return mapa con la URL pública de la imagen
   */
  @PostMapping("/{id}/image")
  public ResponseEntity<?> uploadProductImage(
      @PathVariable Long id,
      @RequestParam("file") MultipartFile file) {

    // Validar que el archivo no esté vacío
    if (file.isEmpty()) {
      return ResponseEntity.badRequest()
          .body(Map.of("mensaje", "El archivo está vacío"));
    }

    // Validar tamaño
    if (file.getSize() > MAX_FILE_SIZE) {
      return ResponseEntity.badRequest()
          .body(Map.of("mensaje", "El archivo excede el tamaño máximo de 10MB"));
    }

    // Validar extensión
    String originalFilename = file.getOriginalFilename();
    if (originalFilename == null) {
      return ResponseEntity.badRequest()
          .body(Map.of("mensaje", "Nombre de archivo inválido"));
    }
    String extension = getFileExtension(originalFilename).toLowerCase();
    if (!ALLOWED_EXTENSIONS.contains(extension)) {
      return ResponseEntity.badRequest()
          .body(Map.of("mensaje", "Formato no permitido. Use: jpg, jpeg, png, webp, gif"));
    }

    // Validar content-type
    String contentType = file.getContentType();
    if (contentType == null || !contentType.startsWith("image/")) {
      return ResponseEntity.badRequest()
          .body(Map.of("mensaje", "El archivo debe ser una imagen"));
    }

    // Buscar producto
    Product product = productRepository.findById(id).orElse(null);
    if (product == null) {
      return ResponseEntity.notFound().build();
    }

    try {
      // Generar nombre único para evitar colisiones
      String filename = UUID.randomUUID().toString() + "." + extension;
      Path targetPath = Paths.get(uploadDir).resolve(filename);

      // Guardar archivo
      Files.copy(file.getInputStream(), targetPath, StandardCopyOption.REPLACE_EXISTING);

      // URL relativa que será servida por WebMvcConfig
      String imageUrl = "/uploads/products/" + filename;

      // Actualizar producto
      product.setImagenUrl(imageUrl);
      productRepository.save(product);

      return ResponseEntity.ok(Map.of(
          "imagenUrl", imageUrl,
          "mensaje", "Imagen subida correctamente"));

    } catch (IOException e) {
      return ResponseEntity.internalServerError()
          .body(Map.of("mensaje", "Error al guardar la imagen"));
    }
  }

  private String getFileExtension(String filename) {
    int dotIndex = filename.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex == filename.length() - 1)
      return "";
    return filename.substring(dotIndex + 1);
  }
}
