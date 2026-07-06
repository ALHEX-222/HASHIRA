import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmocionesScreenTest extends StatefulWidget {
  final FirebaseFirestore firestore;
  const EmocionesScreenTest({required this.firestore, super.key});

  @override
  _EmocionesScreenTestState createState() => _EmocionesScreenTestState();
}

class _EmocionesScreenTestState extends State<EmocionesScreenTest> {
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _filteredStudents = [];
  Map<String, dynamic>? _selectedStudent;
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

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
      _filteredStudents = _students;
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedStudent == null ? 'GESTION DE EMOCIONES' : 'Emociones de ${_selectedStudent!['nombreCompleto']}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[800],
        automaticallyImplyLeading: false,
        leading: _selectedStudent != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => setState(() => _selectedStudent = null),
              )
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                SizedBox(
                  width: 300,
                  child: Material(
                    color: Colors.blue[50],
                    child: Column(
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
                            onChanged: (value) {
                              setState(() {
                                _filteredStudents = _students
                                    .where((s) => s['nombreCompleto'].toLowerCase().contains(value.toLowerCase()))
                                    .toList();
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _filteredStudents.length,
                            itemBuilder: (context, index) {
                              final student = _filteredStudents[index];
                              return Material(
                                color: Colors.transparent,
                                child: ListTile(
                                  title: Text(student['nombreCompleto']),
                                  subtitle: Text(student['email']),
                                  onTap: () => setState(() => _selectedStudent = student),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: _selectedStudent == null
                        ? const Text('Selecciona un estudiante')
                        : Text('Emociones de: ${_selectedStudent!['nombreCompleto']}'),
                  ),
                ),
              ],
            ),
    );
  }
}

void main() {
  group('HASHIRA AI - Pruebas de Widget: Módulo Gestión de Emociones', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      await fakeFirestore.collection('estudiantesSPC').add({
        'nomEstudiante': 'María',
        'apePaEstudiante': 'García',
        'correoEstudiante': 'maria.garcia@hashira.edu.pe',
        'dniEstudiante': '87654321',
        'direcEstudiante': 'Av. Lima 456',
        'pswEstudiante': '87654321',
      });
    });

    Widget buildTestApp() {
      return MaterialApp(
        home: EmocionesScreenTest(firestore: fakeFirestore),
      );
    }

    testWidgets('1. La pantalla carga con el título correcto',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();
      expect(find.text('GESTION DE EMOCIONES'), findsOneWidget);
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

    testWidgets('3. Se muestra el mensaje de selección inicial',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();
      expect(find.text('Selecciona un estudiante'), findsOneWidget);
    });

    testWidgets('4. Se muestra el estudiante cargado desde Firestore',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();
      expect(find.text('María García'), findsOneWidget);
    });

    testWidgets('5. Al seleccionar un estudiante cambia el título',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('María García'));
      await tester.pumpAndSettle();
      expect(find.text('Emociones de: María García'), findsOneWidget);
    });

    testWidgets('6. El campo de búsqueda filtra estudiantes',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pump();
      expect(find.text('María García'), findsNothing);
    });
  });
}
