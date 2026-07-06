import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Page Object Model para la pantalla de Chat (ChatBody)
class ChatPage {
  final WidgetTester tester;

  ChatPage(this.tester);

  // Localizadores
  Finder get campoMensaje => find.byType(TextField);
  Finder get botonEnviar => find.byIcon(Icons.send);
  Finder get botonMicrofono => find.byIcon(Icons.mic);
  Finder get botonDetener => find.byIcon(Icons.stop);
  Finder get indicadorEscribiendo => find.text('Escribiendo...');
  Finder get textoEscuchando => find.text('Escuchando...');
  Finder get hintMensaje => find.text('Escribe tu mensaje...');

  // Acciones
  Future<void> escribirMensaje(String mensaje) async {
    await tester.enterText(campoMensaje, mensaje);
  }

  Future<void> presionarEnviar() async {
    await tester.tap(botonEnviar);
    await tester.pump();
  }

  Future<void> enviarMensaje(String mensaje) async {
    await escribirMensaje(mensaje);
    await presionarEnviar();
  }

  Future<void> presionarMicrofono() async {
    await tester.tap(botonMicrofono);
    await tester.pump();
  }

  // Validaciones
  bool get campoMensajeVisible => campoMensaje.evaluate().isNotEmpty;
  bool get botonEnviarVisible => botonEnviar.evaluate().isNotEmpty;
  bool get botonMicrofonoVisible => botonMicrofono.evaluate().isNotEmpty;
}
