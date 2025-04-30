/// Modelo general de un producto del menú
class Product {
  final String nombre;
  final int precio;
  final String imagen;
  final bool esHamburguesa;

  const Product({
    required this.nombre,
    required this.precio,
    required this.imagen,
    this.esHamburguesa = false,
  });
}

/// Modelo de producto seleccionado para el carrito
class ProductoSeleccionado {
  final Product producto;
  int cantidad;
  final String?
  tipoHamburguesa; // "Pan", "Arepa", "Patacón" (solo si es hamburguesa)

  ProductoSeleccionado({
    required this.producto,
    this.cantidad = 1,
    this.tipoHamburguesa,
  });

  int get total {
    if (!producto.esHamburguesa) {
      return producto.precio * cantidad;
    }

    // Precios según el tipo de hamburguesa
    final tipo = tipoHamburguesa ?? "Pan";

    if (producto.nombre.toLowerCase().contains('plancha')) {
      return 16000 * cantidad;
    } else if (tipo == "Patacón") {
      return 11000 * cantidad;
    } else {
      return 10000 * cantidad;
    }
  }

  // Para mostrar nombre con tipo seleccionado (si aplica)
  String get nombreConTipo {
    if (producto.esHamburguesa && tipoHamburguesa != null) {
      return '${producto.nombre} - $tipoHamburguesa';
    }
    return producto.nombre;
  }
}
