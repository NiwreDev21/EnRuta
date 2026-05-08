import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import 'registro_screen.dart';
import 'chofer_screen.dart';
import 'pasajero_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _recordarEmail = false;

  @override
  void initState() {
    super.initState();
    _cargarEmailGuardado();
  }

  Future<void> _cargarEmailGuardado() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email_guardado');
    if (email != null) {
      setState(() {
        emailController.text = email;
        _recordarEmail = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade900, Colors.blue.shade300],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.directions_bus, size: 80, color: Colors.blue.shade900),
                    SizedBox(height: 20),
                    Text('EnRuta', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
                    SizedBox(height: 40),

                    if (_errorMessage != null)
                      Container(
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(8)),
                        child: Text(_errorMessage!, style: TextStyle(color: Colors.red.shade700)),
                      ),

                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16),

                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 16),

                    Row(
                      children: [
                        Checkbox(
                          value: _recordarEmail,
                          onChanged: (value) => setState(() => _recordarEmail = value ?? false),
                          activeColor: Colors.blue.shade900,
                        ),
                        Text('Recordar email', style: TextStyle(fontSize: 14)),
                      ],
                    ),

                    SizedBox(height: 24),

                    _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                      onPressed: _login,
                      child: Text('Iniciar Sesión'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        backgroundColor: Colors.blue.shade900,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),

                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegistroScreen())),
                      child: Text('¿No tienes cuenta? Regístrate'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (emailController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Ingresa tu email');
      return;
    }
    if (passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Ingresa tu contraseña');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final auth = context.read<AuthProvider>();
      bool success = await auth.login(emailController.text.trim(), passwordController.text);

      if (success) {
        if (_recordarEmail) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('email_guardado', emailController.text.trim());
        }

        if (auth.rol == 'chofer') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ChoferScreen()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PasajeroScreen()));
        }
      } else {
        setState(() => _errorMessage = 'Email o contraseña incorrectos');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error de conexión');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}