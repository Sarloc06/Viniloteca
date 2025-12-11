import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:viniloteca/home_screen.dart';
import 'package:viniloteca/register_screen.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final String apiUrl = "http://localhost:3000/login"; 

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) return _showError("Rellena todos los campos");

    try {
      final response = await http.post(Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        if (res['success'] == true) {
          // EXTRAER DATOS
          final String nombre = res['data']['nombre'] ?? 'Usuario';
          final int userId = res['data']['id_usuario']; // ID IMPORTANTE

          Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => HomeScreen(nombreUsuario: nombre, userId: userId),
          ));
        } else {
          _showError(res['message'] ?? 'Error');
        }
      } else {
        _showError('Error servidor: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error conexión');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6D5B5),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 10), child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF800000), foregroundColor: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
            child: const Text('Registrarme'))),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Image.asset('assets/logo.png', height: 100),
              const SizedBox(height: 20),
              const Text('INICIAR SESIÓN', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Correo', filled: true, fillColor: Colors.white)),
              const SizedBox(height: 20),
              TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña', filled: true, fillColor: Colors.white)),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF800000), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
                onPressed: _login, child: const Text('ENTRAR')),
            ],
          ),
        ),
      ),
    );
  }
}