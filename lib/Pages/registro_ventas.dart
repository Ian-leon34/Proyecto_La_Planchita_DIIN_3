import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pantalla_calculo.dart';
import 'base_datosV.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RegistroVentas extends StatefulWidget {
  const RegistroVentas({super.key});

  @override
  State<RegistroVentas> createState() => _RegistroVentasState();
}

class _RegistroVentasState extends State<RegistroVentas> {
  final List<Map<String, dynamic>> ventas = [];
  final List<Map<String, dynamic>> _pedidoActual = [];

  @override
  void initState() {
    super.initState();
    _cargarVentasGuardadas();
  }

  int obtenerPrecio(String producto) {
    const precios = {
      // Empanadas
      'Papa con carne': 1100,
      'Pollo': 2400,
      'Carne de cerdo': 2400,
      'Carne de res': 2400,
      'Pollo con champiñones': 2500,
      'Salchicha con queso': 2200,
      'Hawaiana': 2400,
      'Ranchera': 2500,
      // Hamburguesas
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
    return precios[producto] ?? 0;
  }

  Future<void> _guardarVentas() async {
    final prefs = await SharedPreferences.getInstance();
    final ventasJson = jsonEncode(ventas);
    await prefs.setString('ventas_guardadas', ventasJson);
  }

  Future<void> _cargarVentasGuardadas() async {
    final prefs = await SharedPreferences.getInstance();
    final ventasJson = prefs.getString('ventas_guardadas');
    if (ventasJson != null) {
      final List<dynamic> listaDecodificada = jsonDecode(ventasJson);
      setState(() {
        ventas.addAll(
          listaDecodificada.map<Map<String, dynamic>>(
            (item) => Map<String, dynamic>.from(item),
          ),
        );
      });
    }
  }

  void _completarVenta() {
    if (_pedidoActual.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => PantallaCalculo(
                ventas: List.from(_pedidoActual),
                onFinalizarVenta: _finalizarVenta,
              ),
        ),
      );
    }
  }

  void _finalizarVenta(List<Map<String, dynamic>> pedidoFinal) {
    setState(() {
      ventas.addAll(pedidoFinal);
      _pedidoActual.clear();
    });
    _guardarVentas();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ Pedido registrado exitosamente"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _registrarVenta(String producto, int cantidad, {String? tipo = ''}) {
    setState(() {
      final nombreCompleto =
          tipo != null && tipo.isNotEmpty ? '$producto - $tipo' : producto;
      final precio = obtenerPrecio(nombreCompleto);
      _pedidoActual.add({
        'producto': nombreCompleto,
        'cantidad': cantidad,
        'precioUnitario': precio,
        'total': cantidad * precio,
        'origen': 'trabajador',
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Producto agregado al pedido: $cantidad de $producto $tipo',
        ),
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 70, left: 16, right: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _mostrarDialogoCantidad(String nombre, {bool esHamburguesa = false}) {
    int cantidad = 1;
    String tipoSeleccionado = 'Pan';

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Cantidad vendida',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed:
                            () => setState(
                              () => cantidad = cantidad > 1 ? cantidad - 1 : 1,
                            ),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('$cantidad', style: const TextStyle(fontSize: 18)),
                      IconButton(
                        onPressed: () => setState(() => cantidad++),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                  if (esHamburguesa) ...[
                    const SizedBox(height: 12),
                    DropdownButton<String>(
                      value: tipoSeleccionado,
                      items:
                          ['Pan', 'Arepa', 'Patacón']
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                      onChanged:
                          (value) =>
                              setState(() => tipoSeleccionado = value ?? 'Pan'),
                    ),
                  ],
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _registrarVenta(
                        nombre,
                        cantidad,
                        tipo: esHamburguesa ? tipoSeleccionado : null,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Agregar al pedido"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _seccionProducto(
    String titulo,
    List<Map<String, String>> productos,
    bool esHamburguesa,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            titulo,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: productos.length,
            itemBuilder: (_, index) {
              final producto = productos[index];
              return ProductoHorizontal(
                nombre: producto['nombre']!,
                rutaImagen: 'assets/${producto['imagen']}',
                onTap: () {
                  HapticFeedback.lightImpact();
                  _mostrarDialogoCantidad(
                    producto['nombre']!,
                    esHamburguesa: esHamburguesa,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final empanadas = [
      {'nombre': 'Papa con carne', 'imagen': 'empanada_papa_carne.png'},
      {'nombre': 'Pollo', 'imagen': 'empanada_pollo.png'},
      {'nombre': 'Carne de cerdo', 'imagen': 'empanada_cerdo.png'},
      {'nombre': 'Carne de res', 'imagen': 'empanada_res.png'},
      {'nombre': 'Pollo con champiñones', 'imagen': 'empanada_pollo_champ.png'},
      {
        'nombre': 'Salchicha con queso',
        'imagen': 'empanada_salchicha_queso.png',
      },
      {'nombre': 'Hawaiana', 'imagen': 'empanada_hawaiana.png'},
      {'nombre': 'Ranchera', 'imagen': 'empanada_ranchera.png'},
    ];

    final hamburguesas = [
      {'nombre': 'Tradicional', 'imagen': 'hamburguesa_res.png'},
      {'nombre': 'Carne de pollo', 'imagen': 'hamburguesa_pollo.png'},
      {'nombre': 'Plancha Burger', 'imagen': 'hamburguesa_plancha.png'},
    ];

    return Stack(
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0.15,
            child: Image.asset('assets/fondo_empanadas.jpg', fit: BoxFit.cover),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              Container(
                color: const Color(0xFFFDF3DC),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Registro de ventas',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Georgia',
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder:
                              (_) => Dialog(
                                backgroundColor: Colors.transparent,
                                insetPadding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 200,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      255,
                                      211,
                                      210,
                                      210,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Seleccione una cantidad vendida y confírmela. El sistema registrará automáticamente la venta.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        height: 100,
                                        child: Image.asset(
                                          'assets/bombilla.gif',
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.amber.shade600,
                                          foregroundColor: Colors.black87,
                                        ),
                                        child: const Text("Entendido"),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        );
                      },
                      child: const Icon(Icons.info_outline, size: 36),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _seccionProducto("Empanadas", empanadas, false),
              const SizedBox(height: 20),
              _seccionProducto("Hamburguesas", hamburguesas, true),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _completarVenta,
                      icon: const Icon(Icons.check_circle_outline, size: 24),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Completar venta',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => BaseDatosV()),
                        );
                      },
                      icon: const Icon(Icons.list_alt_outlined, size: 24),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Visualizar registro diario de ventas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          110,
                          110,
                          110,
                        ),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}

class ProductoHorizontal extends StatelessWidget {
  final String nombre;
  final String rutaImagen;
  final VoidCallback onTap;

  const ProductoHorizontal({
    super.key,
    required this.nombre,
    required this.rutaImagen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.green.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 10),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  rutaImagen,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              nombre,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
