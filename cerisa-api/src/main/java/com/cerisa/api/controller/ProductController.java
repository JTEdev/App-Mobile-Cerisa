package com.cerisa.api.controller;

import com.cerisa.api.dto.product.ProductRequest;
import com.cerisa.api.dto.product.ProductResponse;
import com.cerisa.api.service.ProductService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controlador REST que expone los endpoints CRUD del catálogo de productos.
 * <p>
 * Los endpoints de lectura (GET) son públicos, mientras que los de escritura
 * (POST, PUT, DELETE) requieren rol ADMIN, según la configuración de seguridad.
 * </p>
 * <p>
 * Base URL: {@code /api/products}
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
public class ProductController {

    /** Servicio que gestiona la lógica de negocio de productos. */
    private final ProductService productService;

    /**
     * Obtiene todos los productos activos del catálogo.
     * <p>
     * Endpoint público: {@code GET /api/products}
     * </p>
     *
     * @return respuesta HTTP 200 con la lista de productos activos
     */
    @GetMapping
    public ResponseEntity<List<ProductResponse>> getAllProducts() {
        return ResponseEntity.ok(productService.getAllProducts());
    }

    /**
     * Obtiene un producto por su identificador único.
     * <p>
     * Endpoint público: {@code GET /api/products/{id}}
     * </p>
     *
     * @param id el identificador del producto a consultar
     * @return respuesta HTTP 200 con los datos del producto
     */
    @GetMapping("/{id}")
    public ResponseEntity<ProductResponse> getProductById(@PathVariable Long id) {
        return ResponseEntity.ok(productService.getProductById(id));
    }

    /**
     * Crea un nuevo producto en el catálogo.
     * <p>
     * Endpoint protegido (ADMIN): {@code POST /api/products}
     * </p>
     *
     * @param request el DTO con los datos del producto a crear (validado)
     * @return respuesta HTTP 201 (Created) con los datos del producto creado
     */
    @PostMapping
    public ResponseEntity<ProductResponse> createProduct(@Valid @RequestBody ProductRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(productService.createProduct(request));
    }

    /**
     * Actualiza un producto existente del catálogo.
     * <p>
     * Endpoint protegido (ADMIN): {@code PUT /api/products/{id}}
     * </p>
     *
     * @param id      el identificador del producto a actualizar
     * @param request el DTO con los nuevos datos del producto (validado)
     * @return respuesta HTTP 200 con los datos del producto actualizado
     */
    @PutMapping("/{id}")
    public ResponseEntity<ProductResponse> updateProduct(@PathVariable Long id,
            @Valid @RequestBody ProductRequest request) {
        return ResponseEntity.ok(productService.updateProduct(id, request));
    }

    /**
     * Elimina un producto del catálogo (eliminación lógica).
     * El producto se marca como inactivo pero no se borra de la base de datos.
     * <p>
     * Endpoint protegido (ADMIN): {@code DELETE /api/products/{id}}
     * </p>
     *
     * @param id el identificador del producto a desactivar
     * @return respuesta HTTP 204 (No Content) indicando eliminación exitosa
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProduct(@PathVariable Long id) {
        productService.deleteProduct(id);
        return ResponseEntity.noContent().build();
    }
}
