import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_spc/estudiante/perfilEstudiante.dart';

Widget buildPerfilTestApp() {
  return const MaterialApp(
    home: PerfilEstudiante(userId: 'estudiante.prueba@hashira.edu.pe'),
  );
}

void main() {
  group('HASHIRA AI - Pruebas de Widget: Módulo Perfil Estudiante', () {

    testWidgets('1. La pantalla de perfil carga con el título correcto',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPerfilTestApp());
      await tester.pump();

      expect(find.text('PERFIL DEL ESTUDIANTE'), findsOneWidget);
    });

    testWidgets('2. Se muestra el indicador de carga al iniciar',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPerfilTestApp());
      // No hacemos pump() adicional para capturar el estado inicial de carga
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('3. Los íconos de edición y cierre de sesión están presentes',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPerfilTestApp());
      await tester.pump();

      expect(find.byIcon(Icons.edit), findsWidgets);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('4. El botón de volver está presente',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPerfilTestApp());
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('5. Al presionar Cerrar Sesión aparece el diálogo de confirmación',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPerfilTestApp());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      expect(find.text('¿Desea cerrar sesión?'), findsOneWidget);
      expect(find.text('Sí'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
    });

    testWidgets('6. Al presionar "No" se cierra el diálogo de logout',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildPerfilTestApp());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();

      expect(find.text('¿Desea cerrar sesión?'), findsNothing);
    });
  });
}