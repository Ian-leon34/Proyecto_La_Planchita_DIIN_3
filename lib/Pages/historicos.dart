import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'detalle_historico.dart';

class Historicos extends StatefulWidget {
  const Historicos({super.key});

  @override
  State<Historicos> createState() => _HistoricosState();
}

class _HistoricosState extends State<Historicos> {
  int _selectedYear = DateTime.now().year;
  bool _isLoading = false;

  final List<int> years = List.generate(5, (index) => DateTime.now().year - 2 + index);
  final List<String> months = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  Future<void> _cargarYMostrarMes(int mes) async {
    setState(() => _isLoading = true);
    final monthName = months[mes - 1];
    
    final registrosMes = await _cargarVentasDelMes(mes, _selectedYear);

    if (!mounted) return;
    
    if (registrosMes.isEmpty) {
      _mostrarDialogoSinDatos(monthName);
    } else {
      _navegarADetalle(monthName, registrosMes);
    }

    setState(() => _isLoading = false);
  }

  void _mostrarDialogoSinDatos(String monthName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sin datos', style: TextStyle(fontFamily: 'Georgia')),
        content: Text('No hay ventas registradas en $monthName $_selectedYear.',
          style: const TextStyle(fontFamily: 'Georgia')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar', style: TextStyle(fontFamily: 'Georgia')),
          ),
        ],
      ),
    );
  }

  void _navegarADetalle(String monthName, List<Map<String, dynamic>> ventas) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalleHistorico(
          mes: monthName,
          anio: _selectedYear,
          ventas: ventas,
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _cargarVentasDelMes(int mes, int anio) async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync();

    final ventasMes = <Map<String, dynamic>>[];

    for (var file in files) {
      if (file is File && file.path.contains('ventas_')) {
        try {
          final dateStr = file.path.split('ventas_').last.replaceAll('.json', '');
          final date = DateTime.parse(dateStr);
          
          if (date.month == mes && date.year == anio) {
            final contenido = await file.readAsString();
            final ventasDia = jsonDecode(contenido) as List;
            
            for (var venta in ventasDia.cast<Map<String, dynamic>>()) {
              if (venta.containsKey('fecha')) {
                final fechaVenta = DateTime.parse(venta['fecha']);
                if (fechaVenta.month == mes && fechaVenta.year == anio) {
                  ventasMes.add(venta);
                }
              } else {
                ventasMes.add(venta);
              }
            }
          }
        } catch (_) {
          continue;
        }
      }
    }

    return ventasMes;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0.15,
            child: Image.asset('assets/fondo_empanadas.jpg', fit: BoxFit.cover),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text(
              'Registro Histórico Mensual',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            centerTitle: true,
            backgroundColor: const Color(0xFF1E3A8A),
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Año',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // Versión mejorada del selector de años
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: years.map((year) {
                    final isSelected = year == _selectedYear;
                    return ElevatedButton(
                      onPressed: () => setState(() => _selectedYear = year),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? const Color(0xFF1E3A8A) : Colors.white,
                        foregroundColor: isSelected ? Colors.white : const Color(0xFF1E3A8A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
                        ),
                        minimumSize: const Size(80, 45),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: Text(
                        year.toString(),
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Meses del año',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: months.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.2,
                    ),
                    itemBuilder: (context, index) {
                      final month = months[index];
                      return GestureDetector(
                        onTap: () => _cargarYMostrarMes(index + 1),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _isLoading && months[index] == month 
                                ? const Color(0xFF1E3A8A).withOpacity(0.7)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF1E3A8A),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: _isLoading && months[index] == month
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    month,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _isLoading && months[index] == month 
                                          ? Colors.white 
                                          : const Color(0xFF1E3A8A),
                                    ),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Image.asset(
                  'assets/logo.jpg',
                  height: 90,
                  width: 90,
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}