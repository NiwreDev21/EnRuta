import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'chofer_provider.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  firebase_auth.User? _user;
  String? _rol;

  firebase_auth.User? get user => _user;
  String? get rol => _rol;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _user = _authService.getCurrentUser();
    if (_user != null) {
      _cargarRol();
    }
  }

  // LOGIN
  Future<bool> login(String email, String password) async {
    try {
      final user = await _authService.login(email, password);
      if (user != null) {
        _user = user;
        await _cargarRol();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error en login: $e');
      return false;
    }
  }

  // REGISTRO
  Future<bool> register(String email, String password, String nombre, String rol) async {
    try {
      final user = await _authService.register(email, password, nombre, rol);
      if (user != null) {
        _user = user;
        _rol = rol;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error en registro: $e');
      return false;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _rol = null;
    notifyListeners();
  }

  // Cargar rol del usuario
  Future<void> _cargarRol() async {
    if (_user != null) {
      _rol = await _authService.getRolUsuario(_user!.uid);
      notifyListeners();
    }
  }
  //Agregar al AuthProvider
  Future<void> recuperarJornadaPasada() async {
    final prefs = await SharedPreferences.getInstance();
    final jornadaActiva = prefs.getBool('jornada_activa') ?? false;

    if (jornadaActiva) {
      final uid = prefs.getString('jornada_uid');
      final nombre = prefs.getString('jornada_nombre');
      final linea = prefs.getString('jornada_linea');

      if (uid != null && nombre != null && linea != null) {
        print('🔄 Recuperando jornada pasada para $nombre');
        final choferProvider = ChoferProvider();
        await choferProvider.iniciarJornada(uid, nombre, linea);
      }
    }
  }
}

