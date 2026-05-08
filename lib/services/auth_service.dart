import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService();

  // Obtener usuario actual
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Auto login
  Future<User?> autoLogin(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Auto login falló: $e');
      return null;
    }
  }

  // Login normal
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Login falló: $e');
      return null;
    }
  }

  // Registrar usuario
  Future<User?> register(String email, String password, String nombre, String rol) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await result.user?.updateDisplayName(nombre);

      // Guardar rol en Firebase Database
      await _firebaseService.guardarRolUsuario(result.user!.uid, rol, nombre);

      return result.user;
    } catch (e) {
      print('Registro falló: $e');
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Obtener rol del usuario
  Future<String> getRolUsuario(String uid) async {
    try {
      return await _firebaseService.getRolUsuario(uid);
    } catch (e) {
      print('Error obteniendo rol: $e');
      return 'pasajero';
    }
  }
}