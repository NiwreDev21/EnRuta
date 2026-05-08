import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService();

  // Registrar usuario
  Future<User?> register(String email, String password, String nombre, String rol) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await result.user?.updateDisplayName(nombre);
      await result.user?.sendEmailVerification();

      // Guardar rol en Firebase Database
      await _firebaseService.guardarRolUsuario(result.user!.uid, rol, nombre);

      return result.user;
    } catch (e) {
      print('Error en registro: $e');
      return null;
    }
  }

  // Login
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Error en login: $e');
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Obtener usuario actual
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Obtener rol del usuario
  Future<String> getRolUsuario(String uid) async {
    return await _firebaseService.getRolUsuario(uid);
  }
}