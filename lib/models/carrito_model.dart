class ProductoSeleccionado {
  final String nombre;
  final String imagen;
  final int precio;
  int cantidad;
  final String? tipoHamburguesa; // solo si es hamburguesa

  ProductoSeleccionado({
    required this.nombre,
    required this.imagen,
    required this.precio,
    required this.cantidad,
    this.tipoHamburguesa,
  });

  int get total {
    if (tipoHamburguesa != null) {
      if (nombre.toLowerCase().contains("plancha")) {
        return 16000 * cantidad;
      } else if (tipoHamburguesa == "Patacón") {
        return 11000 * cantidad;
      } else {
        return 10000 * cantidad;
      }
    }
    return precio * cantidad;
  }

  String get nombreConTipo {
    if (tipoHamburguesa != null) {
      return '$nombre - $tipoHamburguesa';
    }
    return nombre;
  }
}

// Lista global para almacenar productos agregados al carrito
List<ProductoSeleccionado> carrito = [];
