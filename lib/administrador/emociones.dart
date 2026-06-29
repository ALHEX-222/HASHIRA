import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmocionesScreen extends StatefulWidget {
  @override
  _EmocionesScreenState createState() => _EmocionesScreenState();
}

class _EmocionesScreenState extends State<EmocionesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _filteredStudents = [];
  Map<String, dynamic>? _selectedStudent;
  Map<String, int> _emotionCounts = {};
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  List<String> _parseField(dynamic field) {
    if (field == null) return [];
    if (field is List) {
      return field.map((e) => e.toString()).toList();
    }
    if (field is String) {
      return field
          .split(RegExp(r'[;,]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }

  String _parseDate(dynamic dateField) {
    if (dateField == null) return '';
    if (dateField is Timestamp) {
      final dt = dateField.toDate();
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    }
    if (dateField is DateTime) {
      return '${dateField.day}/${dateField.month}/${dateField.year} ${dateField.hour}:${dateField.minute.toString().padLeft(2, '0')}';
    }
    if (dateField is String) {
      try {
        final dt = DateTime.parse(dateField);
        return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        return dateField;
      }
    }
    return dateField.toString();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    try {
      final querySnapshot = await _firestore.collection('estudiantesSPC').get();
      _students =
          querySnapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                'nombreCompleto':
                    '${data['nomEstudiante']} ${data['apePaEstudiante']} ${data['apeMaEstudiante']}',
                'email': data['correoEstudiante'],
                'data': data,
              };
            }).toList()
            ..sort(
              (a, b) => a['nombreCompleto'].compareTo(b['nombreCompleto']),
            );
      _filteredStudents = _students;
      setState(() => _isLoading = false);
    } catch (e) {
      _showError(context, 'Error al cargar estudiantes: ${e.toString()}');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectStudent(Map<String, dynamic> student) async {
    setState(() {
      _selectedStudent = student;
      _emotionCounts = {};
      _history = [];
      _isLoading = true;
    });
    try {
      final querySnapshot =
          await _firestore
              .collection('emocionesDetectadas')
              .where('alumno', isEqualTo: student['email'])
              .orderBy('fechaHora', descending: true)
              .get();
      final counts = <String, int>{};
      final history = <Map<String, dynamic>>[];
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final emociones = _parseField(data['emociones']);
        final situaciones = _parseField(
          data['situacion'] ?? data['situaciones'],
        );
        final fecha = _parseDate(data['fechaHora'] ?? data['fechaltora']);
        for (final emocion in emociones) {
          counts[emocion] = (counts[emocion] ?? 0) + 1;
        }
        for (int i = 0; i < emociones.length; i++) {
          history.add({
            'Emoción': emociones[i],
            'Situación': i < situaciones.length ? situaciones[i] : '',
            'Fecha': fecha,
            'DocId': doc.id,
          });
        }
      }
      setState(() {
        _emotionCounts = counts;
        _history = history;
        _isLoading = false;
      });
    } catch (e) {
      _showError(context, 'Error al cargar datos: ${e.toString()}');
      setState(() => _isLoading = false);
    }
  }

  Color _getEmotionColor(String emocion) {
    switch (emocion.toLowerCase()) {
      case 'tristeza':
        return Colors.blue[200]!;
      case 'alegria':
        return Colors.green[200]!;
      case 'miedo':
        return Colors.purple[200]!;
      case 'incertidumbre':
        return Colors.orange[200]!;
      default:
        return Colors.grey[200]!;
    }
  }

  IconData _getEmotionIcon(String emocion) {
    switch (emocion.toLowerCase()) {
      case 'tristeza':
        return Icons.sentiment_dissatisfied;
      case 'alegria':
        return Icons.sentiment_very_satisfied;
      case 'miedo':
        return Icons.sentiment_very_dissatisfied;
      case 'incertidumbre':
        return Icons.help_outline;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isMobile ? 50 : 60, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: AppBar(
        leading:
            isMobile && _selectedStudent != null
                ? IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => setState(() => _selectedStudent = null),
                )
                : null,
        title: Text(
          _selectedStudent == null
              ? 'GESTION DE EMOCIONES'
              : 'Emociones de ${_selectedStudent!['nombreCompleto']}',
          style: TextStyle(color: Colors.white, fontSize: isMobile ? 18 : 20),
        ),
        backgroundColor: Colors.blue[800],
        elevation: 4,
        automaticallyImplyLeading: false,
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(color: Colors.blue[700]),
              )
              : isMobile
              ? (_selectedStudent == null
                  ? _buildMobileList()
                  : _buildMobileDetails())
              : _buildDesktopBody(),
    );
  }

  Widget _buildMobileList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar estudiante...',
              prefixIcon: Icon(Icons.search, color: Colors.blue[700], size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() {
                _filteredStudents =
                    _students
                        .where(
                          (student) => student['nombreCompleto']
                              .toLowerCase()
                              .contains(value.toLowerCase()),
                        )
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
              return Card(
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  title: Text(
                    student['nombreCompleto'],
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                  subtitle: Text(student['email']),
                  onTap: () => _selectStudent(student),
                  tileColor:
                      _selectedStudent?['id'] == student['id']
                          ? Colors.blue[100]
                          : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMobileDetails() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                color: Colors.blue[700],
                size: isMobile ? 24 : 30,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  _selectedStudent!['nombreCompleto'],
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Emociones Detectadas',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 10),
          _emotionCounts.isEmpty
              ? _buildEmptyState(
                icon: Icons.sentiment_neutral_outlined,
                message: 'No hay datos de emociones',
              )
              : Wrap(
                spacing: isMobile ? 8 : 12,
                runSpacing: isMobile ? 8 : 12,
                children:
                    _emotionCounts.entries
                        .map(
                          (entry) => Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: _getEmotionColor(
                                entry.key,
                              ).withOpacity(0.3),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 12 : 16,
                              vertical: isMobile ? 6 : 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getEmotionIcon(entry.key),
                                  color: _getEmotionColor(entry.key),
                                  size: isMobile ? 16 : 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '${entry.key} (${entry.value})',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[900],
                                    fontSize: isMobile ? 12 : 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
              ),
          SizedBox(height: 20),
          Text(
            'Historial',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child:
                _history.isEmpty
                    ? _buildEmptyState(
                      icon: Icons.history_outlined,
                      message: 'No hay historial',
                    )
                    : ListView.separated(
                      itemCount: _history.length,
                      separatorBuilder: (context, index) => Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _history[index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                            vertical: isMobile ? 2 : 4,
                          ),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: isMobile ? 32 : 40,
                              height: isMobile ? 32 : 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getEmotionColor(
                                  item['Emoción'],
                                ).withOpacity(0.3),
                              ),
                              child: Icon(
                                _getEmotionIcon(item['Emoción']),
                                color: _getEmotionColor(item['Emoción']),
                                size: isMobile ? 16 : 20,
                              ),
                            ),
                            title: Text(
                              item['Emoción'] ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                                fontSize: isMobile ? 14 : 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (item['Situación']?.isNotEmpty ?? false)
                                  Text(
                                    item['Situación'] ?? '',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: isMobile ? 12 : 14,
                                    ),
                                  ),
                                Text(
                                  item['Fecha'] ?? '',
                                  style: TextStyle(
                                    fontSize: isMobile ? 10 : 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopBody() {
    return Row(
      children: [
        Container(
          width: 300,
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _filteredStudents =
                          _students
                              .where(
                                (student) => student['nombreCompleto']
                                    .toLowerCase()
                                    .contains(value.toLowerCase()),
                              )
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
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(10),
                        title: Text(
                          student['nombreCompleto'],
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(student['email']),
                        onTap: () => _selectStudent(student),
                        tileColor:
                            _selectedStudent?['id'] == student['id']
                                ? Colors.blue[100]
                                : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child:
                _selectedStudent == null
                    ? _buildEmptyState(
                      icon: Icons.person_outline,
                      message: 'Selecciona un estudiante',
                    )
                    : Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue[100]!, Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedStudent!['nombreCompleto'],
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Emociones Detectadas',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[800],
                              ),
                            ),
                            SizedBox(height: 10),
                            _emotionCounts.isEmpty
                                ? _buildEmptyState(
                                  icon: Icons.sentiment_neutral_outlined,
                                  message: 'No hay datos de emociones',
                                )
                                : Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children:
                                      _emotionCounts.entries
                                          .map(
                                            (entry) => Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: _getEmotionColor(
                                                  entry.key,
                                                ).withOpacity(0.3),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 8,
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    _getEmotionIcon(entry.key),
                                                    color: _getEmotionColor(
                                                      entry.key,
                                                    ),
                                                    size: 20,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    '${entry.key} (${entry.value})',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.blue[900],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                          .toList(),
                                ),
                            SizedBox(height: 20),
                            Text(
                              'Historial',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[800],
                              ),
                            ),
                            SizedBox(height: 10),
                            Expanded(
                              child:
                                  _history.isEmpty
                                      ? _buildEmptyState(
                                        icon: Icons.history_outlined,
                                        message: 'No hay historial',
                                      )
                                      : ListView.separated(
                                        itemCount: _history.length,
                                        separatorBuilder:
                                            (context, index) =>
                                                Divider(height: 1),
                                        itemBuilder: (context, index) {
                                          final item = _history[index];
                                          return Card(
                                            margin: EdgeInsets.symmetric(
                                              vertical: 4,
                                            ),
                                            elevation: 2,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: ListTile(
                                              leading: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: _getEmotionColor(
                                                    item['Emoción'],
                                                  ).withOpacity(0.3),
                                                ),
                                                child: Icon(
                                                  _getEmotionIcon(
                                                    item['Emoción'],
                                                  ),
                                                  color: _getEmotionColor(
                                                    item['Emoción'],
                                                  ),
                                                  size: 20,
                                                ),
                                              ),
                                              title: Text(
                                                item['Emoción'] ?? '',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue[900],
                                                ),
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  if (item['Situación']
                                                          ?.isNotEmpty ??
                                                      false)
                                                    Text(
                                                      item['Situación'] ?? '',
                                                      style: TextStyle(
                                                        color: Colors.grey[700],
                                                      ),
                                                    ),
                                                  Text(
                                                    item['Fecha'] ?? '',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
          ),
        ),
      ],
    );
  }
}
