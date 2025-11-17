import 'package:flutter/material.dart';
import 'package:viniloteca/login_screen.dart'; // Para navegar a Login

// --- WIDGET DE LA CABECERA (ACTUALIZADO) ---
class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  
  // Acepta un nombre de usuario, que puede ser nulo si es un invitado
  final String? nombreUsuario;

  const MyAppBar({
    super.key, 
    this.nombreUsuario // Constructor actualizado
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFe6d5b5), // Tonalidad beige
        border: Border(
          bottom: BorderSide(
            color: Colors.black, // Barra negra
            width: 3.0,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 1. Icono de Menú (Izquierda)
            Expanded(
              flex: 1,
              child: IconButton(
                icon: const Icon(Icons.menu, size: 35, color: Colors.black),
                onPressed: () { print('Menú presionado'); },
              ),
            ),
            
            // 2. LOGO CENTRAL (logo.png)
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0), 
                child: Image.asset(
                  'assets/logo.png', // Asegúrate de tener esta imagen
                  fit: BoxFit.contain,
                  height: 75,
                ),
              ),
            ),

            // --- 3. ICONO DE PERFIL (DINÁMICO) ---
            // Comprueba si el nombre de usuario es nulo.
            (nombreUsuario == null)
              // SI ES NULO (invitado): Muestra el botón de ir a Login
              ? _buildLoginIcon(context)
              // SI NO ES NULO (logueado): Muestra el menú de perfil
              : _buildProfileMenu(context, nombreUsuario!),
          ],
        ),
      ),
    );
  }

  // WIDGET PARA INVITADO
  Widget _buildLoginIcon(BuildContext context) {
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: () {
          // Navega a la pantalla de login
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        },
        child: Container(
          height: double.infinity, 
          color: Colors.red,
          child: const Icon(Icons.person, size: 35, color: Colors.white),
        ),
      ),
    );
  }

  // WIDGET PARA USUARIO LOGUEADO (¡NUEVO!)
  Widget _buildProfileMenu(BuildContext context, String nombre) {
    return Expanded(
      flex: 1,
      child: Container(
        height: double.infinity,
        color: Colors.red, // Mantiene el fondo rojo
        child: PopupMenuButton<String>(
          onSelected: (value) {
            // Lógica de Cerrar Sesión
            if (value == 'logout') {
              // Vuelve a la HomeScreen (como invitado)
              // y borra todo el historial anterior
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()), 
                (route) => false, // Elimina todas las rutas anteriores
              );
            }
          },
          // Este es el icono (igual que el de invitado)
          icon: const Icon(Icons.person, size: 35, color: Colors.white),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            // 1. El nombre del usuario (no se puede pulsar)
            PopupMenuItem<String>(
              enabled: false, 
              child: Text(
                nombre,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            const PopupMenuDivider(),
            // 2. El botón de Cerrar Sesión
            const PopupMenuItem<String>(
              value: 'logout',
              child: Text('Cerrar Sesión'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100.0); 
}


// --- PANTALLA PRINCIPAL (ACTUALIZADA) ---
class HomeScreen extends StatelessWidget {
  
  // HomeScreen ahora acepta un nombre de usuario (puede ser nulo)
  final String? nombreUsuario;

  const HomeScreen({
    super.key, 
    this.nombreUsuario // Constructor actualizado
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Pasa el nombre de usuario al AppBar
      appBar: MyAppBar(nombreUsuario: nombreUsuario), 
      backgroundColor: const Color(0xFF800000), 
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 30),

                // Tarjeta 1: TIENDAS
                _buildMenuCard(
                  context: context, 
                  label: 'TIENDAS',
                  imagePath: 'assets/imagen.png', // Asegúrate de tener esta imagen
                  
                  onTap: () {
                    print('Navegar a Tiendas');
                  },
                ),

                const SizedBox(height: 30),

                // Tarjeta 2: FOROS
                _buildMenuCard(
                  context: context, 
                  label: 'FOROS',
                  imagePath: 'assets/imagenFondo1.png', // Asegúrate de tener esta imagen
                  
                  onTap: () {
                    print('Navegar a Foros');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET REUTILIZABLE PARA LAS TARJETAS (Sin cambios) ---
  Widget _buildMenuCard({
    required BuildContext context, 
    required String label,
    required String imagePath,
    required VoidCallback onTap,
    
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final squareSize = screenWidth * 0.55;

    return InkWell(
      onTap: onTap,
      child: Container(
        
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              imagePath,
              width: squareSize,
              height: squareSize,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: squareSize,
                  height: squareSize,
                  color: Colors.grey[300],
                  child: Center(
                    child: Text(
                      'Error al cargar: $imagePath', 
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                );
              },
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}