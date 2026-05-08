class UserModel {
  final String uid;
  final String nombre;
  final String email;
  final String rol;
  final DateTime creado;

  UserModel({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.creado,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'email': email,
      'rol': rol,
      'creado': creado.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      nombre: map['nombre'] ?? '',
      email: map['email'] ?? '',
      rol: map['rol'] ?? 'pasajero',
      creado: DateTime.fromMillisecondsSinceEpoch(map['creado'] ?? 0),
    );
  }
}