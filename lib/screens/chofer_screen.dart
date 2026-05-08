import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/auth_provider.dart';
import '../providers/chofer_provider.dart';
import '../widgets/selector_linea.dart';

class ChoferScreen extends StatefulWidget {
  @override
  _ChoferScreenState createState() => _ChoferScreenState();
}

class _ChoferScreenState extends State<ChoferScreen> {
  final List<String> lineas = ['Línea 1', 'Línea 2', 'Línea 3', 'Línea 4', 'Línea 5'];
  String _lineaSeleccionada = '';

  @override
  void initState() {
    super.initState();
    _verificarPermisosAlInicio();
  }

  Future<void> _verificarPermisosAlInicio() async {
    // Solicitar permisos al iniciar la app
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _mostrarDialogGPS();
    }
  }

  void _mostrarDialogGPS() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('GPS Desactivado'),
        content: Text('Para compartir tu ubicación, necesitas activar el GPS'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Entendido'),
          ),
        ],
      ),
    );
  }

  // MÉTODO PRINCIPAL - INICIAR JORNADA
  Future<void> _iniciarJornada(AuthProvider auth, ChoferProvider choferProvider) async {
    if (_lineaSeleccionada.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selecciona una línea primero')),
      );
      return;
    }

    // Verificar GPS
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('GPS Desactivado'),
          content: Text('Para compartir tu ubicación, necesitas activar el GPS'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Entendido'),
            ),
          ],
        ),
      );
      return;
    }

    // Verificar permisos
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permisos denegados permanentemente. Ve a ajustes de la app.')),
      );
      return;
    }

    // Mostrar diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Obteniendo ubicación...'),
          ],
        ),
      ),
    );

    bool exito = await choferProvider.iniciarJornada(
      auth.user!.uid,
      auth.user!.displayName ?? 'Chofer',
      _lineaSeleccionada,
    );

    Navigator.pop(context); // Cerrar diálogo

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Jornada iniciada - Compartiendo ubicación en tiempo real')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al iniciar jornada. Verifica el GPS y los permisos.')),
      );
    }
  }

  Future<void> _terminarJornada(AuthProvider auth, ChoferProvider choferProvider) async {
    // Confirmar
    bool? confirmar = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Terminar Jornada'),
        content: Text('¿Estás seguro de que quieres terminar la jornada?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Terminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await choferProvider.terminarJornada(auth.user!.uid);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Jornada terminada')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final choferProvider = Provider.of<ChoferProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('EnRuta - Chofer'),
        backgroundColor: Colors.blue.shade900,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              if (choferProvider.jornadaActiva) {
                await choferProvider.terminarJornada(auth.user!.uid);
              }
              await auth.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.directions_bus, size: 50, color: Colors.blue.shade900),
                    SizedBox(height: 8),
                    Text(
                      'Bienvenido, ${auth.user?.displayName ?? "Chofer"}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'ID: ${auth.user?.uid.substring(0, 8)}...',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Selecciona tu línea:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            SelectorLinea(
              lineas: lineas,
              onLineaSeleccionada: (linea) {
                setState(() {
                  _lineaSeleccionada = linea;
                });
                choferProvider.setLinea(linea);
              },
            ),
            SizedBox(height: 30),

            // Botón principal
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: choferProvider.isLoading
                    ? null
                    : choferProvider.jornadaActiva
                    ? () => _terminarJornada(auth, choferProvider)
                    : () => _iniciarJornada(auth, choferProvider),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: choferProvider.isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(choferProvider.jornadaActiva ? Icons.stop : Icons.play_arrow, size: 30),
                      SizedBox(width: 10),
                      Text(
                        choferProvider.jornadaActiva ? 'TERMINAR JORNADA' : 'INICIAR JORNADA',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: choferProvider.jornadaActiva ? Colors.red : Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            if (choferProvider.jornadaActiva) ...[
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.gps_fixed, color: Colors.green.shade700, size: 30),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '📍 Compartiendo ubicación',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Línea: $_lineaSeleccionada',
                            style: TextStyle(fontSize: 12, color: Colors.green.shade800),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}