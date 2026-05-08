import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // Guardar ubicación del chofer
  Future<void> guardarUbicacionChofer(String uid, double lat, double lng) async {
    try {
      await _db.child('choferes/$uid').update({
        'lat': lat,
        'lng': lng,
        'ultima_actualizacion': DateTime.now().millisecondsSinceEpoch,
      });
      print('✅ Ubicación guardada: lat=$lat, lng=$lng');
    } catch (e) {
      print('❌ Error guardando ubicación: $e');
    }
  }

  // Iniciar jornada
  Future<void> iniciarJornada(String uid, String nombre, String linea) async {
    try {
      await _db.child('choferes/$uid').set({
        'nombre': nombre,
        'linea': linea,
        'activo': true,
        'inicio_jornada': DateTime.now().millisecondsSinceEpoch,
        'lat': null,
        'lng': null,
        'ultima_actualizacion': null,
      });
      print('✅ Jornada iniciada para $nombre (Línea: $linea)');
    } catch (e) {
      print('❌ Error iniciando jornada: $e');
    }
  }

  // Terminar jornada
  Future<void> terminarJornada(String uid) async {
    try {
      await _db.child('choferes/$uid').update({
        'activo': false,
        'fin_jornada': DateTime.now().millisecondsSinceEpoch,
      });
      print('✅ Jornada terminada');
    } catch (e) {
      print('❌ Error terminando jornada: $e');
    }
  }

  // Obtener choferes activos en tiempo real (Stream)
  Stream<List<Map<String, dynamic>>> getChoferesActivosStream() {
    print('📡 Iniciando stream de choferes activos');
    return _db.child('choferes').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      final List<Map<String, dynamic>> choferes = [];

      if (data != null) {
        data.forEach((key, value) {
          final chofer = Map<String, dynamic>.from(value);
          chofer['uid'] = key.toString();

          // Solo incluir choferes activos Y que tienen ubicación
          if (chofer['activo'] == true &&
              chofer['lat'] != null &&
              chofer['lng'] != null) {
            choferes.add(chofer);
            print('📡 Chofer activo: ${chofer['nombre']} - lat:${chofer['lat']}, lng:${chofer['lng']}');
          }
        });
      }

      print('📡 Total choferes activos con ubicación: ${choferes.length}');
      return choferes;
    });
  }

  // Guardar rol del usuario
  Future<void> guardarRolUsuario(String uid, String rol, String nombre) async {
    await _db.child('usuarios/$uid').set({
      'nombre': nombre,
      'rol': rol,
      'creado': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Obtener rol del usuario
  Future<String> getRolUsuario(String uid) async {
    final snapshot = await _db.child('usuarios/$uid/rol').get();
    return snapshot.value?.toString() ?? 'pasajero';
  }
}