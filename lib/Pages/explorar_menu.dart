import 'package:flutter/material.dart';
import '../models/carrito_model.dart';

class ExplorarMenu extends StatelessWidget {
  const ExplorarMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> productos = [
      // Empanadas
      {
        'nombre': 'Empanada Papa con carne',
        'precio': 1100,
        'imagen': 'assets/empanada_papa_carne.png',
      },
      {
        'nombre': 'Empanada Pollo',
        'precio': 2400,
        'imagen': 'assets/empanada_pollo.png',
      },
      {
        'nombre': 'Empanada Carne de cerdo',
        'precio': 2400,
        'imagen': 'assets/empanada_cerdo.png',
      },
      {
        'nombre': 'Empanada Carne de res',
        'precio': 2400,
        'imagen': 'assets/empanada_res.png',
      },
      {
        'nombre': 'Empanada Pollo y champiñones',
        'precio': 2500,
        'imagen': 'assets/empanada_pollo_champ.png',
      },
      {
        'nombre': 'Empanada Salchicha con queso',
        'precio': 2200,
        'imagen': 'assets/empanada_salchicha_queso.png',
      },
      {
        'nombre': 'Empanada Hawaiana',
        'precio': 2400,
        'imagen': 'assets/empanada_hawaiana.png',
      },
      {
        'nombre': 'Empanada Ranchera',
        'precio': 2500,
        'imagen': 'assets/empanada_ranchera.png',
      },
      // Hamburguesas
      {
        'nombre': 'Hamburguesa Res',
        'precio': 10000,
        'imagen': 'assets/hamburguesa_res.png',
        'hamburguesa': true,
      },
      {
        'nombre': 'Hamburguesa Pollo',
        'precio': 10000,
        'imagen': 'assets/hamburguesa_pollo.png',
        'hamburguesa': true,
      },
      {
        'nombre': 'Plancha burguer',
        'precio': 16000,
        'imagen': 'assets/hamburguesa_plancha.png',
        'hamburguesa': true,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar Menú'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => _mostrarCarrito(context),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: productos.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemBuilder: (context, index) {
          final producto = productos[index];
          return GestureDetector(
            onTap: () => _mostrarSeleccionCantidad(context, producto),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.asset(producto['imagen'], fit: BoxFit.cover),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      producto['nombre'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('\$${producto['precio']}'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarCarrito(context),
        backgroundColor: Colors.green,
        child: const Icon(Icons.shopping_cart),
      ),
    );
  }

  void _mostrarSeleccionCantidad(
    BuildContext context,
    Map<String, dynamic> producto,
  ) {
    int cantidad = 1;
    String tipoSeleccionado = 'Pan';
    final esHamburguesa = producto['hamburguesa'] == true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            int precioFinal = producto['precio'];
            if (esHamburguesa) {
              if (producto['nombre'].toLowerCase().contains('plancha')) {
                precioFinal = 16000;
              } else if (tipoSeleccionado == 'Patacón') {
                precioFinal = 11000;
              } else {
                precioFinal = 10000;
              }
            }

            return AlertDialog(
              title: Text(producto['nombre']),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(producto['imagen'], height: 100),
                  const SizedBox(height: 10),

                  if (esHamburguesa)
                    DropdownButton<String>(
                      value: tipoSeleccionado,
                      items:
                          ['Pan', 'Arepa', 'Patacón'].map((tipo) {
                            return DropdownMenuItem(
                              value: tipo,
                              child: Text(tipo),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          tipoSeleccionado = value!;
                        });
                      },
                    ),

                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed:
                            () => setState(() {
                              if (cantidad > 1) cantidad--;
                            }),
                        icon: const Icon(Icons.remove),
                      ),
                      Text('$cantidad'),
                      IconButton(
                        onPressed: () => setState(() => cantidad++),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('Total: \$${precioFinal * cantidad}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    carrito.add(
                      ProductoSeleccionado(
                        nombre: producto['nombre'],
                        imagen: producto['imagen'],
                        precio: producto['precio'],
                        cantidad: cantidad,
                        tipoHamburguesa:
                            esHamburguesa ? tipoSeleccionado : null,
                      ),
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: const [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 10),
                            Text('Se agregó al carrito correctamente'),
                          ],
                        ),
                        duration: const Duration(seconds: 2),
                        backgroundColor: Colors.black87,
                      ),
                    );
                  },
                  child: const Text('Agregar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarCarrito(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child:
                  carrito.isEmpty
                      ? const Center(child: Text("El carrito está vacío"))
                      : Column(
                        children: [
                          const Text(
                            "Carrito de compras",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: ListView.builder(
                              controller: controller,
                              itemCount: carrito.length,
                              itemBuilder: (context, index) {
                                final item = carrito[index];
                                return ListTile(
                                  leading: Image.asset(
                                    item.imagen,
                                    width: 40,
                                    height: 40,
                                  ),
                                  title: Text(item.nombreConTipo),
                                  subtitle: Text('Cantidad: ${item.cantidad}'),
                                  trailing: Text('\$${item.total}'),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text(
                                  'Total a pagar: ',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '\$${_calcularTotalCarrito()}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              carrito.clear();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("✅ Pedido realizado con éxito"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            icon: const Icon(Icons.check),
                            label: const Text("Realizar pedido"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
            );
          },
        );
      },
    );
  }

  int _calcularTotalCarrito() {
    return carrito.fold(0, (sum, item) => sum + item.total);
  }
}
