import 'package:flutter/material.dart';
import 'home_screen.dart';

// 1. MODELO DE DATOS
class ForumPost {
  String title;
  String user;
  String tags;
  String imagePath;
  String dateFI;
  String dateUC;
  int likes;
  int dislikes;
  bool isHeartFilled;

  ForumPost({
    required this.title,
    required this.user,
    required this.tags,
    required this.imagePath,
    required this.dateFI,
    required this.dateUC,
    this.likes = 0,
    this.dislikes = 0,
    this.isHeartFilled = false,
  });
}

// 2. PANTALLA PRINCIPAL
class ForumListPage extends StatefulWidget {
  final String? nombreUsuario;

  const ForumListPage({super.key, this.nombreUsuario});

  @override
  State<ForumListPage> createState() => _ForumListPageState();
}

class _ForumListPageState extends State<ForumListPage> {

  final List<ForumPost> _allPosts = []; 
  
  List<ForumPost> _foundPosts = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _foundPosts = _allPosts;
  }
  bool _verificarSesion() {
    if (widget.nombreUsuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🔒 Debes iniciar sesión para realizar esta acción"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    return true;
  }
  //LÓGICA DE BÚSQUEDA
  void _runFilter(String keyword) {
    List<ForumPost> results = [];
    if (keyword.isEmpty) {
      results = _allPosts;
    } else {
      results = _allPosts
          .where((post) =>
              post.title.toLowerCase().contains(keyword.toLowerCase()) ||
              post.tags.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }
    setState(() {
      _foundPosts = results;
    });
  }

  //AÑADIR NUEVO TEMA
  void _addNewTopic(String title) {
    final now = DateTime.now();
    final dateString = "${now.day}/${now.month}/${now.year}";

    final newPost = ForumPost(
      title: title,
      user: widget.nombreUsuario!,
      tags: "nuevo, comunidad",
      imagePath: "assets/logo.png",
      dateFI: dateString,
      dateUC: dateString,
      likes: 0,
      dislikes: 0,
    );

    setState(() {
      _allPosts.insert(0, newPost); 
      _runFilter(_searchController.text);
    });
  }

  //DIÁLOGO PARA CREAR TEMA
  void _showAddTopicDialog() {
    if (!_verificarSesion()) return;

    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nuevo Tema"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Publicando como: ${widget.nombreUsuario}", 
                 style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 10),
            TextField(
              controller: titleController, 
              decoration: const InputDecoration(
                labelText: "Título del tema",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Cancelar")
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF800000)),
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                _addNewTopic(titleController.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Publicar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(nombreUsuario: widget.nombreUsuario),
      backgroundColor: const Color(0xFF800000),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              height: 40,
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black)),
              child: TextField(
                controller: _searchController,
                onChanged: _runFilter,
                textAlignVertical: TextAlignVertical.center,
                decoration: const InputDecoration(
                  hintText: "Buscar en foros...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  suffixIcon: Icon(Icons.search, color: Colors.black),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _showAddTopicDialog,
              child: Container(
                margin: const EdgeInsets.only(top: 15, right: 20, bottom: 5),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6D5B5),
                  border: Border.all(color: Colors.black),
                ),
                child: const Text("NUEVO TEMA", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),

          // LISTA DE POSTS
          Expanded(
            child: _foundPosts.isEmpty
              ? const Center(
                  child: Text(
                    "No hay temas aún.¡Sé el primero en publicar!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: _foundPosts.length,
                  itemBuilder: (context, index) {
                    return _buildForumCard(_foundPosts[index]);
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildForumCard(ForumPost post) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE6D5B5),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGEN
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(border: Border.all(color: Colors.black54)),
            child: Image.asset(
              post.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(color: Colors.grey, child: const Icon(Icons.music_note)),
            ),
          ),
          const SizedBox(width: 10),
          
          // CONTENIDO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(post.user, style: const TextStyle(fontSize: 14)),
                Text(post.tags, style: TextStyle(fontSize: 12, color: Colors.grey[700]), maxLines: 1),
                const SizedBox(height: 8),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('FI: ${post.dateFI}', style: const TextStyle(fontSize: 10)),
                        Text('UC: ${post.dateUC}', style: const TextStyle(fontSize: 10)),
                      ],
                    ),
                    // ICONOS DE INTERACCIÓN
                    Row(
                      children: [
                        // Corazón
                        InkWell(
                          onTap: () {
                            if (_verificarSesion()) {
                              setState(() => post.isHeartFilled = !post.isHeartFilled);
                            }
                          },
                          child: Icon(
                            post.isHeartFilled ? Icons.favorite : Icons.favorite_border,
                            color: post.isHeartFilled ? const Color(0xFF800000) : Colors.black,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Like
                        InkWell(
                          onTap: () {
                            if (_verificarSesion()) {
                              setState(() => post.likes++);
                            }
                          },
                          child: Column(
                            children: [
                              const Icon(Icons.thumb_up_alt_outlined, size: 24),
                              Text('${post.likes}', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Dislike
                        InkWell(
                          onTap: () {
                            if (_verificarSesion()) {
                              setState(() => post.dislikes++);
                            }
                          },
                          child: Column(
                            children: [
                              const Icon(Icons.thumb_down_alt_outlined, size: 24),
                              Text('${post.dislikes}', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}