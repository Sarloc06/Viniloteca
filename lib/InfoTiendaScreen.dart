import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart'; // Para detectar si es Web o Móvil
import 'home_screen.dart'; 
import 'tiendas.dart';     

// Definimos la clase Review localmente
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

  // --- TRADUCTOR DE BASE DE DATOS ---
  // Aquí es donde convertimos las columnas de MySQL a tu App
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      // Si la BD no manda nombre, ponemos 'Anónimo'
      user: json['nombre_usuario'] ?? 'Usuario', 
      // Convertimos el ID numérico a formato visual "#15"
      userId: json['id_usuario'] != null ? "#${json['id_usuario']}" : '#0000',
      date: json['fecha'] ?? '', // Si tu BD no tiene fecha, saldrá vacía
      // IMPORTANTE: Mapeamos 'texto' (BD) a 'text' (Flutter)
      text: json['texto'] ?? json['text'] ?? '', 
      // IMPORTANTE: Mapeamos 'valoracion' (BD) a 'rating' (Flutter)
      rating: (json['valoracion'] ?? json['rating'] ?? 5),
      avatarColor: Colors.blueAccent, 
    );
  }
}

class InfoTiendaScreen extends StatefulWidget {
  final Store store;
  final String? nombreUsuario;
  final int? userId; // <--- 1. AÑADIDO: Necesario para guardar reseñas

  const InfoTiendaScreen({
    super.key, 
    required this.store, 
    this.nombreUsuario,
    this.userId, // <--- 2. AÑADIDO
  });

  @override
  State<InfoTiendaScreen> createState() => _InfoTiendaScreenState();
}

class _InfoTiendaScreenState extends State<InfoTiendaScreen> {

  // --- DETECCIÓN AUTOMÁTICA DE URL ---
  String get baseUrl {
    if (kIsWeb) return "http://localhost:3000";
    return "http://10.0.2.2:3000";
  }
  
  List<Review> _reviews = []; 
  bool _isLoading = true; 

  @override
  void initState() {
    super.initState();
    _fetchReviews(); 
  }

  // --- OBTENER RESEÑAS (MODIFICADO PARA USAR ID) ---
  Future<void> _fetchReviews() async {
    try {
      // Usamos el ID de la tienda (ej: 1) en vez del nombre
      final url = Uri.parse('$baseUrl/reviews?id_tienda=${widget.store.id}');
      print("Cargando reseñas desde: $url");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          final List<dynamic> reviewsJson = data['data'];
          if (mounted) {
            setState(() {
              _reviews = reviewsJson.map((json) => Review.fromJson(json)).toList();
              _isLoading = false;
            });
          }
        } else {
          if (mounted) setState(() => _isLoading = false);
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
        print("Error al cargar reseñas: ${response.statusCode}");
      }
    } catch (e) {
      print("Error conexión: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- GUARDAR RESEÑA (MODIFICADO PARA ENVIAR IDs) ---
  Future<void> _postReview(String text, int rating) async {
    
    // Validamos que el usuario esté logueado
    if (widget.userId == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Reinicia la app e inicia sesión de nuevo.")),
      );
      return;
    }

    // 1. Optimistic UI (Se añade visualmente al instante)
    final newReview = Review(
      user: widget.nombreUsuario ?? "Yo",
      userId: "#${widget.userId}", 
      date: "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
      text: text,
      rating: rating,
      avatarColor: Colors.teal[200]!,
    );

    setState(() {
      _reviews.insert(0, newReview);
    });

    try {
      // 2. Enviamos al backend con los nombres de columnas correctos
      final bodyData = {
          'id_tienda': widget.store.id,  // <--- Enviamos ID (número)
          'id_usuario': widget.userId,   // <--- Enviamos ID (número)
          'text': text,
          'rating': rating,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/add_review'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("¡Reseña guardada en la base de datos!"), backgroundColor: Colors.green),
        );
      } else {
        print("Error Backend: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al guardar en el servidor"), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      print("Excepción: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // Método para verificar sesión
  bool _verificarSesion() {
    if (widget.userId == null) { // Verificamos por ID, es más seguro
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
      appBar: MyAppBar(nombreUsuario: widget.nombreUsuario, userId: widget.userId),
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
                  
                  // Quitamos el 'const' porque ahora el valor puede cambiar
                  Text(
                    widget.store.location, // <--- AHORA LEE DE LA BASE DE DATOS
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
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