package com.cerisa.api.service;

import com.cerisa.api.dto.product.ProductRequest;
import com.cerisa.api.dto.product.ProductResponse;
import com.cerisa.api.entity.Product;
import com.cerisa.api.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * Servicio que gestiona las operaciones CRUD del catálogo de productos.
 * <p>
 * Proporciona funcionalidades para listar, consultar, crear, actualizar
 * y eliminar (eliminación lógica) productos. Las operaciones de escritura
 * están protegidas con transacciones.
 * </p>
 * <p>
 * La eliminación de productos se realiza de forma lógica (soft delete),
 * marcando el campo {@code activo} como {@code false} en lugar de borrar
 * el registro de la base de datos.
 * </p>
 *
 * @author Equipo Cerisa
 * @version 1.0
 */
@Service
@RequiredArgsConstructor
public class ProductService {

    /** Repositorio para acceder a los datos de productos. */
    private final ProductRepository productRepository;

    /**
     * Obtiene todos los productos activos del catálogo.
     * Los productos eliminados lógicamente (activo=false) se excluyen.
     *
     * @return lista de productos activos en formato de respuesta
     */
    public List<ProductResponse> getAllProducts() {
        return productRepository.findByActivoTrue().stream()
                .map(this::toResponse)
                .toList();
    }

    /**
     * Obtiene un producto por su identificador único.
     *
     * @param id el identificador del producto a buscar
     * @return los datos del producto en formato de respuesta
     * @throws RuntimeException si no se encuentra el producto con el ID dado
     */
    public ProductResponse getProductById(Long id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Producto no encontrado con id: " + id));
        return toResponse(product);
    }

    /**
     * Crea un nuevo producto en el catálogo.
     * El producto se crea con estado activo por defecto.
     *
     * @param request los datos del producto a crear
     * @return los datos del producto creado en formato de respuesta
     */
    @Transactional
    public ProductResponse createProduct(ProductRequest request) {
        Product product = Product.builder()
                .nombre(request.getNombre())
                .descripcion(request.getDescripcion())
                .precio(request.getPrecio())
                .stock(request.getStock())
                .categoria(request.getCategoria())
                .imagenUrl(request.getImagenUrl())
                .activo(true)
                .build();

        return toResponse(productRepository.save(product));
    }

    /**
     * Actualiza los datos de un producto existente.
     *
     * @param id      el identificador del producto a actualizar
     * @param request los nuevos datos del producto
     * @return los datos actualizados del producto en formato de respuesta
     * @throws RuntimeException si no se encuentra el producto con el ID dado
     */
    @Transactional
    public ProductResponse updateProduct(Long id, ProductRequest request) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Producto no encontrado con id: " + id));

        // Actualizar todos los campos editables del producto
        product.setNombre(request.getNombre());
        product.setDescripcion(request.getDescripcion());
        product.setPrecio(request.getPrecio());
        product.setStock(request.getStock());
        product.setCategoria(request.getCategoria());
        product.setImagenUrl(request.getImagenUrl());

        return toResponse(productRepository.save(product));
    }

    /**
     * Elimina un producto de forma lógica (soft delete).
     * No se borra el registro de la BD; se marca como inactivo.
     *
     * @param id el identificador del producto a desactivar
     * @throws RuntimeException si no se encuentra el producto con el ID dado
     */
    @Transactional
    public void deleteProduct(Long id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Producto no encontrado con id: " + id));
        // Soft delete: marcar como inactivo en lugar de eliminar físicamente
        product.setActivo(false);
        productRepository.save(product);
    }

    /**
     * Convierte una entidad {@link Product} a su representación DTO
     * {@link ProductResponse}.
     *
     * @param p la entidad producto a convertir
     * @return el DTO de respuesta con los datos del producto
     */
    private ProductResponse toResponse(Product p) {
        return ProductResponse.builder()
                .id(p.getId())
                .nombre(p.getNombre())
                .descripcion(p.getDescripcion())
                .precio(p.getPrecio())
                .stock(p.getStock())
                .categoria(p.getCategoria())
                .imagenUrl(p.getImagenUrl())
                .activo(p.getActivo())
                .creadoEn(p.getCreadoEn())
                .build();
    }
}
