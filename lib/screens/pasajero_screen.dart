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
      body: Stack(
        children: [
          // Mapa de fondo
          MapaWidget(filtroLinea: filtroLinea == 'Todas' ? null : filtroLinea),

          // Header flotante
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.directions_bus, color: Colors.blue.shade900),
                    SizedBox(width: 8),
                    Text('EnRuta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Spacer(),
                    // Filtro
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DropdownButton<String>(
                        value: filtroLinea,
                        icon: Icon(Icons.filter_list, size: 18),
                        underline: SizedBox(),
                        items: lineas.map((l) => DropdownMenuItem(value: l, child: Text(l, style: TextStyle(fontSize: 12)))).toList(),
                        onChanged: (value) {
                          setState(() => filtroLinea = value!);
                          mapaProvider.filtrarPorLinea(filtroLinea == 'Todas' ? null : filtroLinea);
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    // Refresh
                    IconButton(
                      icon: Icon(Icons.refresh, size: 20),
                      onPressed: () => mapaProvider.iniciarStream(),
                    ),
                    // Logout
                    IconButton(
                      icon: Icon(Icons.logout, size: 20),
                      onPressed: () async {
                        await auth.logout();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Panel inferior deslizable
          DraggableScrollableSheet(
            initialChildSize: 0.12,
            minChildSize: 0.08,
            maxChildSize: 0.45,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -2)),
                  ],
                ),
                child: Column(
                  children: [
                    // Barra de arrastre
                    Container(
                      margin: EdgeInsets.all(12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Header del panel
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(Icons.directions_bus, color: Colors.blue.shade900),
                          SizedBox(width: 8),
                          Text(
                            'Vehículos cercanos',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${choferes.length} activo${choferes.length != 1 ? 's' : ''}',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 8),

                    // Lista de choferes
                    Expanded(
                      child: choferes.isEmpty
                          ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.directions_bus, size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('No hay vehículos en ruta', style: TextStyle(color: Colors.grey)),
                            SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () => mapaProvider.iniciarStream(),
                              icon: Icon(Icons.refresh, size: 16),
                              label: Text('Buscar'),
                            ),
                          ],
                        ),
                      )
                          : ListView.builder(
                        controller: scrollController,
                        itemCount: choferes.length,
                        itemBuilder: (context, index) {
                          final chofer = choferes[index];
                          final linea = chofer['linea'] ?? 'Línea';
                          final colorLinea = _getColorForLinea(linea);

                          // Calcular tiempo desde última actualización
                          int ultimaActualizacionMs = chofer['ultima_actualizacion'] ?? 0;
                          int minutosTranscurridos = 999;

                          if (ultimaActualizacionMs > 0) {
                            final ultimaActualizacion = DateTime.fromMillisecondsSinceEpoch(ultimaActualizacionMs);
                            minutosTranscurridos = DateTime.now().difference(ultimaActualizacion).inMinutes;
                          }

                          // Determinar estado
                          String estadoTexto = 'EN RUTA';
                          Color estadoColor = Colors.green;
                          String estadoIcono = '🟢';

                          if (minutosTranscurridos < 2) {
                            estadoTexto = 'ACTIVO AHORA';
                            estadoColor = Colors.green;
                            estadoIcono = '🟢';
                          } else if (minutosTranscurridos < 5) {
                            estadoTexto = 'ACTIVO HACE $minutosTranscurridos MIN';
                            estadoColor = Colors.orange;
                            estadoIcono = '🟡';
                          } else {
                            estadoTexto = 'POSIBLE INACTIVO';
                            estadoColor = Colors.red;
                            estadoIcono = '🔴';
                          }

                          return ListTile(
                            leading: Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: colorLinea.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.directions_bus, color: colorLinea),
                            ),
                            title: Text(
                              chofer['nombre'] ?? 'Chofer',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Línea: $linea', style: TextStyle(fontSize: 12)),
                                Row(
                                  children: [
                                    Text(estadoIcono, style: TextStyle(fontSize: 10)),
                                    SizedBox(width: 4),
                                    Text(estadoTexto, style: TextStyle(fontSize: 10, color: estadoColor)),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: estadoColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'EN RUTA',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getColorForLinea(String linea) {
    switch(linea) {
      case 'Línea 1': return Colors.red;
      case 'Línea 2': return Colors.green;
      default: return Colors.blue;
    }
  }
}