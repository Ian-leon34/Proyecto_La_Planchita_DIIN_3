import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DetalleHistorico extends StatefulWidget {
  final String mes;
  final int anio;
  final List<Map<String, dynamic>> ventas;

  const DetalleHistorico({
    super.key,
    required this.mes,
    required this.anio,
    required this.ventas,
  });

  @override
  State<DetalleHistorico> createState() => _DetalleHistoricoState();
}

class _DetalleHistoricoState extends State<DetalleHistorico> {
  String filtroProducto = 'Todos';
  late List<Map<String, dynamic>> ventasAgrupadas;
  late List<String> productosDisponibles;

  @override
  void initState() {
    super.initState();
    _agruparVentas();
  }

  void _agruparVentas() {
    final Map<String, Map<String, dynamic>> agrupadas = {};

    for (var venta in widget.ventas) {
      final producto = venta['producto'] ?? '';
      final cantidad = venta['cantidad'] ?? 0;
      final precio = venta['precio'] ?? 0;

      if (agrupadas.containsKey(producto)) {
        agrupadas[producto]!['cantidad'] += cantidad;
      } else {
        agrupadas[producto] = {
          'producto': producto,
          'cantidad': cantidad,
          'precio': precio,
        };
      }
    }

    ventasAgrupadas = agrupadas.values.toList();
    productosDisponibles = ['Todos', ...agrupadas.keys.toList()];
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> ventasFiltradas =
        filtroProducto == 'Todos'
            ? ventasAgrupadas
            : ventasAgrupadas
                .where((v) => v['producto'] == filtroProducto)
                .toList();

    double totalGeneral = ventasFiltradas.fold(0.0, (sum, venta) {
      final cantidad = venta['cantidad'] ?? 0;
      final precio = venta['precio'] ?? 0;
      return sum + (cantidad * precio);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalle ${widget.mes} ${widget.anio}',
          style: const TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child:
            ventasAgrupadas.isEmpty
                ? const Center(
                  child: Text(
                    'No hay registros para mostrar.',
                    style: TextStyle(fontSize: 18, fontFamily: 'Georgia'),
                  ),
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Ventas agrupadas:',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text(
                          'Filtrar producto:',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Georgia',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          value: filtroProducto,
                          onChanged: (String? nuevo) {
                            if (nuevo != null) {
                              setState(() {
                                filtroProducto = nuevo;
                              });
                            }
                          },
                          items:
                              productosDisponibles.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: MaterialStateColor.resolveWith(
                            (states) => const Color(0xFF1E3A8A),
                          ),
                          headingTextStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Georgia',
                          ),
                          dataTextStyle: const TextStyle(
                            fontSize: 15,
                            fontFamily: 'Georgia',
                          ),
                          columns: const [
                            DataColumn(label: Text('Producto')),
                            DataColumn(label: Text('Cantidad')),
                            DataColumn(label: Text('Precio')),
                            DataColumn(label: Text('Total')),
                          ],
                          rows:
                              ventasFiltradas.map((venta) {
                                final producto = venta['producto'];
                                final cantidad = venta['cantidad'];
                                final precio = venta['precio'];
                                final total = cantidad * precio;

                                return DataRow(
                                  cells: [
                                    DataCell(Text(producto.toString())),
                                    DataCell(Text(cantidad.toString())),
                                    DataCell(
                                      Text('\$${precio.toStringAsFixed(0)}'),
                                    ),
                                    DataCell(
                                      Text('\$${total.toStringAsFixed(0)}'),
                                    ),
                                  ],
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Total general: \$${totalGeneral.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontFamily: 'Georgia',
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => GraficaSeguimiento(
                                  mes: widget.mes,
                                  anio: widget.anio,
                                  ventas: ventasAgrupadas,
                                ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.bar_chart),
                      label: const Text(
                        'Ver gráfica de seguimiento',
                        style: TextStyle(fontFamily: 'Georgia'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}

// Nueva pantalla con gráfica
class GraficaSeguimiento extends StatelessWidget {
  final String mes;
  final int anio;
  final List<Map<String, dynamic>> ventas;

  const GraficaSeguimiento({
    super.key,
    required this.mes,
    required this.anio,
    required this.ventas,
  });

  @override
  Widget build(BuildContext context) {
    final List<BarChartGroupData> barGroups = [];
    final List<String> labels = [];

    for (int i = 0; i < ventas.length; i++) {
      final v = ventas[i];
      final total = (v['cantidad'] ?? 0) * (v['precio'] ?? 0);
      labels.add(v['producto'] ?? 'P$i');

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: total.toDouble(),
              color: const Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(4),
              width: 22,
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gráfica de $mes $anio',
          style: const TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: BarChart(
          BarChartData(
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < labels.length) {
                      return Transform.rotate(
                        angle: -0.5,
                        child: Text(
                          labels[index],
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
            barGroups: barGroups,
            borderData: FlBorderData(show: false),
            gridData: FlGridData(show: true),
          ),
        ),
      ),
    );
  }
}
