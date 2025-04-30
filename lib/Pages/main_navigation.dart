import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home_screen.dart';
import 'explorar_menu.dart';
import 'registro_ventas.dart';
import 'historicos.dart';
import 'planifica.dart';

class MainNavigation extends StatelessWidget {
  final int initialPage;

  const MainNavigation({super.key, this.initialPage = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: initialPage,
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Elimina la flecha de retroceso
          backgroundColor: const Color(0xFFFFC107),
          title: Text(
            'La Planchita',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: TabBar(
              isScrollable: false,
              indicatorColor: Colors.white,
              tabs: [
                _buildTab(icon: Icons.home, text: 'Inicio'),
                _buildTab(icon: Icons.fastfood, text: 'Pedidos'),
                _buildTab(icon: Icons.point_of_sale, text: 'Ventas'),
                _buildTab(icon: Icons.bar_chart, text: 'Histórico'),
                _buildTab(icon: Icons.calendar_today, text: 'Planifica'),
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            HomeScreen(),
            ExplorarMenu(),
            RegistroVentas(),
            Historicos(),
            Planifica(),
          ],
        ),
      ),
    );
  }

  Widget _buildTab({required IconData icon, required String text}) {
    return Tab(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
