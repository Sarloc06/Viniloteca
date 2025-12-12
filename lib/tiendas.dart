import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // IMPORTANTE
import 'dart:convert'; // IMPORTANTE
import 'package:flutter/foundation.dart'; // Para detectar Web/Móvil
import 'home_screen.dart'; 
import 'InfoTiendaScreen.dart'; 

class Store {
  final int id;
  final String title;
  final int rating;
  final String tags;
  final String imagePath;
  final String description;
  final String location; // <--- 1. AÑADIMOS ESTO

  Store({
    required this.id,
    required this.title,
    required this.rating,
    required this.tags,
    required this.imagePath,
    required this.description,
    required this.location, // <--- 2. AÑADIMOS ESTO
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      title: json['title'] ?? 'Sin nombre',
      rating: json['rating'] ?? 0,
      tags: json['tags'] ?? '',
      imagePath: json['imagePath'] ?? 'assets/logo.png',
      description: json['description'] ?? '',
      location: json['location'] ?? 'Dirección no disponible', // <--- 3. AÑADIMOS ESTO
    );
  }
}

class StoreListPage extends StatefulWidget {
  final String? nombreUsuario;
  final int? userId; 

  const StoreListPage({super.key, this.nombreUsuario, this.userId});

  @override
  State<StoreListPage> createState() => _StoreListPageState();
}

class _StoreListPageState extends State<StoreListPage> {
  
  // URL Dinámica
  String get baseUrl {
    if (kIsWeb) return "http://localhost:3000";
    return "http://10.0.2.2:3000";
  }

  List<Store> _allStores = []; // Empezamos con lista vacía
  List<Store> _foundStores = [];
  bool _isLoading = true; // Para mostrar carga

  @override
  void initState() {
    super.initState();
    _fetchStores(); // Llamamos a la base de datos al iniciar
  }

  // --- PETICIÓN A LA BASE DE DATOS ---
  Future<void> _fetchStores() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/stores'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> storesJson = data['data'];
          setState(() {
            _allStores = storesJson.map((json) => Store.fromJson(json)).toList();
            _foundStores = _allStores;
            _isLoading = false;
          });
        }
      } else {
        print("Error servidor: ${response.statusCode}");
      }
    } catch (e) {
      print("Error de conexión: $e");
      setState(() => _isLoading = false);
    }
  }

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

          // LISTA DE TIENDAS O CARGA
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : _foundStores.isNotEmpty
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

  // --- TU DISEÑO ORIGINAL (SIN CAMBIOS) ---
  Widget _buildStoreCard(Store store) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InfoTiendaScreen(
              store: store,
              nombreUsuario: widget.nombreUsuario,
              userId: widget.userId,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // IMPORTANTE: Aquí puedes usar Image.asset si guardas las rutas locales 
                  // o Image.network si las imágenes están en internet
                  Image.asset(
                    store.imagePath,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(height: 120, color: Colors.grey, child: const Icon(Icons.store)),
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