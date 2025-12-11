import 'package:flutter/material.dart';
import 'package:viniloteca/login_screen.dart';
import 'tiendas.dart'; 
import 'foros.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  
  final String? nombreUsuario;

  const MyAppBar({
    super.key, 
    this.nombreUsuario 
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFe6d5b5),
        border: Border(
          bottom: BorderSide(
            color: Colors.black,
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
                onPressed: () { 
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    print('Menú presionado en Home'); 
                  }
                },
              ),
            ),
            
            // 2. LOGO CENTRAL
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(nombreUsuario: nombreUsuario),
                    ),
                    (route) => false,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0), 
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.contain,
                    height: 75,
                  ),
                ),
              ),
            ),

            //3. ICONO DE PERFIL
            (nombreUsuario == null)
              ? _buildLoginIcon(context)
              : _buildProfileMenu(context, nombreUsuario!),
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

  Widget _buildProfileMenu(BuildContext context, String nombre) {
    return Expanded(
      flex: 1,
      child: Container(
        height: double.infinity,
        color: Colors.red,
        child: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'logout') {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen(nombreUsuario: null)), 
                (route) => false,
              );
            }
          },
          icon: const Icon(Icons.person, size: 35, color: Colors.white),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              enabled: false, 
              child: Text(
                nombre,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            const PopupMenuDivider(),
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

class HomeScreen extends StatelessWidget {
  
  final String? nombreUsuario;

  const HomeScreen({
    super.key, 
    this.nombreUsuario
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  imagePath: 'assets/imagen.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StoreListPage(nombreUsuario: nombreUsuario),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

              _buildMenuCard(
                context: context, 
                label: 'FOROS',
                imagePath: 'assets/imagenFondo1.png',                
 
                onTap: () {
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
    );
  }
}