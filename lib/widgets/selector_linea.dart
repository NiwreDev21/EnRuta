import 'package:flutter/material.dart';

class SelectorLinea extends StatefulWidget {
  final List<String> lineas;
  final Function(String) onLineaSeleccionada;

  const SelectorLinea({
    Key? key,
    required this.lineas,
    required this.onLineaSeleccionada,
  }) : super(key: key);

  @override
  _SelectorLineaState createState() => _SelectorLineaState();
}

class _SelectorLineaState extends State<SelectorLinea> {
  String? _lineaSeleccionada;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: widget.lineas.map((linea) {
        final isSelected = _lineaSeleccionada == linea;
        return FilterChip(
          label: Text(linea),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _lineaSeleccionada = selected ? linea : null;
            });
            if (selected) {
              widget.onLineaSeleccionada(linea);
            }
          },
          backgroundColor: Colors.grey.shade200,
          selectedColor: Colors.blue.shade300,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }
}