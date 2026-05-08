import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String KEY_USER_EMAIL = 'user_email';
  static const String KEY_USER_PASSWORD = 'user_password';
  static const String KEY_USER_ROL = 'user_rol';
  static const String KEY_USER_UID = 'user_uid';
  static const String KEY_USER_NOMBRE = 'user_nombre';
  static const String KEY_SESSION_ACTIVE = 'session_active';

  // Guardar credenciales del usuario
  Future<void> guardarCredenciales(String email, String password, String uid, String nombre, String rol) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(KEY_USER_EMAIL, email);
    await prefs.setString(KEY_USER_PASSWORD, password);
    await prefs.setString(KEY_USER_UID, uid);
    await prefs.setString(KEY_USER_NOMBRE, nombre);
    await prefs.setString(KEY_USER_ROL, rol);
    await prefs.setBool(KEY_SESSION_ACTIVE, true);
    print('✅ Credenciales guardadas correctamente');
  }

  // Obtener credenciales guardadas
  Future<Map<String, String?>> obtenerCredenciales() async {
    final prefs = await SharedPreferences.getInstance();
    final isActive = prefs.getBool(KEY_SESSION_ACTIVE) ?? false;

    if (!isActive) {
      print('⚠️ No hay sesión activa');
      return {};
    }

    return {
      'email': prefs.getString(KEY_USER_EMAIL),
      'password': prefs.getString(KEY_USER_PASSWORD),
      'uid': prefs.getString(KEY_USER_UID),
      'nombre': prefs.getString(KEY_USER_NOMBRE),
      'rol': prefs.getString(KEY_USER_ROL),
    };
  }

  // Verificar si hay una sesión activa guardada
  Future<bool> haySesionActiva() async {
    final prefs = await SharedPreferences.getInstance();
    final isActive = prefs.getBool(KEY_SESSION_ACTIVE) ?? false;

    if (!isActive) return false;

    // Verificar que las credenciales existan
    final email = prefs.getString(KEY_USER_EMAIL);
    final password = prefs.getString(KEY_USER_PASSWORD);

    return email != null && password != null;
  }

  // Cerrar sesión - eliminar todas las credenciales
  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(KEY_USER_EMAIL);
    await prefs.remove(KEY_USER_PASSWORD);
    await prefs.remove(KEY_USER_UID);
    await prefs.remove(KEY_USER_NOMBRE);
    await prefs.remove(KEY_USER_ROL);
    await prefs.setBool(KEY_SESSION_ACTIVE, false);
    print('✅ Sesión cerrada - credenciales eliminadas');
  }
}