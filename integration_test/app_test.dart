import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:frontend_spc/main.dart' as app;

import 'login_page.dart';
import 'estudiante_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('HASHIRA AI - Pruebas de Integración', () {

    testWidgets('1. La pantalla de login carga correctamente', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final loginPage = LoginPage(tester);

      // Validar que el título está presente
      expect(find.text('ASISTENTE VIRTUAL - HASHIRA AI'), findsOneWidget);

      // Validar que los campos y botón existen
      expect(loginPage.loginButton, findsOneWidget);
      expect(loginPage.estudianteButton, findsOneWidget);
      expect(loginPage.adminButton, findsOneWidget);
    });

    testWidgets('2. Validación de campos vacíos', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final loginPage = LoginPage(tester);

      // Intentar ingresar sin datos
      await loginPage.presionarIngresar();

      // Debe mostrar mensaje de validación
      expect(find.text('Requerido'), findsWidgets);
    });

    testWidgets('3. Validación de correo institucional', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final loginPage = LoginPage(tester);

      // Ingresar correo no institucional
      await loginPage.ingresarEmail('correo@gmail.com');
      await loginPage.ingresarPassword('password123');
      await loginPage.presionarIngresar();

      // Debe mostrar error de correo institucional
      expect(
        find.text('Debe ser correo institucional'),
        findsOneWidget,
      );
    });

    testWidgets('4. Selección de rol Administrador', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final loginPage = LoginPage(tester);

      // Cambiar a rol Administrador
      await loginPage.seleccionarRolAdmin();

      // Validar que el subtítulo cambia
      expect(
        find.text('ADMINISTRADOR INGRESA A TU CUENTA'),
        findsOneWidget,
      );
    });

    testWidgets('5. Flujo completo: Login estudiante', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final loginPage = LoginPage(tester);
      final estudiantePage = EstudiantePage(tester);

      // Seleccionar rol estudiante e ingresar credenciales
      await loginPage.seleccionarRolEstudiante();
      await loginPage.iniciarSesion(
        'estudiante@hashira.edu.pe',
        'password123',
      );

      // Validar que navegó a la pantalla del estudiante
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(estudiantePage.pantallaEstudiante, findsOneWidget);
    });
  });
}
