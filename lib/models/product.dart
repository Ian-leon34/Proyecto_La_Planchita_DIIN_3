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

  // Para convertir de Map a Product (útil al cargar desde archivo)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      nombre: map['nombre'],
      precio: map['precio'],
      imagen: map['imagen'],
      esHamburguesa: map['esHamburguesa'] ?? false,
    );
  }

  // Para convertir a Map (útil al guardar en archivo)
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'precio': precio,
      'imagen': imagen,
      'esHamburguesa': esHamburguesa,
    };
  }
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

  // Calcula el total del producto
  int get total {
    if (!producto.esHamburguesa) {
      return producto.precio * cantidad;
    }

    final tipo = tipoHamburguesa ?? "Pan";

    if (producto.nombre.toLowerCase().contains('plancha')) {
      return 16000 * cantidad;
    } else if (tipo == "Patacón") {
      return 11000 * cantidad;
    } else {
      return 10000 * cantidad;
    }
  }

  // Precio unitario real según tipo
  int _getPrecioReal() {
    if (!producto.esHamburguesa) return producto.precio;

    if (producto.nombre.toLowerCase().contains('plancha')) {
      return 16000;
    } else if (tipoHamburguesa == "Patacón") {
      return 11000;
    } else {
      return 10000;
    }
  }

  // Nombre para mostrar incluyendo el tipo (si aplica)
  String get nombreConTipo {
    if (producto.esHamburguesa && tipoHamburguesa != null) {
      return '${producto.nombre} - $tipoHamburguesa';
    }
    return producto.nombre;
  }

  // Convertir a Map para guardar como JSON
  Map<String, dynamic> toMap() {
    return {
      'producto': nombreConTipo,
      'cantidad': cantidad,
      'precio': _getPrecioReal(),
      'fecha': DateTime.now().toIso8601String(),
      'origen': 'aplicacion',
      'imagen': producto.imagen,
    };
  }

  // Crear desde Map (al leer desde archivo JSON)
  factory ProductoSeleccionado.fromMap(Map<String, dynamic> map) {
    String? tipo;
    String nombre = map['producto'];

    if (nombre.contains(' - ')) {
      final partes = nombre.split(' - ');
      nombre = partes[0];
      tipo = partes[1];
    }

    return ProductoSeleccionado(
      producto: Product(
        nombre: nombre,
        precio: map['precio'],
        imagen: map['imagen'] ?? '',
        esHamburguesa: map['producto'].toString().toLowerCase().contains(
          'hamburguesa',
        ),
      ),
      cantidad: map['cantidad'],
      tipoHamburguesa: tipo,
    );
  }
}
