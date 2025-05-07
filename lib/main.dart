import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'pages/register_page.dart';
import 'pages/home_screen.dart';
import 'pages/main_navigation.dart';
import 'services/user_service.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<String> _usuariosRegistrados = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    setState(() {
      _isLoading = true;
    });

    final usuarios = await UserService.getRegisteredUsers();

    setState(() {
      _usuariosRegistrados = usuarios;
      _isLoading = false;
    });
  }

  void _mostrarSnackbar({
    required String titulo,
    required String mensaje,
    required ContentType tipo,
  }) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: titulo,
        message: mensaje,
        contentType: tipo,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _eliminarTodosLosUsuarios() async {
    // Mostrar diálogo de confirmación
    final confirmacion = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: const Text(
              '¿Estás seguro de que deseas eliminar TODOS los usuarios registrados? Esta acción no se puede deshacer.',
            ),
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
        _isLoading = true;
      });

      await UserService.deleteAllUsers();

      _mostrarSnackbar(
        titulo: 'Base de datos eliminada',
        mensaje: 'Se han eliminado todos los usuarios correctamente.',
        tipo: ContentType.success,
      );

      await _cargarUsuarios(); // Recargar la lista (ahora vacía)
    }
  }

  Future<void> _eliminarUsuario(String username) async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: Text(
              '¿Estás seguro de que deseas eliminar el usuario "$username"?',
            ),
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
      final resultado = await UserService.deleteUser(username);

      if (resultado) {
        _mostrarSnackbar(
          titulo: 'Usuario eliminado',
          mensaje: 'El usuario $username ha sido eliminado correctamente.',
          tipo: ContentType.success,
        );
        _cargarUsuarios(); // Recargar la lista
      } else {
        _mostrarSnackbar(
          titulo: 'Error',
          mensaje: 'No se pudo eliminar el usuario $username.',
          tipo: ContentType.failure,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Administración de Usuarios',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gestión de la Base de Datos',
                                style: GoogleFonts.roboto(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Desde aquí puedes administrar los usuarios registrados en la aplicación.',
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(Icons.people, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Total de usuarios: ${_usuariosRegistrados.length}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _eliminarTodosLosUsuarios,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                icon: const Icon(Icons.delete_forever),
                                label: const Text(
                                  'Eliminar toda la base de datos',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Usuarios Registrados',
                        style: GoogleFonts.roboto(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child:
                            _usuariosRegistrados.isEmpty
                                ? const Center(
                                  child: Text(
                                    'No hay usuarios registrados',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                                : ListView.builder(
                                  itemCount: _usuariosRegistrados.length,
                                  itemBuilder: (context, index) {
                                    final username =
                                        _usuariosRegistrados[index];
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: ListTile(
                                        leading: const CircleAvatar(
                                          child: Icon(Icons.person),
                                        ),
                                        title: Text(username),
                                        trailing: IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed:
                                              () => _eliminarUsuario(username),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}

void main() {
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'La Planchita',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(textTheme: GoogleFonts.robotoTextTheme()),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/registro':
            (context) => const RegisterPage(), // Añadimos ruta para registro
        '/home': (context) => const HomeScreen(),
        '/menu': (context) => const MainNavigation(initialPage: 1),
        '/ventas': (context) => const MainNavigation(initialPage: 2),
        '/historicos': (context) => const MainNavigation(initialPage: 3),
        '/planifica': (context) => const MainNavigation(initialPage: 4),
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _hovering = false;
  bool _isLoading = false;

  void _mostrarSnackbar({
    required String titulo,
    required String mensaje,
    required ContentType tipo,
  }) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: titulo,
        message: mensaje,
        contentType: tipo,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _iniciarSesion() async {
    final usuario = _userController.text.trim();
    final contrasena = _passwordController.text.trim();

    if (usuario.isEmpty || contrasena.isEmpty) {
      _mostrarSnackbar(
        titulo: 'Campos vacíos',
        mensaje: 'Por favor completa todos los campos.',
        tipo: ContentType.failure,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Primero verificamos si es el admin (acceso especial)
    if (usuario == "admin" && contrasena == "12345") {
      _mostrarSnackbar(
        titulo: '¡Bienvenido Administrador!',
        mensaje: 'Acceso exitoso como administrador.',
        tipo: ContentType.success,
      );

      // Mostrar un diálogo para elegir entre el panel normal o el de administración
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Panel de Administración'),
                content: const Text(
                  '¿Deseas ir al panel de administración de usuarios o al panel normal?',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Cerrar el diálogo
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    child: const Text('Panel Normal'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Cerrar el diálogo
                      // En lugar de usar rutas, creamos directamente la página
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AdminPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: const Text('Panel de Administración'),
                  ),
                ],
              ),
        );
      }
    } else {
      // Si no es admin, verificamos con el servicio de usuarios
      final loginExitoso = await UserService.loginUser(usuario, contrasena);

      if (loginExitoso) {
        _mostrarSnackbar(
          titulo: '¡Bienvenido!',
          mensaje: 'Acceso exitoso.',
          tipo: ContentType.success,
        );

        Future.delayed(const Duration(milliseconds: 1300), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        });
      } else {
        _mostrarSnackbar(
          titulo: 'Acceso denegado',
          mensaje: 'Usuario o contraseña incorrectos.',
          tipo: ContentType.failure,
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/fondo.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.6),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(30),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage('assets/logo.jpg'),
                      backgroundColor: Colors.transparent,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Bienvenido a",
                      style: GoogleFonts.roboto(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "La Planchita",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.4),
                            offset: const Offset(2, 2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _userController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Usuario',
                        labelStyle: const TextStyle(color: Colors.white),
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white70),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.blueAccent,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        labelStyle: const TextStyle(color: Colors.white),
                        prefixIcon: const Icon(Icons.lock, color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white70),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.blueAccent,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    MouseRegion(
                      onEnter: (_) => setState(() => _hovering = true),
                      onExit: (_) => setState(() => _hovering = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow:
                              _hovering
                                  ? [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.6),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                  : [],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _iniciarSesion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 100,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Text(
                                    'Ingreso',
                                    style: GoogleFonts.roboto(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/registro');
                      },
                      child: Text(
                        '¿No tienes cuenta? Crear una',
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: GoogleFonts.roboto(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
