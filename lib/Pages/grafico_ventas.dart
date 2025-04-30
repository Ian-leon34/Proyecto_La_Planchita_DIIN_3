import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class GraficoVentas extends StatelessWidget {
  final List<Map<String, dynamic>> ventas;

  const GraficoVentas({super.key, required this.ventas});

  @override
  Widget build(BuildContext context) {
    Map<String, int> cantidadesPorProducto = {};

    for (var venta in ventas) {
      final producto = venta['producto'] ?? '';
      final cantidadRaw = venta['cantidad'] ?? 0;
      final cantidad = (cantidadRaw is int)
          ? cantidadRaw
          : (cantidadRaw is double)
              ? cantidadRaw.toInt()
              : int.tryParse(cantidadRaw.toString()) ?? 0;

      if (cantidadesPorProducto.containsKey(producto)) {
        cantidadesPorProducto[producto] =
            cantidadesPorProducto[producto]! + cantidad;
      } else {
        cantidadesPorProducto[producto] = cantidad;
      }
    }

    final productos = cantidadesPorProducto.keys.toList();
    final cantidades = cantidadesPorProducto.values.toList();

    // Generar colores diferentes para cada producto
    final random = Random();
    final colores = List.generate(
      productos.length,
      (index) => Color.fromARGB(
        255,
        random.nextInt(155) + 100,
        random.nextInt(155) + 100,
        random.nextInt(155) + 100,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gráfico de Ventas',
          style: TextStyle(fontFamily: 'Georgia'),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: cantidades.isEmpty
          ? const Center(
              child: Text(
                'No hay datos para graficar.',
                style: TextStyle(fontSize: 18, fontFamily: 'Georgia'),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: List.generate(productos.length, (index) {
                          final cantidad = cantidades[index].toDouble();
                          return PieChartSectionData(
                            color: colores[index],
                            value: cantidad,
                            title: '${productos[index]}',
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Georgia',
                            ),
                            radius: 80,
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(productos.length, (index) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            color: colores[index],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${productos[index]}: ${cantidades[index]}',
                            style: const TextStyle(fontFamily: 'Georgia'),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
    );
  }
}