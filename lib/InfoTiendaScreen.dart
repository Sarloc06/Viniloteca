import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Importar http
import 'dart:convert'; // Importar convert
import 'home_screen.dart'; // Para el AppBar
import 'tiendas.dart';     // Para acceder a la clase Store

// Definimos la clase Review aquí localmente
class Review {
  final String user;
  final String userId;
  final String date;
  final String text;
  final int rating;
  final Color avatarColor;

  Review({
    required this.user,
    required this.userId,
    required this.date,
    required this.text,
    required this.rating,
    required this.avatarColor,
  });

  // Método factory para crear una Review desde JSON (Base de datos)
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      user: json['user'] ?? 'Anónimo',
      userId: json['userId'] ?? '#0000',
      date: json['date'] ?? '',
      text: json['text'] ?? '',
      rating: json['rating'] ?? 5,
      avatarColor: Colors.blueAccent, // Color por defecto al cargar
    );
  }
}

class InfoTiendaScreen extends StatefulWidget {
  final Store store;
  final String? nombreUsuario;

  const InfoTiendaScreen({
    super.key, 
    required this.store, 
    this.nombreUsuario
  });

  @override
  State<InfoTiendaScreen> createState() => _InfoTiendaScreenState();
}

class _InfoTiendaScreenState extends State<InfoTiendaScreen> {

  // URL del Backend (Igual que en tu perfil: usa 10.0.2.2 para emulador Android)
  final String baseUrl = "http://localhost:3000"; 
  
  List<Review> _reviews = []; // Lista vacía, se llenará desde la BD
  bool _isLoading = true; // Para mostrar carga inicial

  @override
  void initState() {
    super.initState();
    _fetchReviews(); // Cargar reseñas al entrar
  }

