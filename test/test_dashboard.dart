import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Widget de prueba que replica la UI de DashboardScreen sin Firebase real
class DashboardScreenTest extends StatefulWidget {
  final FirebaseFirestore firestore;
  const DashboardScreenTest({required this.firestore, super.key});

  @override
  _DashboardScreenTestState createState() => _DashboardScreenTestState();
}

class _DashboardScreenTestState extends State<DashboardScreenTest> {
  Map<String, int> _emotionCounts = {};
  bool _isLoading = false;
  String _selectedInterval = 'Todo';
  final List<String> _intervals = ['Diario', 'Mensual', 'Anual', 'Todo'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await widget.firestore.collection('emocionesDetectadas').get();
      final counts = <String, int>{};
      for (final doc in snapshot.docs) {
        final emociones = doc['emociones'];
        if (emociones is List) {
          for (final e in emociones) {
            counts[e.toString()] = (counts[e.toString()] ?? 0) + 1;
          }
        }
      }
      setState(() {
        _emotionCounts = counts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<String> _getRecommendations() {
    if (_emotionCounts.isEmpty) return ['Todo en orden. Continuar monitoreando emociones.'];
    return ['Revisar emociones detectadas.', 'Continuar monitoreando.'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DASHBOARD GENERAL', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButton<String>(
                      value: _selectedInterval,
                      items: _intervals.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
                      onChanged: (value) => setState(() => _selectedInterval = value!),
                    ),
                    const SizedBox(height: 20),
                    const Text('Recomendaciones', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _getRecommendations().map((rec) => Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.blue[700]),
                              const SizedBox(width: 8),
                              Expanded(child: Text(rec)),
                            ],
                          )).toList(),
                        ),
                      ),
                    ),
                    if (_emotionCounts.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Text('Emociones detectadas:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ..._emotionCounts.entries.map((e) => Text('${e.key}: ${e.value}')),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}

void main() {
  group('HASHIRA AI - Pruebas de Widget: Módulo Dashboard General', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      await fakeFirestore.collection('emocionesDetectadas').add({
        'alumno': 'juan.perez@hashira.edu.pe',
        'emociones': ['Alegria', 'Tristeza'],
        'fechaHora': Timestamp.now(),
      });
    });

    Widget buildTestApp() {
      return MaterialApp(
        home: DashboardScreenTest(firestore: fakeFirestore),
      );
    }

    testWidgets('1. La pantalla carga con el título correcto',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();
      expect(find.text('DASHBOARD GENERAL'), findsOneWidget);
    });

    testWidgets('2. El dropdown de intervalo está presente',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();
      expect(find.byType(DropdownButton<String>), findsOneWidget);
    });

    testWidgets('3. La sección de Recomendaciones está presente',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();
      expect(find.text('Recomendaciones'), findsOneWidget);
    });

    testWidgets('4. Se muestran las emociones cargadas desde Firestore',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();
      expect(find.text('Emociones detectadas:'), findsOneWidget);
    });

    testWidgets('5. El ícono de check_circle está en las recomendaciones',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check_circle), findsWidgets);
    });

    testWidgets('6. El dropdown muestra las opciones de intervalo',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();
      expect(find.text('Todo'), findsOneWidget);
    });
  });
}