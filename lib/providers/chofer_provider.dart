import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/firebase_service.dart';

class ChoferProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  bool _jornadaActiva = false;
  String _lineaSeleccionada = '';
  bool _isLoading = false;

  bool get jornadaActiva => _jornadaActiva;
  String get lineaSeleccionada => _lineaSeleccionada;
  bool get isLoading => _isLoading;

  void setLinea(String linea) {
    _lineaSeleccionada = linea;
    notifyListeners();
  }

  Future<bool> iniciarJornada(String uid, String nombre, String linea) async {
    if (linea.isEmpty) {
      print('❌ No hay línea seleccionada');
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // 1. Verificar GPS
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ GPS desactivado');
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 2. Solicitar permisos si es necesario
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ Permisos denegados');
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ Permisos denegados permanentemente');
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 3. Obtener ubicación inicial
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('📍 Ubicación inicial obtenida: ${position.latitude}, ${position.longitude}');

      // 4. Iniciar jornada en Firebase (crear registro)
      await _firebaseService.iniciarJornada(uid, nombre, linea);

      // 5. Guardar ubicación inicial
      await _firebaseService.guardarUbicacionChofer(uid, position.latitude, position.longitude);

      _jornadaActiva = true;

      // 6. Iniciar stream de ubicación continua
      _startSendingLocation(uid);

      print('✅ Jornada iniciada correctamente');
      return true;
    } catch (e) {
      print('❌ Error en iniciarJornada: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _startSendingLocation(String uid) {
    // Configuración GPS optimizada
    const LocationSettings settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Actualizar cada 5 metros de movimiento
      timeLimit: Duration(seconds: 3), // O cada 3 segundos
    );

    // Escuchar cambios de ubicación
    Geolocator.getPositionStream(locationSettings: settings).listen((Position position) {
      print('📍 Enviando ubicación en tiempo real: ${position.latitude}, ${position.longitude}');
      _firebaseService.guardarUbicacionChofer(uid, position.latitude, position.longitude);
    }).onError((error) {
      print('❌ Error en stream de ubicación: $error');
    });
  }

  Future<void> terminarJornada(String uid) async {
    _jornadaActiva = false;
    await _firebaseService.terminarJornada(uid);
    notifyListeners();
    print('✅ Jornada terminada');
  }

  @override
  void dispose() {
    super.dispose();
  }
}