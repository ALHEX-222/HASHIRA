import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

/// Page Object Model para la pantalla de Administración (AdminScreen)
class AdminPage {
  final WidgetTester tester;

  AdminPage(this.tester);

  // Localizadores
  Finder get tituloPanelAdmin => find.text('PANEL DE ADMINISTRACIÓN');
  Finder get botonCerrarSesion => find.byIcon(Icons.logout);
  Finder get dialogoLogout => find.text('¿Quiere cerrar sesión?');
  Finder get botonSi => find.text('Sí');
  Finder get botonNo => find.text('No');
  Finder get cardEstudiantes => find.text('REGISTRO DE ESTUDIANTES');
  Finder get cardAdministradores => find.text('REGISTRO DE ADMINISTRADORES');
  Finder get cardEmociones => find.text('REPORTE DE EMOCIONES');
  Finder get cardDashboard => find.text('DASHBOARD GENERAL');
  Finder get menuInicio => find.byIcon(Icons.home);
  Finder get menuEstudiantes => find.byIcon(Icons.person);
  Finder get menuAdministradores => find.byIcon(Icons.people);
  Finder get menuReportes => find.byIcon(Icons.bar_chart);
  Finder get menuDashboard => find.byIcon(Icons.dashboard);

  // Acciones
  Future<void> presionarCerrarSesion() async {
    await tester.tap(botonCerrarSesion);
    await tester.pumpAndSettle();
  }

  Future<void> presionarCardEstudiantes() async {
    await tester.tap(find.text('Ir a conocer').first);
    await tester.pumpAndSettle();
  }

  // Validaciones
  bool get pantallaVisible => tituloPanelAdmin.evaluate().isNotEmpty;
}
