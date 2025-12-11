import 'package:flutter/material.dart';
import 'home_screen.dart'; 
import 'InfoTiendaScreen.dart'; 

// 1. MODELO DE DATOS
// He añadido 'final int id' para que la base de datos funcione.
// Visualmente no cambia nada.
class Store {
  final int id; // <--- NECESARIO PARA LA BASE DE DATOS
  final String title;
  final int rating;
  final String tags;
  final String imagePath;
  final String description;

  Store({
    required this.id, // <--- AHORA REQUERIDO
    required this.title,
    required this.rating,
    required this.tags,
    required this.imagePath,
    required this.description,
  });
}

// 2. PANTALLA CON ESTADO
class StoreListPage extends StatefulWidget {
  final String? nombreUsuario;
  final int? userId; 

  const StoreListPage({super.key, this.nombreUsuario, this.userId});

  @override
  State<StoreListPage> createState() => _StoreListPageState();
}

class _StoreListPageState extends State<StoreListPage> {
  // --- TUS DATOS ---
  // He añadido el ID a cada tienda. Asegúrate de que coincida con tu Base de Datos.
  final List<Store> _allStores = [
    Store(
      id: 1, // <--- ID 1 (Base de Datos)
      title: "Latimore Records",
      rating: 3,
      tags: "pop, rock, indie, vinilos, clásicos",
      imagePath: "assets/Latimore.jpg",
      description: "Una tienda clásica en el corazón de la ciudad con una gran colección de vinilos vintage.",
    ),
    Store(
      id: 2, // <--- ID 2 (Base de Datos)
      title: "TotemTanz",
      rating: 5,
      tags: "metal, rock, gotico, instrumentos",
      imagePath: "assets/Totem.png",
      description: "Especialistas en sonidos oscuros y metal. También vendemos instrumentos.",
    ),
  ];

  // Lista que se muestra (filtrada)
  List<Store> _foundStores = [];

  @override
  void initState() {
    super.initState();
    _foundStores = _allStores;
  }

  // --- LÓGICA DE BÚSQUEDA (TUYA ORIGINAL) ---
  void _runFilter(String enteredKeyword) {
    List<Store> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allStores;
    } else {
      results = _allStores
          .where((store) =>
              store.title.toLowerCase().contains(enteredKeyword.toLowerCase()) ||
              store.tags.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundStores = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(nombreUsuario: widget.nombreUsuario, userId: widget.userId),
      backgroundColor: const Color(0xFF800000),
      body: Column(
        children: [
          // --- BUSCADOR INTERACTIVO (TUYO ORIGINAL) ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => _runFilter(value),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Buscar tienda o género...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: const Icon(Icons.search, color: Colors.grey),
              ),
            ),
          ),

          // --- LISTA DE TIENDAS ---
          Expanded(
            child: _foundStores.isNotEmpty
                ? ListView.builder(
                    itemCount: _foundStores.length,
                    itemBuilder: (context, index) {
                      return _buildStoreCard(_foundStores[index]);
                    },
                  )
                : const Center(
                    child: Text(
                      'No se encontraron tiendas',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // --- DISEÑO DE LA TARJETA (TUYO ORIGINAL) ---
  Widget _buildStoreCard(Store store) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InfoTiendaScreen(
              store: store,
              nombreUsuario: widget.nombreUsuario,
              userId: widget.userId, // Pasamos el ID del usuario
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Expanded(
              flex: 2,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Image.asset(
                    store.imagePath,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(height: 120, color: Colors.grey),
                  ),
                  Positioned(
                    bottom: 8.0,
                    child: Row(
                      children: List.generate(4, (index) => _buildDot(index == 0)),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < store.rating ? Icons.star : Icons.star_border,
                            color: Colors.yellow,
                            size: 18,
                          );
                        }),
                        const SizedBox(width: 5),
                        Text("${store.rating}/5",
                            style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                    Text(
                      store.tags,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontStyle: FontStyle.italic),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      store.description,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2.0),
      width: 6.0,
      height: 6.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white54,
        shape: BoxShape.circle,
      ),
    );
  }
}