import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_spc/login.dart';

Widget buildTestApp() {
  return MaterialApp(
    home: AuthScreen(),
  );
}

void main() {
  group('HASHIRA AI - Pruebas de Widget', () {

    testWidgets('1. La pantalla de login carga correctamente', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      expect(find.text('ASISTENTE VIRTUAL - HASHIRA AI MODIFICADO'), findsOneWidget);
    });

    testWidgets('2. Los botones de rol están presentes', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      expect(find.text('Estudiante'), findsOneWidget);
      expect(find.text('Administrador'), findsOneWidget);
    });

    testWidgets('3. El botón Ingresar está presente', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      expect(find.text('Ingresar'), findsOneWidget);
    });

    testWidgets('4. Campos de correo y contraseña están presentes', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('5. Validación: campos vacíos muestran error', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      await tester.tap(find.text('Ingresar'));
      await tester.pump();

      expect(find.text('Requerido'), findsWidgets);
    });

    testWidgets('6. Validación: correo no institucional muestra error', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).first, 'correo@gmail.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.text('Ingresar'));
      await tester.pump();

      expect(find.text('Debe ser correo institucional'), findsOneWidget);
    });

    testWidgets('7. Cambio de rol a Administrador', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      await tester.tap(find.text('Administrador'));
      await tester.pumpAndSettle();

      expect(find.text('ADMINISTRADOR INGRESA A TU CUENTA'), findsOneWidget);
    });
  });
}