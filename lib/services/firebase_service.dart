import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Future<void> guardarUbicacionChofer(String uid, double lat, double lng) async {
    try {
      await _db.child('choferes/$uid').update({
        'lat': lat,
        'lng': lng,
        'ultima_actualizacion': DateTime.now().millisecondsSinceEpoch,
      });
      print('✅ GUARDADO EN FIREBASE: $uid -> lat:$lat, lng:$lng');
    } catch (e) {
      print('❌ Error guardando: $e');
    }
  }

  Future<void> iniciarJornada(String uid, String nombre, String linea) async {
    await _db.child('choferes/$uid').set({
      'nombre': nombre,
      'linea': linea,
      'activo': true,
      'inicio_jornada': DateTime.now().millisecondsSinceEpoch,
      'lat': null,
      'lng': null,
    });
    print('✅ Jornada iniciada: $nombre - $linea');
  }

  Future<void> terminarJornada(String uid) async {
    await _db.child('choferes/$uid').remove();
    print('✅ Chofer eliminado de Firebase');
  }

  Stream<List<Map<String, dynamic>>> getChoferesActivos() {
    return _db.child('choferes').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      final List<Map<String, dynamic>> choferes = [];

      if (data != null) {
        data.forEach((key, value) {
          final chofer = Map<String, dynamic>.from(value);
          chofer['uid'] = key.toString();

          if (chofer['activo'] == true &&
              chofer['lat'] != null &&
              chofer['lng'] != null) {
            choferes.add(chofer);
            print('📡 LECTURA FIREBASE: ${chofer['nombre']} -> lat:${chofer['lat']}, lng:${chofer['lng']}');
          }
        });
      }

      print('📡 Total choferes activos: ${choferes.length}');
      return choferes;
    });
  }

  Future<void> guardarRolUsuario(String uid, String rol, String nombre) async {
    await _db.child('usuarios/$uid').set({
      'nombre': nombre,
      'rol': rol,
      'creado': DateTime.now().millisecondsSinceEpoch
    });
  }

  Future<String> getRolUsuario(String uid) async {
    final snapshot = await _db.child('usuarios/$uid/rol').get();
    return snapshot.value?.toString() ?? 'pasajero';
  }
}