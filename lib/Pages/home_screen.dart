import 'package:flutter/material.dart';
import '/widgets/animated_nav_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _allButtons = [
    {
      'label': "Explora nuestro menú:",
      'description': "Realiza tu pedido de manera rápida y sencilla",
      'icon': Icons.restaurant_menu,
      'route': "/menu",
      'color': Colors.amberAccent,
    },
    {
      'label': "Registro de ventas:",
      'description': "Control detallado de las transacciones del día.",
      'icon': Icons.receipt_long,
      'route': "/ventas",
      'color': Colors.lightGreenAccent,
    },
    {
      'label': "Históricos:",
      'description': "Registro de ventas de los últimos meses",
      'icon': Icons.bar_chart,
      'route': "/historicos",
      'color': Colors.lightBlueAccent,
    },
    {
      'label': "Planifica con anticipación:",
      'description':
          "Estimaciones sobre el uso de materia prima y producción necesaria.",
      'icon': Icons.event_note,
      'route': "/planifica",
      'color': Colors.orangeAccent,
    },
  ];

  List<Map<String, dynamic>> _filteredButtons = [];

  @override
  void initState() {
    super.initState();
    _filteredButtons = List.from(_allButtons);
    _searchController.addListener(_filterButtons);
  }

  void _filterButtons() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredButtons =
          _allButtons.where((button) {
            return button['label'].toLowerCase().contains(query) ||
                button['description'].toLowerCase().contains(query);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/fondo_empanadas.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'La Planchita',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Georgia',
                    letterSpacing: 1.2,
                    color: Colors.brown,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black26,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '"Sabor que une,\ncalidad que se siente"',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                    fontFamily: 'Times New Roman',
                    color: Colors.black54,
                    height: 1.3,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 12),

                // Barra de búsqueda
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _searchController.clear(),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Logo del negocio
                SizedBox(
                  height: 90,
                  child: Image.asset('assets/La_Planchita_Logo.png'),
                ),
                const SizedBox(height: 16),

                // Lista de botones filtrados
                Expanded(
                  child:
                      _filteredButtons.isNotEmpty
                          ? ListView.builder(
                            itemCount: _filteredButtons.length,
                            itemBuilder: (context, index) {
                              final item = _filteredButtons[index];
                              return AnimatedNavButton(
                                label: item['label'],
                                description: item['description'],
                                icon: item['icon'],
                                color: item['color'],
                                routeName: item['route'],
                              );
                            },
                          )
                          : const Center(
                            child: Text(
                              "No se encontraron coincidencias",
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
