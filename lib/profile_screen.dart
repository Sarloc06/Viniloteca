import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Para detectar si es Web

class ProfileScreen extends StatefulWidget {
  final int userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  bool _isEditingDescription = false;
  bool _isLoading = true;
  
  final ImagePicker _picker = ImagePicker();

  // Datos del perfil
  String _userName = "";
  String _userToken = "";
  int _userContributions = 0;
  String _memberSince = "";
  String _profileImageUrl = ""; 

  // URLs (Usa localhost para Chrome)
  final String baseUrl = "http://localhost:3000"; 
  late final String getProfileUrl = "$baseUrl/profile";
  late final String updateDescUrl = "$baseUrl/update_description";
  late final String uploadPhotoUrl = "$baseUrl/upload_profile_picture";

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final response = await http.get(Uri.parse('$getProfileUrl?id=${widget.userId}'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final userData = data['data'];
          if (!mounted) return;
          setState(() {
            _userName = userData['nombre'];
            _userToken = userData['token'];
            _userContributions = userData['aportaciones'];
            _memberSince = userData['fecha_union'];
            _descriptionController.text = userData['descripcion'];
            _profileImageUrl = userData['ruta_foto'] ?? ""; 
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error perfil: $e");
      if(mounted) setState(() { _isLoading = false; });
    }
  }

  // --- SUBIR FOTO (COMPATIBLE CON WEB Y MÓVIL) ---
  Future<void> _pickAndUploadImage() async {
    try {
      // 1. Abrir galería
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile == null) return; // Usuario canceló

      setState(() { _isLoading = true; });

      // 2. Preparar el envío
      var request = http.MultipartRequest('POST', Uri.parse(uploadPhotoUrl));
      
      request.fields['id_usuario'] = widget.userId.toString();
      request.fields['token'] = _userToken; 
      
      // 3. Añadir la imagen (Diferente para Web y Móvil)
      if (kIsWeb) {
        // EN WEB: Leemos los bytes
        var bytes = await pickedFile.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes('image', bytes, filename: 'upload.jpg'));
      } else {
        // EN MÓVIL: Usamos la ruta
        request.files.add(await http.MultipartFile.fromPath('image', pickedFile.path));
      }

      // 4. Enviar
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            // Truco del timestamp para refrescar la imagen
            _profileImageUrl = "${data['data']['url']}?v=${DateTime.now().millisecondsSinceEpoch}";
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto actualizada'), backgroundColor: Colors.green));
        } else {
          _showError(data['message']);
          setState(() { _isLoading = false; });
        }
      } else {
        _showError('Error al subir imagen');
        setState(() { _isLoading = false; });
      }

    } catch (e) {
      _showError('Error: $e');
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _saveDescription() async {
    try {
      final response = await http.post(
        Uri.parse(updateDescUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_usuario': widget.userId, 'descripcion': _descriptionController.text}),
      );
      if (response.statusCode == 200) {
        setState(() { _isEditingDescription = false; });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Descripción actualizada'), backgroundColor: Colors.green));
      }
    } catch (e) {
      _showError('Error al guardar: $e');
    }
  }
  
  void _showError(String msg) {
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(backgroundColor: Color(0xFFE6D5B5), body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFFE6D5B5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE6D5B5), elevation: 0, centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('Mi Perfil', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECCIÓN DE FOTO (Stack) ---
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      // Foto Grande (Clicable también)
                      GestureDetector(
                        onTap: _pickAndUploadImage, 
                        child: CircleAvatar(
                          radius: 50, backgroundColor: Colors.grey[300],
                          backgroundImage: _profileImageUrl.isNotEmpty ? NetworkImage(_profileImageUrl) : null,
                          child: _profileImageUrl.isEmpty ? Icon(Icons.person, size: 60, color: Colors.grey[600]) : null,
                        ),
                      ),
                      // Botón Rojo Pequeño
                      GestureDetector(
                        onTap: _pickAndUploadImage, 
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.red[800],
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_userName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                        Text('#$_userToken', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Aportaciones: $_userContributions', style: const TextStyle(fontSize: 16)),
                            Text('Desde: $_memberSince', style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text('Descripción:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              // ... (Resto igual)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black)),
                child: Row(
                  children: [
                    Expanded(
                      child: _isEditingDescription
                          ? TextFormField(controller: _descriptionController, maxLines: null, decoration: const InputDecoration(border: InputBorder.none, hintText: 'Escribe algo...'))
                          : Text(_descriptionController.text.isEmpty ? "Sin descripción" : _descriptionController.text, style: const TextStyle(fontSize: 16)),
                    ),
                    IconButton(
                      icon: Icon(_isEditingDescription ? Icons.check : Icons.edit, color: Colors.black),
                      onPressed: () {
                        setState(() { if (_isEditingDescription) _saveDescription(); else _isEditingDescription = true; });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}