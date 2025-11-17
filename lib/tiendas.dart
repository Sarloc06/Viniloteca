import 'package:flutter/material.dart';
import 'main.dart'; // <-- ¡IMPORTANTE! Añadido para que conozca HomeScreen

// --- WIDGET DE LA CABECERA (LOGO NAVEGABLE) ---
class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoHeight = screenWidth * 0.2;
    final iconSize = screenWidth * 0.09;

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
                icon: Icon(Icons.menu, size: iconSize, color: Colors.black),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context); // Vuelve a la pantalla anterior
                  }
                  print('Menú presionado');
                },
              ),
            ),
            
            // --- CAMBIO AQUÍ ---
            Expanded(
              flex: 2,
              child: GestureDetector( // 1. Envuelto con GestureDetector
                onTap: () { // 2. Añadida la acción onTap
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (Route<dynamic> route) => false, // Borra todas las rutas
                  );
                },
                child: Padding( // 3. El logo original
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.contain,
                    height: logoHeight,
                  ),
                ),
              ),
            ),
            // --- FIN DEL CAMBIO ---

            Expanded(
              flex: 1,
              child: InkWell(
                onTap: () {
                  print('Perfil presionado');
                },
                child: Container(
                  height: double.infinity,
                  color: Colors.red,
                  child: Icon(Icons.person, size: iconSize, color: Colors.white),
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

// --- PANTALLA DE LISTA DE TIENDAS (Sin cambios aquí) ---
class StoreListPage extends StatelessWidget {
  const StoreListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(), // Usa la cabecera actualizada
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

  // Helper (Sin cambios)
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

  // Helper (Sin cambios)
  Widget _buildStoreCard(
      {required String title,
      required int rating,
      required String tags,
      required String imagePath}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      child: const Center(
                          child:
                              Text('Error', style: TextStyle(color: Colors.red))),
                    );
                  },
                ),
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
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 4),
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
                  Text(
                    tags,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
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

  // Helper (Sin cambios)
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