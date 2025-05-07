import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class GraficoVentas extends StatelessWidget {
  final List<Map<String, dynamic>> ventas;

  const GraficoVentas({super.key, required this.ventas});

  @override
  Widget build(BuildContext context) {
    if (ventas.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Gráfico de Ventas',
            style: TextStyle(fontFamily: 'Georgia'),
          ),
          backgroundColor: const Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            'No hay datos para graficar.',
            style: TextStyle(fontSize: 18, fontFamily: 'Georgia'),
          ),
        ),
      );
    }

    Map<String, num> cantidadesPorProducto = {};
    Map<String, double> ingresosPorProducto = {};
    double totalGeneral = 0;

    for (var venta in ventas) {
      final producto = venta['producto'] ?? '';
      final cantidad =
          (venta['cantidad'] is num)
              ? venta['cantidad'] as num
              : int.tryParse(venta['cantidad'].toString()) ?? 0;
      final precio =
          (venta['precio'] is num)
              ? venta['precio'].toDouble()
              : double.tryParse(venta['precio'].toString()) ?? 0;

      cantidadesPorProducto[producto] =
          (cantidadesPorProducto[producto] ?? 0) + cantidad;
      ingresosPorProducto[producto] =
          (ingresosPorProducto[producto] ?? 0) + (cantidad * precio);
      totalGeneral += cantidad.toDouble();
    }

    final productos = cantidadesPorProducto.keys.toList();

    // Colores únicos por producto
    final random = Random();
    final colores = List.generate(
      productos.length,
      (index) => Color.fromARGB(
        255,
        random.nextInt(100) + 100,
        random.nextInt(100) + 100,
        random.nextInt(100) + 100,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gráfico de Abril 2025',
          style: TextStyle(fontFamily: 'Georgia'),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: List.generate(productos.length, (index) {
                    final producto = productos[index];
                    final cantidad =
                        cantidadesPorProducto[producto]!.toDouble();
                    final porcentaje = (cantidad / totalGeneral) * 100;

                    return PieChartSectionData(
                      color: colores[index],
                      value: cantidad,
                      title: '${porcentaje.toStringAsFixed(1)}%',
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
            const Text(
              'Detalle por producto',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: productos.length,
                itemBuilder: (context, index) {
                  final producto = productos[index];
                  final cantidad = cantidadesPorProducto[producto]!;
                  final ingreso = ingresosPorProducto[producto]!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: colores[index],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            producto,
                            style: const TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Text(
                          'x$cantidad',
                          style: const TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '\$${ingreso.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
