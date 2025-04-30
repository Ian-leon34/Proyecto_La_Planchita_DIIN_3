import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PantallaCalculo extends StatelessWidget {
  final List<Map<String, dynamic>> ventas;
  final void Function(List<Map<String, dynamic>>) onFinalizarVenta;

  const PantallaCalculo({
    super.key,
    required this.ventas,
    required this.onFinalizarVenta,
  });

  double obtenerPrecio(String producto) {
    const precios = {
      'Papa con carne': 1100,
      'Pollo': 2400,
      'Carne de cerdo': 2400,
      'Carne de res': 2400,
      'Pollo con champiñones': 2500,
      'Salchicha con queso': 2200,
      'Hawaiana': 2400,
      'Ranchera': 2500,
      'Tradicional - Pan': 10000,
      'Tradicional - Arepa': 10000,
      'Tradicional - Patacón': 11000,
      'Carne de pollo - Pan': 10000,
      'Carne de pollo - Arepa': 10000,
      'Carne de pollo - Patacón': 11000,
      'Plancha Burger - Pan': 16000,
      'Plancha Burger - Arepa': 16000,
      'Plancha Burger - Patacón': 17000,
    };
    return (precios[producto] ?? 0).toDouble();
  }

  double calcularTotal() {
    return ventas.fold(0.0, (suma, venta) {
      final nombre = venta['producto'];
      final cantidad = venta['cantidad'];
      final precioUnitario = obtenerPrecio(nombre);
      return suma + (precioUnitario * cantidad);
    });
  }

  Future<void> guardarVentas() async {
    final prefs = await SharedPreferences.getInstance();
    final ventasExistentesJson = prefs.getString('registro_diario');

    List<dynamic> ventasAnteriores = [];
    if (ventasExistentesJson != null) {
      ventasAnteriores = jsonDecode(ventasExistentesJson);
    }

    final nuevasVentas =
        ventas
            .map(
              (venta) => {
                'producto': venta['producto'],
                'cantidad': venta['cantidad'],
                'precio': obtenerPrecio(venta['producto']),
                'fecha': DateTime.now().toIso8601String(),
              },
            )
            .toList();

    final todasLasVentas = [...ventasAnteriores, ...nuevasVentas];

    await prefs.setString('registro_diario', jsonEncode(todasLasVentas));
  }

  @override
  Widget build(BuildContext context) {
    final double total = calcularTotal();

    return Stack(
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0.1,
            child: Image.asset('assets/fondo_empanadas.jpg', fit: BoxFit.cover),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text(
              'Resumen de Venta',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            centerTitle: true,
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Detalles de productos vendidos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Georgia',
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: ventas.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final venta = ventas[index];
                        final nombre = venta['producto'];
                        final cantidad = venta['cantidad'];
                        final precioUnitario = obtenerPrecio(nombre);
                        final subtotal = precioUnitario * cantidad;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          title: Text(
                            nombre,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Georgia',
                            ),
                          ),
                          subtitle: Text(
                            'Cantidad: $cantidad',
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'Georgia',
                            ),
                          ),
                          trailing: Text(
                            '\$${subtotal.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontFamily: 'Georgia',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(thickness: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Georgia',
                      ),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontFamily: 'Georgia',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await guardarVentas();
                      onFinalizarVenta(ventas);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('¡Venta guardada exitosamente!'),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al guardar la venta: $e'),
                            duration: const Duration(seconds: 3),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text("Finalizar y volver"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
