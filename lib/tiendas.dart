import 'package:flutter/material.dart';
import 'home_screen.dart'; // <-- IMPORTANTE: Ahora importa 'home_screen.dart'
import 'package:viniloteca/login_screen.dart'; // Importa LoginScreen

// --- WIDGET DE LA CABECERA (Copia idéntica a la de home_screen.dart) ---
class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  
  final String? nombreUsuario; // Acepta el usuario

  const MyAppBar({
    super.key, 
    this.nombreUsuario // Constructor
  });

  @override
  Widget build(BuildContext context) {
    // ... (El código de MyAppBar es EXACTAMENTE EL MISMO que en home_screen.dart) ...
    // ... (Incluyendo _buildLoginIcon y _buildProfileMenu) ...
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
            Expanded(
              flex: 1,
              child: IconButton(
                icon: const Icon(Icons.menu, size: 35, color: Colors.black),
                onPressed: () { 
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    print('Menú presionado'); 
                  }
                },
              ),
            ),
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      // Navega a HomeScreen (que está en home_screen.dart)
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
            (nombreUsuario == null)
              ? _buildLoginIcon(context)
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

  // WIDGET PARA USUARIO LOGUEADO
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


// --- PANTALLA DE LISTA DE TIENDAS (ACTUALIZADA) ---
class StoreListPage extends StatelessWidget {
  
  final String? nombreUsuario; // <-- ACEPTA EL USUARIO

  const StoreListPage({
    super.key, 
    this.nombreUsuario // <-- CONSTRUCTOR ACTUALIZADO
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Pasa el usuario al AppBar de esta página
      appBar: MyAppBar(nombreUsuario: nombreUsuario), 
      backgroundColor: const Color(0xFF800000),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildStoreCard(
              title: "Latimore Records",
              rating: 3,
              tags: "pop, rock, tag, tag, tag, tag, tag...",
              imagePath: "assets/store1.png",
            ),
            const SizedBox(height: 20),
            _buildStoreCard(
              title: "TotemTanz",
              rating: 4,
              tags: "hip hop, pop, rock, tag, tag, tag...",
              imagePath: "assets/store2.png",
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Helper para la Barra de Búsqueda ---
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: "Buscar...",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none, 
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          suffixIcon: const Icon(Icons.search, color: Colors.grey),
        ),
      ),
    );
  }

  // --- Helper para las Tarjetas de Tienda ---
  Widget _buildStoreCard({
    required String title,
    required int rating,
    required String tags,
    required String imagePath,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Columna Izquierda: Imagen y Puntos ---
          Expanded(
            flex: 2,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120, 
                      color: Colors.grey,
                      child: const Center(child: Text('Error', style: TextStyle(color: Colors.red))),
                    );
                  },
                ),
                // Puntos de paginación (simulados)
                Positioned(
                  bottom: 8.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDot(isActive: true),
                      _buildDot(isActive: false),
                      _buildDot(isActive: false),
                      _buildDot(isActive: false),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- Columna Derecha: Información ---
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Rating (Estrellas y texto)
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.yellow,
                          size: 20,
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        "$rating/5",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Tags
                  Text(
                    tags,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Descripción
                  const Text(
                    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text of the printing...",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper para los puntos de paginación ---
  Widget _buildDot({bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      width: 8.0,
      height: 8.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white54,
        shape: BoxShape.circle,
      ),
    );
  }
}