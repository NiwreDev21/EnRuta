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
    print('🟢 Iniciando stream de choferes desde MapaProvider');
    _firebaseService.getChoferesActivosStream().listen((choferes) {
      print('🟢 Recibidos ${choferes.length} choferes');
      _choferes = choferes;
      notifyListeners();
    });
  }

  void filtrarPorLinea(String? linea) {
    _filtroLinea = linea;
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }

  void setMapController(dynamic controller) {
    // Método requerido por mapa_widget
  }

  @override
  void dispose() {
    super.dispose();
  }
}