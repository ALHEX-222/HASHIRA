import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend_spc/administrador/administrador.dart';

// Widget de prueba que inyecta Firestore falso
class AdministradorScreenTest extends StatefulWidget {
  final FirebaseFirestore firestore;
  const AdministradorScreenTest({required this.firestore, super.key});

  @override
  _AdministradorScreenTestState createState() => _AdministradorScreenTestState();
}

class _AdministradorScreenTestState extends State<AdministradorScreenTest> {
  List<Map<String, dynamic>> _admins = [];
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAdmins();
  }

  Future<void> _loadAdmins() async {
    setState(() => _isLoading = true);
    try {
      final querySnapshot = await widget.firestore.collection('administradorSPC').get();
      _admins = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {'id': doc.id, 'correo': data['correoAdmin'] ?? '', 'password': data['pswAdmin'] ?? ''};
      }).toList();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showAddDialog() {
    _emailController.clear();
    _passwordController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('REGISTRAR ADMINISTRADOR', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Correo Institucional')),
                TextFormField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Contraseña (8 dígitos)'), obscureText: true),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                    ElevatedButton(onPressed: () {}, child: const Text('Registrar')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GESTION DE ADMINISTRADORES', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar administrador...',
                      prefixIcon: Icon(Icons.search, color: Colors.blue[700]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _admins.length,
                    itemBuilder: (context, index) {
                      return ListTile(title: Text(_admins[index]['correo']));
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

void main() {
  group('HASHIRA AI - Pruebas de Widget: Módulo Gestión de Administradores', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    Widget buildTestApp() {
      return MaterialApp(
        home: AdministradorScreenTest(firestore: fakeFirestore),
      );
    }

    testWidgets('1. La pantalla carga con el título correcto',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('GESTION DE ADMINISTRADORES'), findsOneWidget);
    });

    testWidgets('2. El campo de búsqueda está presente',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('3. El botón de agregar administrador está presente',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('4. Al presionar + aparece el diálogo de registro',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('REGISTRAR ADMINISTRADOR'), findsOneWidget);
    });

    testWidgets('5. El diálogo muestra campos de correo y contraseña',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('6. Al presionar Cancelar se cierra el diálogo',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.text('REGISTRAR ADMINISTRADOR'), findsNothing);
    });
  });
}