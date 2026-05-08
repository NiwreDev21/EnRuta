import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _redirigir();
  }

  Future<void> _redirigir() async {
    await Future.delayed(Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    final emailGuardado = prefs.getString('email_guardado');

    if (emailGuardado != null && emailGuardado.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/login', arguments: emailGuardado);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.directions_bus, size: 100, color: Colors.white),
              SizedBox(height: 20),
              Text('EnRuta', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 10),
              Text('Transporte en tiempo real', style: TextStyle(fontSize: 18, color: Colors.white70)),
              SizedBox(height: 50),
              CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}