import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
/// Page Object Model para la pantalla de Login (AuthScreen)
class LoginPage {
  final WidgetTester tester;

  LoginPage(this.tester);
  // Localizadores
  Finder get emailField => find.byType(TextFormField).first;
  Finder get passwordField => find.byType(TextFormField).last;
  Finder get loginButton => find.text('Ingresar');
  Finder get estudianteButton => find.text('Estudiante');
  Finder get adminButton => find.text('Administrador');
  Finder get tituloApp => find.text('ASISTENTE VIRTUAL - HASHIRA AI');
  // Acciones
  Future<void> ingresarEmail(String email) async {
    await tester.enterText(emailField, email);
  }

  Future<void> ingresarPassword(String password) async {
    await tester.enterText(passwordField, password);
  }

  Future<void> seleccionarRolEstudiante() async {
    await tester.tap(estudianteButton);
    await tester.pumpAndSettle();
  }

  Future<void> seleccionarRolAdmin() async {
    await tester.tap(adminButton);
    await tester.pumpAndSettle();
  }

  Future<void> presionarIngresar() async {
    await tester.tap(loginButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  Future<void> iniciarSesion(String email, String password) async {
    await ingresarEmail(email);
    await ingresarPassword(password);
    await presionarIngresar();
  }

  // Validaciones
  bool get tituloVisible => tituloApp.evaluate().isNotEmpty;
  bool get loginButtonVisible => loginButton.evaluate().isNotEmpty;
}
