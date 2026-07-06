import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_spc/administrador/admin.dart';

Widget buildAdminTestApp() {
  return MaterialApp(
    home: AdminScreen(),
  );
}

void main() {
  group('HASHIRA AI - Pruebas de Widget: Módulo Admin Principal', () {

    testWidgets('1. La pantalla de administración carga con el título correcto',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildAdminTestApp());
      await tester.pump();

      expect(find.text('PANEL DE ADMINISTRACIÓN'), findsOneWidget);
    });

    testWidgets('2. El botón de cerrar sesión está presente en el AppBar',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildAdminTestApp());
      await tester.pump();

      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('3. El menú lateral muestra el ícono de Inicio',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildAdminTestApp());
      await tester.pump();

      expect(find.byIcon(Icons.home), findsOneWidget);
    });

    testWidgets('4. El menú lateral muestra el ícono de Estudiantes',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildAdminTestApp());
      await tester.pump();

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('5. Al presionar Cerrar Sesión aparece el diálogo de confirmación',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildAdminTestApp());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      expect(find.text('¿Quiere cerrar sesión?'), findsOneWidget);
      expect(find.text('Sí'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
    });

    testWidgets('6. Al presionar "No" se cierra el diálogo de logout',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildAdminTestApp());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();

      expect(find.text('¿Quiere cerrar sesión?'), findsNothing);
    });
  });
}
