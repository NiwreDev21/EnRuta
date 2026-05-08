import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mapa_provider.dart';
import '../widgets/mapa_widget.dart';

class PasajeroScreen extends StatefulWidget {
  @override
  _PasajeroScreenState createState() => _PasajeroScreenState();
}

class _PasajeroScreenState extends State<PasajeroScreen> {
  final List<String> lineas = ['Todas', 'Línea 1', 'Línea 2', 'Línea 3', 'Línea 4', 'Línea 5'];
  String filtroLinea = 'Todas';

  @override
  void initState() {
    super.initState();
    // Iniciar stream al abrir la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MapaProvider>(context, listen: false).iniciarStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mapaProvider = Provider.of<MapaProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('EnRuta - Transporte en vivo'),
        backgroundColor: Colors.blue.shade900,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              mapaProvider.iniciarStream(); // Refrescar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Actualizando...'), duration: Duration(seconds: 1)),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            color: Colors.blue.shade100,
            child: Row(
              children: [
                Icon(Icons.filter_list),
                SizedBox(width: 10),
                Text('Filtrar por línea:'),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    value: filtroLinea,
                    isExpanded: true,
                    items: lineas.map((linea) {
                      return DropdownMenuItem(
                        value: linea,
                        child: Text(linea),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        filtroLinea = value!;
                      });
                      mapaProvider.filtrarPorLinea(
                          filtroLinea == 'Todas' ? null : filtroLinea
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: MapaWidget(
              filtroLinea: filtroLinea == 'Todas' ? null : filtroLinea,
            ),
          ),
        ],
      ),
    );
  }
}