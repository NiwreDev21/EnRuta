class UbicacionModel {
  final double latitud;
  final double longitud;
  final DateTime timestamp;

  UbicacionModel({
    required this.latitud,
    required this.longitud,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'lat': latitud,
      'lng': longitud,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
  factory UbicacionModel.fromMap(Map<String, dynamic> map) {
    return UbicacionModel(
      latitud: (map['lat'] as num? ?? 0.0).toDouble(),   // ✅ cast seguro
      longitud: (map['lng'] as num? ?? 0.0).toDouble(),  // ✅ cast seguro
      timestamp: DateTime.fromMillisecondsSinceEpoch(
          (map['timestamp'] as num? ?? 0).toInt()),
    );
  }
}