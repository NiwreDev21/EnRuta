import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/firebase_service.dart';

class ChoferProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  bool _jornadaActiva = false;
  bool isLoading = false;
  String _ultimaActualizacion = 'Esperando...';
  String _errorGPS = '';

  bool get jornadaActiva => _jornadaActiva;
  String get ultimaActualizacion => _ultimaActualizacion;
  String get errorGPS => _errorGPS;

  Future<bool> iniciarJornada(String uid, String nombre, String linea) async {
    if (linea.isEmpty) return false;

    isLoading = true;
    _errorGPS = 'Iniciando...';
    notifyListeners();

    try {
      // 1. Permisos
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

      // 2. Verificar GPS
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

      // 3. Iniciar jornada en Firebase
      await _firebaseService.iniciarJornada(uid, nombre, linea);
      _jornadaActiva = true;

      // 4. INICIAR ENVÍO CONTINUO DE UBICACIÓN
      _iniciarEnvioUbicacion(uid);

      _errorGPS = '✅ Compartiendo ubicación en tiempo real';
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

  void _iniciarEnvioUbicacion(String uid) {
    // PRIMERO: Enviar ubicación inmediatamente
    Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    ).then((position) {
      _firebaseService.guardarUbicacionChofer(uid, position.latitude, position.longitude);
      _actualizarTimestamp();
      print('📍 Ubicación inicial enviada: ${position.latitude}, ${position.longitude}');
    }).catchError((e) {
      print('Error ubicación inicial: $e');
    });

    // SEGUNDO: Stream continuo cada 3 segundos
    Timer.periodic(Duration(seconds: 3), (timer) async {
      if (!_jornadaActiva) {
        timer.cancel();
        return;
      }

      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 3),
        );

        await _firebaseService.guardarUbicacionChofer(uid, position.latitude, position.longitude);
        _actualizarTimestamp();
        print('📍 Ubicación enviada cada 3s: ${position.latitude}, ${position.longitude}');
      } catch (e) {
        print('Error enviando ubicación: $e');
      }
    });
  }

  void _actualizarTimestamp() {
    final now = DateTime.now();
    _ultimaActualizacion = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    notifyListeners();
  }

  Future<void> terminarJornada(String uid) async {
    await _firebaseService.terminarJornada(uid);
    _jornadaActiva = false;
    _ultimaActualizacion = 'Jornada terminada';
    _errorGPS = '';
    notifyListeners();
    print('✅ Jornada terminada');
  }
}