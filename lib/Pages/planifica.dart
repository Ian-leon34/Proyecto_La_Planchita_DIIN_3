import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Planifica extends StatefulWidget {
  const Planifica({super.key});

  @override
  State<Planifica> createState() => _PlanificaState();
}

class _PlanificaState extends State<Planifica> {
  Map<String, int> estimacionVentas = {};
  Map<String, double> insumosTotales = {};
  bool cargando = false;
  bool mostrarProyecciones = false;
  String nombreMes = "";

  final Random random = Random();

  final Map<String, Map<String, double>> recetas = {
    // EMPANADAS
    "Papa con carne": {
      "Papa (kg)": 0.25,
      "Carne (kg)": 0.15,
      "Masa de maíz (kg)": 0.2,
      "Aceite (L)": 0.05,
    },
    "Pollo": {
      "Pollo (kg)": 0.2,
      "Masa de maíz (kg)": 0.2,
      "Aceite (L)": 0.05,
    },
    "Carne de cerdo": {
      "Carne de cerdo (kg)": 0.2,
      "Masa de maíz (kg)": 0.2,
      "Aceite (L)": 0.05,
    },
    "Carne de res": {
      "Carne de res (kg)": 0.2,
      "Masa de maíz (kg)": 0.2,
      "Aceite (L)": 0.05,
    },
    "Pollo con champiñones": {
      "Pollo (kg)": 0.15,
      "Champiñones (kg)": 0.1,
      "Masa de maíz (kg)": 0.2,
      "Aceite (L)": 0.05,
    },
    "Salchicha con queso": {
      "Salchicha (ud)": 1,
      "Queso (g)": 30,
      "Masa de maíz (kg)": 0.2,
      "Aceite (L)": 0.05,
    },
    "Hawaiana": {
      "Jamón (g)": 30,
      "Piña (g)": 30,
      "Queso (g)": 30,
      "Masa de maíz (kg)": 0.2,
      "Aceite (L)": 0.05,
    },
    "Ranchera": {
      "Carne molida (kg)": 0.2,
      "Frijoles (g)": 50,
      "Masa de maíz (kg)": 0.2,
      "Aceite (L)": 0.05,
    },

    // HAMBURGUESAS
    "Hamburguesa res - pan": {
      "Pan (ud)": 1,
      "Carne de res (kg)": 0.2,
      "Queso (g)": 30,
      "Lechuga (g)": 20,
      "Tomate (g)": 30,
    },
    "Hamburguesa res - arepa": {
      "Arepa (ud)": 1,
      "Carne de res (kg)": 0.2,
      "Queso (g)": 30,
      "Lechuga (g)": 20,
      "Tomate (g)": 30,
    },
    "Hamburguesa res - patacon": {
      "Patacón (ud)": 1,
      "Carne de res (kg)": 0.2,
      "Queso (g)": 30,
      "Lechuga (g)": 20,
      "Tomate (g)": 30,
    },
    "Hamburguesa pollo - pan": {
      "Pan (ud)": 1,
      "Carne de pollo (kg)": 0.2,
      "Queso (g)": 30,
      "Lechuga (g)": 20,
      "Tomate (g)": 30,
    },
    "Hamburguesa pollo - arepa": {
      "Arepa (ud)": 1,
      "Carne de pollo (kg)": 0.2,
      "Queso (g)": 30,
      "Lechuga (g)": 20,
      "Tomate (g)": 30,
    },
    "Hamburguesa pollo - patacon": {
      "Patacón (ud)": 1,
      "Carne de pollo (kg)": 0.2,
      "Queso (g)": 30,
      "Lechuga (g)": 20,
      "Tomate (g)": 30,
    },
    "Plancha burguer - pan": {
      "Pan (ud)": 1,
      "Carne de res (kg)": 0.1,
      "Carne de pollo (kg)": 0.1,
      "Queso (g)": 30,
      "Lechuga (g)": 20,
      "Tomate (g)": 30,
    },
    "Plancha burguer - arepa": {
      "Arepa (ud)": 1,
      "Carne de res (kg)": 0.1,
      "Carne de pollo (kg)": 0.1,
      "Queso (g)": 30,
      "Lechuga (g)": 20,
      "Tomate (g)": 30,
    },
    "Plancha burguer - patacon": {
      "Patacón (ud)": 1,
      "Carne de res (kg)": 0.1,
      "Carne de pollo (kg)": 0.1,
      "Queso (g)": 30,
      "Lechuga (g)": 20,
      "Tomate (g)": 30,
    },
  };

  void _generarProyeccion() async {
    setState(() {
      cargando = true;
    });

    await Future.delayed(const Duration(seconds: 5)); // Simular carga

    final ahora = DateTime.now();
    final proximo = DateTime(ahora.year, ahora.month + 1);
    nombreMes = toBeginningOfSentenceCase(DateFormat.MMMM('es').format(proximo))!;
    final diasMes = DateUtils.getDaysInMonth(proximo.year, proximo.month);
    final totalEmpanadas = 300 * diasMes;
    final totalHamburguesas = (random.nextInt(11) + 30) * diasMes;

    final empanadas = recetas.keys.where((e) => !e.contains('Hamburguesa') && !e.contains('Plancha'));
    final hamburguesas = recetas.keys.where((e) => e.contains('Hamburguesa') || e.contains('Plancha'));

    final Map<String, int> ventas = {};
    final Map<String, double> insumos = {};

    for (var emp in empanadas) {
      final base = emp == "Papa con carne"
          ? (totalEmpanadas * 0.25).toInt()
          : (totalEmpanadas * 0.75 ~/ (empanadas.length - 1));
      ventas[emp] = base + random.nextInt(20);
    }

    for (var burg in hamburguesas) {
      final base = burg == "Hamburguesa pollo - patacon"
          ? (totalHamburguesas * 0.3).toInt()
          : (totalHamburguesas * 0.7 ~/ (hamburguesas.length - 1));
      ventas[burg] = base + random.nextInt(10);
    }

    ventas.forEach((producto, cantidad) {
      final receta = recetas[producto]!;
      receta.forEach((insumo, cantidadPorUnidad) {
        insumos[insumo] = (insumos[insumo] ?? 0) + cantidadPorUnidad * cantidad;
      });
    });

    setState(() {
      estimacionVentas = ventas;
      insumosTotales = insumos;
      cargando = false;
      mostrarProyecciones = true;
    });
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planificación del Mes Siguiente'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: cargando
            ? const CircularProgressIndicator()
            : mostrarProyecciones
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView(
                      children: [
                        Text(
                          'Proyección para $nombreMes',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '🔢 Estimación de Ventas:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        ...estimacionVentas.entries.map((e) => Card(
                              child: ListTile(
                                leading: const Icon(Icons.shopping_cart, color: Colors.teal),
                                title: Text(e.key),
                                trailing: Text('${e.value} unidades'),
                              ),
                            )),
                        const Divider(thickness: 2),
                        const SizedBox(height: 12),
                        const Text(
                          '🧾 Insumos necesarios:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        ...insumosTotales.entries.map((e) => Card(
                              color: Colors.orange[50],
                              child: ListTile(
                                leading: const Icon(Icons.kitchen, color: Colors.brown),
                                title: Text(e.key),
                                trailing: Text(e.value.toStringAsFixed(2)),
                              ),
                            )),
                      ],
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: _generarProyeccion,
                    icon: const Icon(Icons.analytics_outlined),
                    label: const Text("Calcular Proyecciones"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
      ),
    );
  }
}