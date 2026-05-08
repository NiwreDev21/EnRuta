import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/chofer_provider.dart';

class ChoferScreen extends StatefulWidget {
  @override
  _ChoferScreenState createState() => _ChoferScreenState();
}

class _ChoferScreenState extends State<ChoferScreen> {
  final List<String> lineas = ['Línea 1', 'Línea 2'];
  String _lineaSeleccionada = '';

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
            // Info usuario
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.person, size: 40, color: Colors.blue.shade900),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(auth.user?.displayName ?? 'Chofer',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(auth.user?.email ?? '', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    if (choferProvider.jornadaActiva)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('EN VIVO', style: TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Selección de línea
            Text('Línea:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              children: lineas.map((linea) => Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton(
                    onPressed: choferProvider.jornadaActiva ? null : () => setState(() => _lineaSeleccionada = linea),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _lineaSeleccionada == linea ? Colors.blue.shade900 : Colors.grey.shade200,
                      foregroundColor: _lineaSeleccionada == linea ? Colors.white : Colors.black,
                    ),
                    child: Text(linea),
                  ),
                ),
              )).toList(),
            ),

            SizedBox(height: 20),

            // Estado GPS
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: choferProvider.jornadaActiva ? Colors.green.shade50 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: choferProvider.jornadaActiva ? Colors.green : Colors.grey),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(choferProvider.jornadaActiva ? Icons.gps_fixed : Icons.gps_off,
                          color: choferProvider.jornadaActiva ? Colors.green : Colors.grey,
                          size: 30),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          choferProvider.jornadaActiva
                              ? '📍 Compartiendo ubicación EN VIVO'
                              : '⚡ Presiona "Iniciar Jornada"',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  if (choferProvider.jornadaActiva) ...[
                    SizedBox(height: 8),
                    Divider(),
                    Row(
                      children: [
                        Icon(Icons.timer, size: 14, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Actualización: ', style: TextStyle(fontSize: 12)),
                        Text(choferProvider.ultimaActualizacion,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.sync, size: 14, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Stream GPS activo - Actualizando cada 2 segundos',
                            style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ],
                  if (choferProvider.errorGPS.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(choferProvider.errorGPS, style: TextStyle(fontSize: 12, color: Colors.orange)),
                    ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Botón principal
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: choferProvider.isLoading
                    ? null
                    : choferProvider.jornadaActiva
                    ? () async {
                  bool confirm = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Terminar Jornada'),
                      content: Text('¿Dejar de compartir tu ubicación?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancelar')),
                        TextButton(onPressed: () => Navigator.pop(context, true),
                            child: Text('Terminar', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  ) ?? false;

                  if (confirm) {
                    await choferProvider.terminarJornada(auth.user!.uid);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Dejaste de compartir ubicación'), backgroundColor: Colors.orange));
                  }
                }
                    : () async {
                  if (_lineaSeleccionada.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Selecciona una línea'), backgroundColor: Colors.orange));
                    return;
                  }

                  bool exito = await choferProvider.iniciarJornada(
                    auth.user!.uid,
                    auth.user!.displayName ?? 'Chofer',
                    _lineaSeleccionada,
                  );

                  if (exito) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('✅ Compartiendo ubicación en tiempo real'), backgroundColor: Colors.green));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('❌ Error al iniciar'), backgroundColor: Colors.red));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: choferProvider.jornadaActiva ? Colors.red : Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: choferProvider.isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(choferProvider.jornadaActiva ? 'TERMINAR JORNADA' : 'INICIAR JORNADA',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),

            SizedBox(height: 16),

            if (!choferProvider.jornadaActiva)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Icon(Icons.info, size: 16, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Al iniciar jornada, tu ubicación se compartirá en tiempo real.',
                        style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}