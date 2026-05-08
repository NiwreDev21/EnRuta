import 'package:flutter/material.dart';

class BotonJornada extends StatelessWidget {
  final bool jornadaActiva;
  final VoidCallback onPressed;

  const BotonJornada({
    Key? key,
    required this.jornadaActiva,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                jornadaActiva ? Icons.stop : Icons.play_arrow,
                size: 30,
              ),
              SizedBox(width: 10),
              Text(
                jornadaActiva ? 'Terminar Jornada' : 'Iniciar Jornada',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: jornadaActiva ? Colors.red : Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}