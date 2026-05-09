import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import '../services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChoferProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  bool _jornadaActiva = false;
  bool isLoading = false;
  String _ultimaActualizacion = 'Esperando...';
  String _errorGPS = '';
  StreamSubscription<Position>? _ubicacionSubscription;
  Timer? _timerFuerzaBruta;

  bool get jornadaActiva => _jornadaActiva;
  String get ultimaActualizacion => _ultimaActualizacion;
  String get errorGPS => _errorGPS;

  Future<bool> iniciarJornada(String uid, String nombre, String linea) async {
    if (linea.isEmpty) return false;

    isLoading = true;
    _errorGPS = 'Iniciando GPS...';
    notifyListeners();

    try {
      // Guardar estado en shared preferences para persistencia
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('jornada_activa', true);
      await prefs.setString('jornada_uid', uid);
      await prefs.setString('jornada_nombre', nombre);
      await prefs.setString('jornada_linea', linea);

      // Permisos
      LocationPermission permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }

      if (permiso == LocationPermission.deniedForever) {
        _errorGPS = 'Permisos denegados permanentemente';
        isLoading = false;
        notifyListeners();
        return false;
      }

      // Activar GPS
      bool gpsActivo = await Geolocator.isLocationServiceEnabled();
      if (!gpsActivo) {
        _errorGPS = 'Activando GPS...';
        notifyListeners();
        await Geolocator.openLocationSettings();
        await Future.delayed(Duration(seconds: 3));
        gpsActivo = await Geolocator.isLocationServiceEnabled();
        if (!gpsActivo) {
          _errorGPS = 'Activa el GPS manualmente';
          isLoading = false;
          notifyListeners();
          return false;
        }
      }

      // Iniciar jornada en Firebase
      await _firebaseService.iniciarJornada(uid, nombre, linea);
      _jornadaActiva = true;

      // INICIAR TRACKING (MÉTODO 1: Stream continuo)
      _iniciarStreamUbicacion(uid);

      // MÉTODO 2: Timer de fuerza bruta como respaldo
      _iniciarTimerFuerzaBruta(uid);

      _errorGPS = '✅ Compartiendo ubicación las 24h';
      notifyListeners();

      return true;
    } catch (e) {
      _errorGPS = 'Error: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _iniciarStreamUbicacion(String uid) {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 2,  // Cada 2 metros
      timeLimit: Duration(seconds: 1),  // Cada 1 segundo
    );

    _ubicacionSubscription = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen((Position position) {
      _enviarUbicacion(uid, position);
    }, onError: (error) {
      print('Error stream: $error');
    });
  }

  void _iniciarTimerFuerzaBruta(String uid) {
    // Timer que fuerza la actualización cada 2 segundos
    // Esto asegura que aunque el stream falle, SIGA actualizando
    _timerFuerzaBruta = Timer.periodic(Duration(seconds: 2), (timer) async {
      if (!_jornadaActiva) {
        timer.cancel();
        return;
      }

      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation,
        );
        _enviarUbicacion(uid, position);
      } catch (e) {
        print('Error timer fuerza bruta: $e');
      }
    });
  }

  void _enviarUbicacion(String uid, Position position) {
    _firebaseService.guardarUbicacionChofer(uid, position.latitude, position.longitude);

    final now = DateTime.now();
    _ultimaActualizacion = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    notifyListeners();

    print('📍 GPS ENVÍO: ${position.latitude}, ${position.longitude} - $_ultimaActualizacion');
  }

  Future<void> terminarJornada(String uid) async {
    // Detener todo
    await _ubicacionSubscription?.cancel();
    _ubicacionSubscription = null;
    _timerFuerzaBruta?.cancel();
    _timerFuerzaBruta = null;

    // Limpiar shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jornada_activa');
    await prefs.remove('jornada_uid');

    await _firebaseService.terminarJornada(uid);

    _jornadaActiva = false;
    _ultimaActualizacion = 'Jornada terminada';
    _errorGPS = '';
    notifyListeners();

    print('✅ Jornada terminada');
  }

  @override
  void dispose() {
    _ubicacionSubscription?.cancel();
    _timerFuerzaBruta?.cancel();
    super.dispose();
  }
}