import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

/// Page Object Model para la pantalla principal del Estudiante (MainAIScreen)
class OpcionesPage {
  final WidgetTester tester;

  OpcionesPage(this.tester);

  // Localizadores
  Finder get tituloBienvenida => find.text('Bienvenido a HASHIRA AI');
  Finder get subtitulo => find.text('Asistente Emocional Inteligente');
  Finder get botonChat => find.byIcon(Icons.chat);
  Finder get botonCamara => find.byIcon(Icons.camera_alt);
  Finder get botonPerfil => find.byIcon(Icons.account_circle);
  Finder get botonCerrarSesion => find.byIcon(Icons.logout);
  Finder get dialogoLogout => find.text('¿DESEA SALIR DE HASHIRA AI?');
  Finder get dialogoCam => find.textContaining('HASHIRA FACE');
  Finder get botonSiLogout => find.text('Sí');
  Finder get botonNoLogout => find.text('No');

  // Acciones
  Future<void> presionarChat() async {
    await tester.tap(botonChat);
    await tester.pumpAndSettle();
  }

  Future<void> presionarCamara() async {
    await tester.tap(botonCamara);
    await tester.pumpAndSettle();
  }

  Future<void> presionarPerfil() async {
    await tester.tap(botonPerfil);
    await tester.pumpAndSettle();
  }

  Future<void> presionarCerrarSesion() async {
    await tester.tap(botonCerrarSesion);
    await tester.pumpAndSettle();
  }

  Future<void> confirmarCerrarSesion() async {
    await tester.tap(botonSiLogout);
    await tester.pumpAndSettle();
  }

  Future<void> cancelarCerrarSesion() async {
    await tester.tap(botonNoLogout);
    await tester.pumpAndSettle();
  }

  // Validaciones
  bool get pantallaPrincipalVisible => tituloBienvenida.evaluate().isNotEmpty;
}
