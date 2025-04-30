import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BaseDatosV extends StatefulWidget {
  const BaseDatosV({Key? key}) : super(key: key);

  @override
  State<BaseDatosV> createState() => _BaseDatosVState();
}

class _BaseDatosVState extends State<BaseDatosV> {
  List<Map<String, dynamic>> ventas = [];

  @override
  void initState() {
    super.initState();
    _cargarVentas();
  }

  Future<void> _cargarVentas() async {
    await _cargarDesdeSharedPreferences();
    await _guardarVentasDelDiaEnArchivo();
  }

  Future<void> _cargarDesdeSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final ventasGuardadasJson = prefs.getString('registro_diario');
    if (ventasGuardadasJson != null) {
      final List<dynamic> ventasDecodificadas = jsonDecode(ventasGuardadasJson);
      setState(() {
        ventas = ventasDecodificadas.cast<Map<String, dynamic>>();
      });
    }
  }

  Future<void> _guardarEnSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('registro_diario', jsonEncode(ventas));
  }

  Future<void> _guardarVentasDelDiaEnArchivo() async {
    if (ventas.isEmpty) return;

    final DateTime ahora = DateTime.now();
    final String fechaArchivo = DateFormat('yyyy-MM-dd').format(ahora);
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/ventas_$fechaArchivo.json';
    final file = File(path);

    await file.writeAsString(jsonEncode(ventas));
  }

  void _eliminarVenta(int index) async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: const Text('¿Estás seguro de eliminar esta venta?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmacion == true) {
      setState(() {
        ventas.removeAt(index);
      });
      await _guardarEnSharedPreferences();
      await _guardarVentasDelDiaEnArchivo();
    }
  }

  double calcularTotalGeneral() {
    double total = 0;
    for (var venta in ventas) {
      final cantidad = venta['cantidad'] ?? 0;
      final precio = venta['precio'] ?? 0;
      total += cantidad * precio;
    }
    return total;
  }

  String formatearFecha(String? fechaIso) {
    if (fechaIso == null) return '';
    final DateTime fecha = DateTime.parse(fechaIso);
    return DateFormat('dd/MM/yyyy HH:mm').format(fecha);
  }

  @override
  Widget build(BuildContext context) {
    final double totalGeneral = calcularTotalGeneral();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registro diario de ventas',
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
      body:
          ventas.isEmpty
              ? const Center(
                child: Text(
                  'No hay ventas registradas.',
                  style: TextStyle(fontSize: 18, fontFamily: 'Georgia'),
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(
                            Colors.deepPurple[100],
                          ),
                          columns: const [
                            DataColumn(
                              label: Text(
                                'Producto',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Georgia',
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Cantidad',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Georgia',
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Total',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Georgia',
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Tipo',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Georgia',
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Fecha',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Georgia',
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Acciones',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Georgia',
                                ),
                              ),
                            ),
                          ],
                          rows: List<DataRow>.generate(ventas.length, (index) {
                            final venta = ventas[index];
                            final producto = venta['producto'] ?? '';
                            final cantidad = venta['cantidad'] ?? 0;
                            final precio = venta['precio'] ?? 0;
                            final total = (precio * cantidad).toDouble();
                            final fecha = formatearFecha(venta['fecha']);

                            return DataRow(
                              cells: [
                                DataCell(Text(producto)),
                                DataCell(Text(cantidad.toString())),
                                DataCell(Text('\$${total.toStringAsFixed(0)}')),
                                const DataCell(Text('Trabajador')),
                                DataCell(Text(fecha)),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _eliminarVenta(index),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'Total General: ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Georgia',
                          ),
                        ),
                        Text(
                          '\$${totalGeneral.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontFamily: 'Georgia',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
    );
  }
}
