import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vinoloteca',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const HomeScreen(),
    );
  }
}

// --- WIDGET DE LA CABECERA ---
class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

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
                onPressed: () {
                  print('Menú presionado');
                },
              ),
            ),
            
            // 2. LOGO CENTRAL (logo.png)
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0), 
                child: Image.asset(
                  'assets/logo.png', // Tu imagen de logo
                  fit: BoxFit.contain,
                  height: 75,
                ),
              ),
            ),

            // 3. Icono de Perfil (Derecha)
            Expanded(
              flex: 1,
              child: InkWell(
                onTap: () {
                  print('Perfil presionado');
                },
                child: Container(
                  height: double.infinity, 
                  color: Colors.red,
                  child: const Icon(Icons.person, size: 35, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100.0); 
}


// --- PANTALLA PRINCIPAL ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(),
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
                  hasBorder: true,
                  onTap: () {
                    print('Navegar a Tiendas');
                  },
                ),

                const SizedBox(height: 30),

                // Tarjeta 2: FOROS
                _buildMenuCard(
                  context: context, 
                  label: 'FOROS',
                  imagePath: 'assets/imagenFondo1.png', 
                  hasBorder: false,
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

  // --- WIDGET REUTILIZABLE PARA LAS TARJETAS (IMÁGENES CUADRADAS) ---
  Widget _buildMenuCard({
    required BuildContext context, 
    required String label,
    required String imagePath,
    required VoidCallback onTap,
    bool hasBorder = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Definimos un tamaño base para el lado del cuadrado.
    // Usaremos un 85% del ancho de la pantalla para dejar un poco de margen.
    final squareSize = screenWidth * 0.55; // <-- Tamaño adaptable y cuadrado

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: hasBorder ? const EdgeInsets.all(4.0) : EdgeInsets.zero,
        decoration: hasBorder
            ? BoxDecoration(
                border: Border.all(color: Colors.purple, width: 3),
              )
            : null,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Imagen de fondo de la tarjeta (ahora cuadrada)
            Image.asset(
              imagePath,
              width: squareSize, // <-- Ancho igual a la altura
              height: squareSize, // <-- Altura igual al ancho
              fit: BoxFit.cover, // Para que la imagen cubra el cuadrado
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
            
            // Etiqueta de texto de la tarjeta
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