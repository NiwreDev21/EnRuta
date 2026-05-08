import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mapa_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/mapa_widget.dart';

class PasajeroScreen extends StatefulWidget {
  @override
  _PasajeroScreenState createState() => _PasajeroScreenState();
}

class _PasajeroScreenState extends State<PasajeroScreen> {
  String filtroLinea = 'Todas';
  final List<String> lineas = ['Todas', 'Línea 1', 'Línea 2'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapaProvider>().iniciarStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final mapaProvider = Provider.of<MapaProvider>(context);
    final choferes = mapaProvider.choferes;

    return Scaffold(
      appBar: AppBar(
        title: Text('EnRuta', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade900,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => filtroLinea = value);
              mapaProvider.filtrarPorLinea(filtroLinea == 'Todas' ? null : filtroLinea);
            },
            itemBuilder: (context) => lineas.map((l) => PopupMenuItem(value: l, child: Text(l))).toList(),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MapaWidget(filtroLinea: filtroLinea == 'Todas' ? null : filtroLinea),

          // Contador flotante
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade900,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.directions_bus, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text('${choferes.length}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => mapaProvider.iniciarStream(),
                    child: Icon(Icons.refresh, color: Colors.white, size: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}