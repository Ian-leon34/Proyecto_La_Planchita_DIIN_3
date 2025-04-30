import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'main_navigation.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Menú Principal - La Planchita',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange, fontFamily: 'Arial'),
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomeScreen(), // Inicio
        '/menu': (context) => const MainNavigation(initialPage: 1), // Pedidos
        '/ventas': (context) => const MainNavigation(initialPage: 2), // Ventas
        '/historicos':
            (context) => const MainNavigation(initialPage: 3), // Históricos
        '/planifica':
            (context) => const MainNavigation(initialPage: 4), // Planifica
      },
    );
  }
}
