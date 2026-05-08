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

    print('🎨 Construyendo mapa con ${choferes.length} choferes');

    Set<Marker> markers = {};

    for (var chofer in choferes) {
      final lat = chofer['lat']?.toDouble() ?? 0;
      final lng = chofer['lng']?.toDouble() ?? 0;
      final nombre = chofer['nombre'] ?? 'Chofer';
      final linea = chofer['linea'] ?? 'Línea';

      print('🎨 Marcador: $nombre en $lat, $lng');

      if (lat != 0 && lng != 0) {
        markers.add(Marker(
          markerId: MarkerId(chofer['uid']),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: nombre,
            snippet: 'Línea: $linea',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ));
      }
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(-16.974729, -65.426241),
        zoom: 13,
      ),
      markers: markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      onMapCreated: (controller) {
        print('🗺️ Mapa creado');
      },
    );
  }
}