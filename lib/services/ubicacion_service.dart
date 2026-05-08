import 'package:geolocator/geolocator.dart';

class UbicacionService {
  static const int INTERVALO_ACTUALIZACION = 3000; // 3 segundos
  static const int DISTANCIA_MINIMA = 2; // 2 metros

  Position? _currentPosition;
  Stream<Position>? _positionStream;

  // Solicitar permisos
  static Future<bool> solicitarPermisos() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Obtener ubicación actual (una vez)
  Future<Position?> getUbicacionActual() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    bool tienePermiso = await solicitarPermisos();
    if (!tienePermiso) return null;

    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return _currentPosition;
    } catch (e) {
      print('Error obteniendo ubicación: $e');
      return null;
    }
  }

  // Stream de ubicación en tiempo real (OPTIMIZADO para batería)
  Stream<Position> iniciarStreamUbicacion() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation, // Mejor para vehículos
      distanceFilter: DISTANCIA_MINIMA, // No actualizar si no se mueve 2m
      timeLimit: Duration(milliseconds: INTERVALO_ACTUALIZACION),
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).map((event) {
      _currentPosition = event;
      return event;
    });

    return _positionStream!;
  }

  // Detener stream
  void detenerStream() {
    _positionStream = null;
  }
}