  // --- OBTENER RESEÑAS DE LA BASE DE DATOS ---
  Future<void> _fetchReviews() async {
    try {
      // Simulamos la URL: /reviews?store=NombreTienda
      // Asegúrate de que tu backend tenga este endpoint
      final response = await http.get(Uri.parse('$baseUrl/reviews?store=${widget.store.title}'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> reviewsJson = data['data'];
          setState(() {
            _reviews = reviewsJson.map((json) => Review.fromJson(json)).toList();
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = false);
        print("Error al cargar reseñas: ${response.statusCode}");
      }
    } catch (e) {
      print("Error conexión: $e");
      setState(() => _isLoading = false);
    }
  }

  // --- GUARDAR RESEÑA EN LA BASE DE DATOS ---
  Future<void> _postReview(String text, int rating) async {
    // 1. Añadimos visualmente primero (Optimistic UI)
    final newReview = Review(
      user: widget.nombreUsuario!,
      userId: "#User", 
      date: "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
      text: text,
      rating: rating,
      avatarColor: Colors.teal[200]!,
    );

    setState(() {
      _reviews.insert(0, newReview);
    });

    try {
      // 2. Enviamos al backend
      final response = await http.post(
        Uri.parse('$baseUrl/add_review'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'store': widget.store.title,
          'user': widget.nombreUsuario,
          'text': text,
          'rating': rating,
          'date': newReview.date,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("¡Reseña guardada en la base de datos!"), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al guardar en el servidor"), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // Método para verificar sesión
  bool _verificarSesion() {
    if (widget.nombreUsuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🔒 Inicia sesión para dejar una reseña"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    return true;
  }

  // Método para añadir reseña
  void _mostrarDialogoResena() {
    if (!_verificarSesion()) return;

    final textController = TextEditingController();
    double rating = 5.0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Escribe tu reseña"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Publicando como: ${widget.nombreUsuario}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: textController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: "Cuéntanos tu experiencia...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Puntuación: "),
                      DropdownButton<double>(
                        value: rating,
                        items: [1, 2, 3, 4, 5].map((e) => DropdownMenuItem(value: e.toDouble(), child: Text(e.toStringAsFixed(0)))).toList(),
                        onChanged: (val) {
                          setDialogState(() => rating = val!);
                        },
                      )
                    ],
                  )
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF800000)),
                  onPressed: () {
                    if (textController.text.isNotEmpty) {
                      Navigator.pop(context); // Cerrar diálogo primero
                      // Llamamos a la función que guarda en la BD
                      _postReview(textController.text, rating.toInt());
                    }
                  },
                  child: const Text("Publicar", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(nombreUsuario: widget.nombreUsuario),
      backgroundColor: const Color(0xFFE6D5B5), 
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            // --- 1. IMAGEN DE CABECERA ---
            Container(
              height: 200,
              color: Colors.grey[400],
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    widget.store.imagePath,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.store, size: 80, color: Colors.white54),
                  ),
                  Positioned(
                    bottom: 10,
                    child: Row(
                      children: List.generate(5, (index) => 
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                            color: index == 2 ? Colors.white : Colors.white54,
                            shape: BoxShape.circle,
                          ),
                        )
                      ),
                    ),
                  )
                ],
              ),
            ),

            // --- 2. INFORMACIÓN DE LA TIENDA ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.store.title,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Serif'),
                        ),
                      ),
                      Row(
                        children: [
                          ...List.generate(5, (index) => Icon(
                            index < widget.store.rating ? Icons.star : Icons.star_border,
                            color: Colors.amber, size: 20,
                          )),
                          const SizedBox(width: 5),
                          Text("${widget.store.rating}/5", style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  
                  const Text("C. Amor de Dios, 66, Casco Antiguo, 41002 Sevilla", style: TextStyle(fontSize: 14, color: Colors.black87)),
                  const SizedBox(height: 15),

                  Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.black), color: const Color(0xFFDCC8A8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black))),
                          child: const Text("ETIQUETAS", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(widget.store.tags, style: TextStyle(color: Colors.grey[700], fontStyle: FontStyle.italic), textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(widget.store.description, style: const TextStyle(fontSize: 15, height: 1.2)),
                  const SizedBox(height: 15),
                  Row(
                    children: const [Icon(Icons.share, size: 30), SizedBox(width: 15), Icon(Icons.album, size: 30)],
                  ),
                ],
              ),
            ),

            // --- 3. SECCIÓN DE RESEÑAS (Interactiva con BD) ---
            Container(
              color: const Color(0xFF800000),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: _mostrarDialogoResena,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF800000),
                          border: Border.all(color: Colors.white),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 2, offset: const Offset(1,1))],
                        ),
                        child: const Text("AÑADIR RESEÑA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // LISTA DE RESEÑAS CON CARGA
                  if (_isLoading)
                     const Padding(
                       padding: EdgeInsets.all(20.0),
                       child: CircularProgressIndicator(color: Colors.white),
                     )
                  else if (_reviews.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text("No hay reseñas aún. ¡Sé el primero!", style: TextStyle(color: Colors.white70)),
                    )
                  else
                    ..._reviews.map((review) => _buildReviewCard(review)).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50, height: 50, color: review.avatarColor,
                child: const Icon(Icons.person, size: 40, color: Colors.black54),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.white),
                            children: [
                              TextSpan(text: review.user, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const TextSpan(text: "  "),
                              TextSpan(text: review.userId, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            ]
                          ),
                        ),
                        Text(review.date, style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(review.text, style: const TextStyle(color: Colors.white, fontSize: 13)),
                    const SizedBox(height: 5),
                    Row(
                      children: List.generate(5, (index) => Icon(
                        index < review.rating ? Icons.star : Icons.star_border,
                        color: Colors.amber, size: 16,
                      )),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              Icon(Icons.thumb_up_alt_outlined, color: Colors.white, size: 20),
              SizedBox(width: 5),
              Text("0", style: TextStyle(color: Colors.white, fontSize: 12)),
              SizedBox(width: 15),
              Icon(Icons.thumb_down_alt_outlined, color: Colors.white, size: 20),
              SizedBox(width: 5),
              Text("0", style: TextStyle(color: Colors.white, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }
}