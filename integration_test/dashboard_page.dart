import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

/// Page Object Model para la pantalla de Dashboard General
class DashboardPage {
  final WidgetTester tester;

  DashboardPage(this.tester);

  // Localizadores
  Finder get tituloDashboard => find.text('DASHBOARD GENERAL');
  Finder get dropdownIntervalo => find.byType(DropdownButton<String>);
  Finder get textoRecomendaciones => find.text('Recomendaciones');
  Finder get indicadorCarga => find.byType(CircularProgressIndicator);

  // Validaciones
  bool get pantallaVisible => tituloDashboard.evaluate().isNotEmpty;
}
