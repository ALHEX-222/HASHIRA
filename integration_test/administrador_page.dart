import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

/// Page Object Model para la pantalla de Gestión de Administradores
class AdministradorPage {
  final WidgetTester tester;

  AdministradorPage(this.tester);

  // Localizadores
  Finder get tituloGestion => find.text('GESTION DE ADMINISTRADORES');
  Finder get campoBusqueda => find.byType(TextField);
  Finder get botonAgregar => find.byIcon(Icons.add);
  Finder get indicadorCarga => find.byType(CircularProgressIndicator);
  Finder get dialogoRegistrar => find.text('REGISTRAR ADMINISTRADOR');
  Finder get botonCancelar => find.text('Cancelar');
  Finder get botonRegistrar => find.text('Registrar');

  // Acciones
  Future<void> presionarAgregar() async {
    await tester.tap(botonAgregar);
    await tester.pumpAndSettle();
  }

  Future<void> presionarCancelar() async {
    await tester.tap(botonCancelar);
    await tester.pumpAndSettle();
  }

  Future<void> buscarAdmin(String texto) async {
    await tester.enterText(campoBusqueda, texto);
    await tester.pump();
  }

  // Validaciones
  bool get pantallaVisible => tituloGestion.evaluate().isNotEmpty;
  bool get estaCargando => indicadorCarga.evaluate().isNotEmpty;
}
