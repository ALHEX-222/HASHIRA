import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_spc/estudiante/opciones.dart';

Widget buildOpcionesTestApp() {
  return const MaterialApp(
    home: MainAIScreen(userId: 'estudiante.prueba@hashira.edu.pe'),
  );
}

void main() {
  group('HASHIRA AI - Pruebas de Widget: Módulo Opciones (MainAIScreen)', () {

    testWidgets('1. La pantalla principal carga con el mensaje de bienvenida',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildOpcionesTestApp());
      await tester.pump();

      expect(find.text('Bienvenido a HASHIRA AI'), findsOneWidget);
      expect(find.text('Asistente Emocional Inteligente'), findsOneWidget);
    });

    testWidgets('2. Los 4 íconos de navegación están presentes',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildOpcionesTestApp());
      await tester.pump();

      expect(find.byIcon(Icons.chat), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      expect(find.byIcon(Icons.account_circle), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('3. Al presionar Cerrar Sesión aparece el diálogo de confirmación',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildOpcionesTestApp());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      expect(find.text('¿DESEA SALIR DE HASHIRA AI?'), findsOneWidget);
      expect(find.text('Sí'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
    });

    testWidgets('4. Al presionar "No" se cierra el diálogo de logout',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildOpcionesTestApp());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();

      expect(find.text('¿DESEA SALIR DE HASHIRA AI?'), findsNothing);
    });

    testWidgets('5. Al presionar la cámara aparece el diálogo de HASHIRA FACE',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildOpcionesTestApp());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      expect(find.textContaining('HASHIRA FACE'), findsOneWidget);
    });

    testWidgets('6. El botón de Chat es interactuable',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildOpcionesTestApp());
      await tester.pump();

      final botonChat = find.byIcon(Icons.chat);
      expect(botonChat, findsOneWidget);

      final widget = tester.widget<IconButton>(
        find.ancestor(of: botonChat, matching: find.byType(IconButton)),
      );
      expect(widget.onPressed, isNotNull);
    });
  });
}