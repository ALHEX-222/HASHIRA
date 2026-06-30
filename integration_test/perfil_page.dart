import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

/// Page Object Model para la pantalla de Perfil del Estudiante
class PerfilPage {
  final WidgetTester tester;

  PerfilPage(this.tester);

  // Localizadores
  Finder get tituloPerfil => find.text('PERFIL DEL ESTUDIANTE');
  Finder get botonVolver => find.byIcon(Icons.arrow_back);
  Finder get botonEditar => find.byIcon(Icons.edit).first;
  Finder get botonCerrarSesion => find.byIcon(Icons.logout);
  Finder get indicadorCarga => find.byType(CircularProgressIndicator);
  Finder get dialogoLogout => find.text('¿Desea cerrar sesión?');
  Finder get botonSiLogout => find.text('Sí');
  Finder get botonNoLogout => find.text('No');

  // Acciones
  Future<void> presionarVolver() async {
    await tester.tap(botonVolver);
    await tester.pumpAndSettle();
  }

  Future<void> presionarEditar() async {
    await tester.tap(botonEditar);
    await tester.pumpAndSettle();
  }

  Future<void> presionarCerrarSesion() async {
    await tester.tap(botonCerrarSesion);
    await tester.pumpAndSettle();
  }

  // Validaciones
  bool get pantallaVisible => tituloPerfil.evaluate().isNotEmpty;
  bool get estaCargando => indicadorCarga.evaluate().isNotEmpty;
}
