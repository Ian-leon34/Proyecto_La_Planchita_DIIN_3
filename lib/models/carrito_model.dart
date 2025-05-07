import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

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

  // Calcula el total según el tipo de producto
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

  // Devuelve el nombre con el tipo si es hamburguesa
  String get nombreConTipo {
    if (tipoHamburguesa != null) {
      return '$nombre - $tipoHamburguesa';
    }
    return nombre;
  }

  // Convierte el producto a Map para guardar en JSON
  Map<String, dynamic> toMap() {
    return {
      'producto': nombreConTipo,
      'cantidad': cantidad,
      'precio': _getPrecioReal(), // Usamos el precio calculado
      'fecha': DateTime.now().toIso8601String(),
      'origen': 'aplicacion', // Identificador para pedidos de la app
      'imagen': imagen, // Opcional: para posible uso futuro
    };
  }

  // Obtiene el precio unitario real (importante para hamburguesas)
  int _getPrecioReal() {
    if (tipoHamburguesa != null) {
      if (nombre.toLowerCase().contains("plancha")) {
        return 16000;
      } else if (tipoHamburguesa == "Patacón") {
        return 11000;
      } else {
        return 10000;
      }
    }
    return precio;
  }

  // Método para convertir a JSON
  String toJson() => json.encode(toMap());

  // Factory method para crear desde Map (por si necesitas cargar después)
  factory ProductoSeleccionado.fromMap(Map<String, dynamic> map) {
    // Separa nombre y tipo si es hamburguesa
    String? tipo;
    String nombre = map['producto'];

    if (nombre.contains(' - ')) {
      final partes = nombre.split(' - ');
      nombre = partes[0];
      tipo = partes[1];
    }

    return ProductoSeleccionado(
      nombre: nombre,
      imagen: map['imagen'] ?? '',
      precio: map['precio'],
      cantidad: map['cantidad'],
      tipoHamburguesa: tipo,
    );
  }
}

// Lista global para almacenar productos agregados al carrito
List<ProductoSeleccionado> carrito = [];

// Función auxiliar para guardar el carrito completo
Future<void> guardarCarritoEnHistorial() async {
  if (carrito.isEmpty) return;

  final prefs = await SharedPreferences.getInstance();
  final ventasExistentesJson = prefs.getString('registro_diario');

  List<dynamic> ventasAnteriores = [];
  if (ventasExistentesJson != null) {
    ventasAnteriores = jsonDecode(ventasExistentesJson);
  }

  final nuevosPedidos = carrito.map((item) => item.toMap()).toList();
  final todasLasVentas = [...ventasAnteriores, ...nuevosPedidos];

  await prefs.setString('registro_diario', jsonEncode(todasLasVentas));

  // Opcional: Guardar también en archivo diario específico
  try {
    final directory = await getApplicationDocumentsDirectory();
    final fecha = DateTime.now().toString().split(' ')[0];
    final file = File('${directory.path}/ventas_$fecha.json');
    await file.writeAsString(jsonEncode(todasLasVentas));
  } catch (e) {
    print('Error al guardar archivo diario: $e');
  }
}
