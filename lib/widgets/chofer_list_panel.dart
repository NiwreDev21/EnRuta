import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mapa_provider.dart';

class ChoferListPanel extends StatelessWidget {
  final VoidCallback onRefresh;

  const ChoferListPanel({Key? key, required this.onRefresh}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mapaProvider = Provider.of<MapaProvider>(context);
    final choferes = mapaProvider.choferes;

    return DraggableScrollableSheet(
      initialChildSize: 0.15,
      minChildSize: 0.1,
      maxChildSize: 0.4,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Barra de arrastre
              Container(
                margin: EdgeInsets.all(8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.directions_bus, color: Colors.blue.shade900),
                    SizedBox(width: 8),
                    Text(
                      'Vehículos cercanos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${choferes.length} activo${choferes.length != 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh, size: 20),
                      onPressed: onRefresh,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Lista de choferes
              Expanded(
                child: choferes.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_bus, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'No hay vehículos activos',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: onRefresh,
                        icon: Icon(Icons.refresh, size: 16),
                        label: Text('Actualizar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  controller: scrollController,
                  itemCount: choferes.length,
                  itemBuilder: (context, index) {
                    final chofer = choferes[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getColorForLinea(chofer['linea']),
                        child: Icon(Icons.directions_bus, color: Colors.white, size: 20),
                      ),
                      title: Text(
                        chofer['nombre'] ?? 'Chofer',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Línea: ${chofer['linea']}'),
                      trailing: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, size: 8, color: Colors.green),
                            SizedBox(width: 4),
                            Text('En ruta', style: TextStyle(fontSize: 10)),
                          ],
                        ),
                      ),
                      onTap: () {
                        // Centrar mapa en el chofer seleccionado
                        final lat = chofer['lat']?.toDouble() ?? 0;
                        final lng = chofer['lng']?.toDouble() ?? 0;
                        if (lat != 0 && lng != 0) {
                          // Aquí puedes centrar el mapa
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getColorForLinea(String? linea) {
    switch(linea) {
      case 'Línea 1': return Colors.red;
      case 'Línea 2': return Colors.green;
      case 'Línea 3': return Colors.blue;
      case 'Línea 4': return Colors.orange;
      case 'Línea 5': return Colors.purple;
      default: return Colors.grey;
    }
  }
}