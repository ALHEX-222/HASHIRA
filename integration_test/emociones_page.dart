import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

/// Page Object Model para la pantalla de Gestión de Emociones
class EmocionesPage {
  final WidgetTester tester;

  EmocionesPage(this.tester);

  // Localizadores
  Finder get tituloGestion => find.text('GESTION DE EMOCIONES');
  Finder get campoBusqueda => find.byType(TextField);
  Finder get iconoBusqueda => find.byIcon(Icons.search);
  Finder get mensajeSeleccionar => find.text('Selecciona un estudiante');

  // Validaciones
  bool get pantallaVisible => tituloGestion.evaluate().isNotEmpty;
}
