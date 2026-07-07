import 'package:flutter/material.dart';

// Módulo de Reportes - HASHIRA
// En desarrollo: generación de reportes en PDF para el administrador.
// Utilizará los paquetes 'pdf' y 'printing' ya incluidos en el proyecto.

class ReportesScreen extends StatelessWidget {
  const ReportesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        backgroundColor: Colors.blue[800],
      ),
      body: const Center(child: Text('Módulo de reportes en construcción')),
    );
  }
}
