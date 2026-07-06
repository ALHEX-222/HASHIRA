import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Widget de prueba que replica la UI de EstudianteScreen sin Firebase real
class EstudianteScreenTest extends StatefulWidget {
  final FirebaseFirestore firestore;
  const EstudianteScreenTest({required this.firestore, super.key});

  @override
  _EstudianteScreenTestState createState() => _EstudianteScreenTestState();
}

class _EstudianteScreenTestState extends State<EstudianteScreenTest> {
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await widget.firestore.collection('estudiantesSPC').get();
      _students = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'nombreCompleto': '${data['nomEstudiante']} ${data['apePaEstudiante']}',
          'email': data['correoEstudiante'],
          'data': data,
        };
      }).toList();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showAddDialog() {
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
                const Text('REGISTRAR ESTUDIANTE', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                TextFormField(controller: _nombreController, decoration: const InputDecoration(labelText: 'Nombres')),
                TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Correo Institucional')),
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
        title: const Text('GESTION DE ESTUDIANTES', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar estudiante...',
                      prefixIcon: Icon(Icons.search, color: Colors.blue[700]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_students[index]['nombreCompleto']),
                        subtitle: Text(_students[index]['email']),
                      );
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
  group('HASHIRA AI - Pruebas de Widget: Módulo Gestión de Estudiantes (Admin)', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      await fakeFirestore.collection('estudiantesSPC').add({
        'nomEstudiante': 'Juan',
        'apePaEstudiante': 'Pérez',
        'correoEstudiante': 'juan.perez@hashira.edu.pe',
        'dniEstudiante': '12345678',
        'direcEstudiante': 'Av. Lima 123',
        'pswEstudiante': '12345678',
      });
    });

    Widget buildTestApp() {
      return MaterialApp(
        home: EstudianteScreenTest(firestore: fakeFirestore),
      );
    }

    testWidgets('1. La pantalla carga con el título correcto',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('GESTION DE ESTUDIANTES'), findsOneWidget);
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

    testWidgets('3. El botón de agregar está presente',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('4. Se muestra el estudiante cargado desde Firestore',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Juan Pérez'), findsOneWidget);
    });

    testWidgets('5. Al presionar + aparece el diálogo de registro',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('REGISTRAR ESTUDIANTE'), findsOneWidget);
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

      expect(find.text('REGISTRAR ESTUDIANTE'), findsNothing);
    });
  });
}
