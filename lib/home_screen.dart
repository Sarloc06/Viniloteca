import 'package:flutter/material.dart';
import 'package:viniloteca/login_screen.dart'; 
import 'package:viniloteca/profile_screen.dart'; // Importa la pantalla de perfil
import 'tiendas.dart'; // <-- IMPORTANTE: Importa Tiendas
import 'foros.dart';   // <-- IMPORTANTE: Importa Foros

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? nombreUsuario;
  final int? userId; // ID del usuario logueado

  const MyAppBar({super.key, this.nombreUsuario, this.userId});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFe6d5b5),
        border: Border(bottom: BorderSide(color: Colors.black, width: 3.0)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Menú Hamburguesa
            Expanded(
              flex: 1,
              child: IconButton(
                icon: const Icon(Icons.menu, size: 35, color: Colors.black),
                onPressed: () {
                  // Si hay historial de navegación (ej: estamos en tiendas), volvemos atrás
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            // Logo (Interactivo para volver a Inicio)
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen(nombreUsuario: nombreUsuario, userId: userId)),
                    (route) => false,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0), 
                  child: Image.asset('assets/logo.png', fit: BoxFit.contain, height: 75),
                ),
              ),
            ),
            // Perfil (Invitado o Logueado)
            (nombreUsuario == null)
              ? _buildLoginIcon(context)
              : _buildProfileMenu(context, nombreUsuario!, userId!),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginIcon(BuildContext context) {
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
        },
        child: Container(
          height: double.infinity, color: Colors.red,
          child: const Icon(Icons.person, size: 35, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildProfileMenu(BuildContext context, String nombre, int id) {
    return Expanded(
      flex: 1,
      child: Container(
        height: double.infinity, color: Colors.red,
        child: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'logout') {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()), 
                (route) => false,
              );
            } else if (value == 'profile') {
              // NAVEGAR AL PERFIL
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen(userId: id)),
              );
            }
          },
          icon: const Icon(Icons.person, size: 35, color: Colors.white),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              enabled: false, 
              child: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(value: 'profile', child: Text('Ir al perfil')),
            const PopupMenuItem<String>(value: 'logout', child: Text('Cerrar Sesión')),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100.0); 
}

class HomeScreen extends StatelessWidget {
  final String? nombreUsuario;
  final int? userId;

  const HomeScreen({super.key, this.nombreUsuario, this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(nombreUsuario: nombreUsuario, userId: userId), 
      backgroundColor: const Color(0xFF800000), 
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 30),
                
                // TARJETA TIENDAS
                _buildMenuCard(
                  context: context, 
                  label: 'TIENDAS', 
                  imagePath: 'assets/imagen.png', 
                  hasBorder: false, // <-- CAMBIO: Borde desactivado
                  onTap: () {
                    // NAVEGACIÓN A TIENDAS
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // Pasamos el usuario para mantener la sesión
                        builder: (context) => StoreListPage(nombreUsuario: nombreUsuario),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 30),
                
                // TARJETA FOROS
                _buildMenuCard(
                  context: context, 
                  label: 'FOROS', 
                  imagePath: 'assets/imagenFondo1.png', 
                  hasBorder: false, 
                  onTap: () {
                    // NAVEGACIÓN A FOROS
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForumListPage(nombreUsuario: nombreUsuario),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({required BuildContext context, required String label, required String imagePath, required VoidCallback onTap, bool hasBorder = false}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final squareSize = screenWidth * 0.55;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: hasBorder ? const EdgeInsets.all(4.0) : EdgeInsets.zero,
        decoration: hasBorder ? BoxDecoration(border: Border.all(color: Colors.purple, width: 3)) : null,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(imagePath, width: squareSize, height: squareSize, fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(width: squareSize, height: squareSize, color: Colors.grey[300])),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              child: Text(label, style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ),
          ],
        ),
      ),
    );
  }
}