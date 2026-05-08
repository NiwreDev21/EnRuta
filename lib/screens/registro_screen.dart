import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _rolSeleccionado = 'pasajero';
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (_nombreController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      setState(() => _error = 'Completa todos los campos');
      return;
    }

    setState(() { _cargando = true; _error = null; });

    final auth = context.read<AuthProvider>();
    final exito = await auth.register(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _nombreController.text.trim(),
      _rolSeleccionado,
    );

    if (!mounted) return;

    if (exito) {
      if (_rolSeleccionado == 'chofer') {
        Navigator.pushReplacementNamed(context, '/chofer');
      } else {
        Navigator.pushReplacementNamed(context, '/pasajero');
      }
    } else {
      setState(() {
        _error = 'Error al registrar. Intenta con otro correo.';
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                  labelText: 'Nombre', prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  labelText: 'Correo', prefixIcon: Icon(Icons.email)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'Contraseña', prefixIcon: Icon(Icons.lock)),
            ),
            const SizedBox(height: 20),
            const Text('Tipo de cuenta:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: ['pasajero', 'chofer'].map((rol) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      onPressed: () => setState(() => _rolSeleccionado = rol),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _rolSeleccionado == rol
                            ? Colors.blue.shade900
                            : Colors.grey.shade300,
                        foregroundColor: _rolSeleccionado == rol
                            ? Colors.white
                            : Colors.black,
                      ),
                      child: Text(rol[0].toUpperCase() + rol.substring(1)),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _cargando ? null : _registrar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade900,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _cargando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Crear cuenta',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}