import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../services/auth_service.dart';

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
}