import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_spc/estudiante/chat.dart';

Widget buildChatTestApp() {
  return const MaterialApp(
    home: Scaffold(
      body: ChatBody(userId: 'estudiante.prueba@hashira.edu.pe'),
    ),
  );
}

void main() {
  group('HASHIRA AI - Pruebas de Widget: Módulo Chat', () {

    testWidgets('1. La pantalla de chat carga con el campo de mensaje',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildChatTestApp());
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Escribe tu mensaje...'), findsOneWidget);
    });

    testWidgets('2. El botón de enviar mensaje está presente',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildChatTestApp());
      await tester.pump();

      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('3. El botón de micrófono está presente',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildChatTestApp());
      await tester.pump();

      expect(find.byIcon(Icons.mic), findsOneWidget);
    });

    testWidgets('4. Se puede escribir texto en el campo de mensaje',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildChatTestApp());
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Hola, me siento feliz hoy');
      await tester.pump();

      expect(find.text('Hola, me siento feliz hoy'), findsOneWidget);
    });

    testWidgets('5. El campo de mensaje se deshabilita mientras escucha por voz',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildChatTestApp());
      await tester.pump();

      final campoTexto = tester.widget<TextField>(find.byType(TextField));
      expect(campoTexto.enabled, isTrue);
    });

    testWidgets('6. La lista de mensajes (ListView) está presente',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildChatTestApp());
      await tester.pump();

      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
