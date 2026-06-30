import 'package:flutter_test/flutter_test.dart';

/// Page Object Model para la pantalla principal del Estudiante
class EstudiantePage {
  final WidgetTester tester;

  EstudiantePage(this.tester);

  // Localizadores — ajusta los textos según lo que muestre opciones.dart
  Finder get pantallaEstudiante => find.byKey(const Key('estudiante_screen'));
  Finder get botonChat => find.text('Chat');
  Finder get botonOpciones => find.text('Opciones');

  // Validaciones
  bool get pantallaVisible => pantallaEstudiante.evaluate().isNotEmpty;
  bool get chatVisible => botonChat.evaluate().isNotEmpty;
}
