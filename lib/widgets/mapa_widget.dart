import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/mapa_provider.dart';

class MapaWidget extends StatelessWidget {
  final String? filtroLinea;

  const MapaWidget({Key? key, this.filtroLinea}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mapaProvider = Provider.of<MapaProvider>(context);
    final choferes = mapaProvider.choferes;

    Set<Marker> markers = {};

    for (var chofer in choferes) {
      final lat = chofer['lat']?.toDouble() ?? 0;
      final lng = chofer['lng']?.toDouble() ?? 0;
      final nombre = chofer['nombre'] ?? 'Chofer';
      final linea = chofer['linea'] ?? 'Sin línea';

      if (lat != 0 && lng != 0) {
        markers.add(
          Marker(
            markerId: MarkerId(chofer['uid']),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: nombre,
              snippet: 'Línea: $linea',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              _getColorForLinea(linea),
            ),
          ),
        );
      }
    }

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(-16.973052, -65.420201), // Cochabamba -16.973052, -65.420201
            zoom: 12,
          ),
          markers: markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: true,
        ),

        if (markers.isEmpty)
          Container(
            color: Colors.black54,
            child: Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.directions_bus, size: 50, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No hay choferes activos',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('Esperando que un chofer inicie jornada...'),
                      SizedBox(height: 16),
                      CircularProgressIndicator(),
                    ],
                  ),
                ),
              ),
            ),
          ),

        Positioned(
          bottom: 80,
          right: 16,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade900,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${markers.length} vehículo${markers.length != 1 ? 's' : ''} activo${markers.length != 1 ? 's' : ''}',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  double _getColorForLinea(String linea) {
    switch(linea) {
      case 'Línea 1': return BitmapDescriptor.hueRed;
      case 'Línea 2': return BitmapDescriptor.hueGreen;
      case 'Línea 3': return BitmapDescriptor.hueBlue;
      case 'Línea 4': return BitmapDescriptor.hueOrange;
      case 'Línea 5': return BitmapDescriptor.hueViolet;
      default: return BitmapDescriptor.hueAzure;
    }
  }
}