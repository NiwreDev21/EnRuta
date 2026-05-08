import 'ubicacion_model.dart';
class ChoferModel {
  final String uid;
  final String nombre;
  final String email;
  final String linea;
  bool activo;
  UbicacionModel? ubicacionActual;

  ChoferModel({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.linea,
    this.activo = false,
    this.ubicacionActual,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nombre': nombre,
      'email': email,
      'linea': linea,
      'activo': activo,
      'ubicacion': ubicacionActual?.toMap(),
    };
  }

  factory ChoferModel.fromMap(Map<String, dynamic> map, String uid) {
    return ChoferModel(
      uid: uid,
      nombre: map['nombre'] ?? '',
      email: map['email'] ?? '',
      linea: map['linea'] ?? '',
      activo: map['activo'] ?? false,
      ubicacionActual: map['ubicacion'] != null
          ? UbicacionModel.fromMap(
          Map<String, dynamic>.from(map['ubicacion'] as Map))
          : null,
    );
  }
}