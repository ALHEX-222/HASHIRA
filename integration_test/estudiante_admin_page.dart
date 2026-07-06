import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

/// Page Object Model para la pantalla de Gestión de Estudiantes (Admin)
class EstudianteAdminPage {
  final WidgetTester tester;

  EstudianteAdminPage(this.tester);

  // Localizadores
  Finder get tituloGestion => find.text('GESTION DE ESTUDIANTES');
  Finder get campoBusqueda => find.byType(TextField);
  Finder get botonAgregar => find.byIcon(Icons.add);
  Finder get iconoBusqueda => find.byIcon(Icons.search);
  Finder get dialogoRegistrar => find.text('REGISTRAR ESTUDIANTE');
  Finder get botonCancelar => find.text('Cancelar');
  Finder get botonRegistrar => find.text('Registrar');

  // Acciones
  Future<void> presionarAgregar() async {
    await tester.tap(botonAgregar);
    await tester.pumpAndSettle();
  }

  Future<void> presionarCancelar() async {
    await tester.tap(botonCancelar);
    await tester.pumpAndSettle();
  }

  // Validaciones
  bool get pantallaVisible => tituloGestion.evaluate().isNotEmpty;
}
