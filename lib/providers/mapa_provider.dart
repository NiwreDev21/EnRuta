import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class MapaProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> _choferes = [];
  String? _filtroLinea;

  List<Map<String, dynamic>> get choferes {
    if (_filtroLinea == null) return _choferes;
    return _choferes.where((c) => c['linea'] == _filtroLinea).toList();
  }

  void iniciarStream() {
    print('🟢 Iniciando stream de choferes');
    _firebaseService.getChoferesActivos().listen((choferes) {
      print('🟢 Recibidos ${choferes.length} choferes');
      _choferes = choferes;
      notifyListeners();
    });
  }

  void filtrarPorLinea(String? linea) {
    _filtroLinea = linea;
    notifyListeners();
  }
}