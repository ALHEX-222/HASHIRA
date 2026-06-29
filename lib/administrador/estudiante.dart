import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EstudianteScreen extends StatefulWidget {
  @override
  _EstudianteScreenState createState() => _EstudianteScreenState();
}

class _EstudianteScreenState extends State<EstudianteScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _students = [];
  Map<String, dynamic>? _selectedStudent;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _apePaController = TextEditingController();
  final _apeMaController = TextEditingController();
  final _emailController = TextEditingController();
  final _direccionController = TextEditingController();
  final _dniController = TextEditingController();
  final _passwordController = TextEditingController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apePaController.dispose();
    _apeMaController.dispose();
    _emailController.dispose();
    _direccionController.dispose();
    _dniController.dispose();
    _passwordController.dispose();
    _searchController.dispose();
    super.dispose();
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
      setState(() => _isLoading = false);
    } catch (e) {
      _showError(context, 'Error al cargar estudiantes: ${e.toString()}');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addStudent() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      setState(() => _isLoading = true);
      final emailExists = await _firestore
          .collection('estudiantesSPC')
          .where('correoEstudiante', isEqualTo: _emailController.text.trim())
          .get()
          .then((snapshot) => snapshot.docs.isNotEmpty);
      if (emailExists) {
        _showError(context, 'El correo ya está registrado');
        return;
      }
      await _firestore.collection('estudiantesSPC').add({
        'nomEstudiante': _nombreController.text.trim(),
        'apePaEstudiante': _apePaController.text.trim(),
        'apeMaEstudiante': _apeMaController.text.trim(),
        'correoEstudiante': _emailController.text.trim(),
        'direcEstudiante': _direccionController.text.trim(),
        'dniEstudiante': _dniController.text.trim(),
        'pswEstudiante': _passwordController.text.trim(),
      });
      _showSuccess(context, 'Estudiante registrado con éxito');
      _clearControllers();
      _loadStudents();
    } catch (e) {
      _showError(context, 'Error al registrar estudiante: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStudent() async {
    if (!_formKey.currentState!.validate() || _selectedStudent == null) return;
    try {
      setState(() => _isLoading = true);
      final newEmail = _emailController.text.trim();
      final emailExists = await _firestore
          .collection('estudiantesSPC')
          .where('correoEstudiante', isEqualTo: newEmail)
          .get()
          .then(
            (snapshot) =>
                snapshot.docs.isNotEmpty &&
                snapshot.docs.first.id != _selectedStudent!['id'],
          );
      if (emailExists) {
        _showError(context, 'El correo ya está registrado por otro estudiante');
        return;
      }
      await _firestore
          .collection('estudiantesSPC')
          .doc(_selectedStudent!['id'])
          .update({
            'nomEstudiante': _nombreController.text.trim(),
            'apePaEstudiante': _apePaController.text.trim(),
            'apeMaEstudiante': _apeMaController.text.trim(),
            'correoEstudiante': newEmail,
            'direcEstudiante': _direccionController.text.trim(),
            'dniEstudiante': _dniController.text.trim(),
            'pswEstudiante': _passwordController.text.trim(),
          });
      _showSuccess(context, 'Datos actualizados con éxito');
      setState(() => _selectedStudent = null);
      _clearControllers();
      _loadStudents();
    } catch (e) {
      _showError(context, 'Error al actualizar estudiante: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteStudent(Map<String, dynamic> student) async {
    try {
      setState(() => _isLoading = true);
      await _firestore.collection('estudiantesSPC').doc(student['id']).delete();
      _showSuccess(context, 'Estudiante eliminado con éxito');
      setState(() => _selectedStudent = null);
      _loadStudents();
    } catch (e) {
      _showError(context, 'Error al eliminar estudiante: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearControllers() {
    _nombreController.clear();
    _apePaController.clear();
    _apeMaController.clear();
    _emailController.clear();
    _direccionController.clear();
    _dniController.clear();
    _passwordController.clear();
  }

  void _showError(BuildContext context, String message) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              width: isMobile ? double.infinity : 400,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red[100]!, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Error',
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(message),
                  SizedBox(height: 15),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'OK',
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showSuccess(BuildContext context, String message) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              width: isMobile ? double.infinity : 400,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[100]!, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Éxito',
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(message),
                  SizedBox(height: 15),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'OK',
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showAddDialog() {
    _clearControllers();
    final isMobile = MediaQuery.of(context).size.width < 600;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              width: isMobile ? double.infinity : 500,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              padding: EdgeInsets.all(isMobile ? 12 : 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[100]!, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'REGISTRAR ESTUDIANTE',
                        style: TextStyle(
                          fontSize: isMobile ? 18 : 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _nombreController,
                        decoration: InputDecoration(
                          labelText: 'Nombres',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: isMobile ? 10 : 12,
                          ),
                        ),
                        validator:
                            (value) => value!.isEmpty ? 'Requerido' : null,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _apePaController,
                        decoration: InputDecoration(
                          labelText: 'Apellido Paterno',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: isMobile ? 10 : 12,
                          ),
                        ),
                        validator:
                            (value) => value!.isEmpty ? 'Requerido' : null,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _apeMaController,
                        decoration: InputDecoration(
                          labelText: 'Apellido Materno',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: isMobile ? 10 : 12,
                          ),
                        ),
                        validator:
                            (value) => value!.isEmpty ? 'Requerido' : null,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Correo Institucional',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: isMobile ? 10 : 12,
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) return 'Requerido';
                          if (!value.endsWith('@hashira.edu.pe'))
                            return 'Debe ser correo institucional';
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _direccionController,
                        decoration: InputDecoration(
                          labelText: 'Dirección',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: isMobile ? 10 : 12,
                          ),
                        ),
                        validator:
                            (value) => value!.isEmpty ? 'Requerido' : null,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _dniController,
                        decoration: InputDecoration(
                          labelText: 'DNI (8 dígitos)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: isMobile ? 10 : 12,
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) return 'Requerido';
                          if (value.length != 8 ||
                              !RegExp(r'^[0-9]+$').hasMatch(value))
                            return 'DNI debe tener 8 dígitos';
                          return null;
                        },
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Contraseña (8 dígitos)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: isMobile ? 10 : 12,
                          ),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value!.isEmpty) return 'Requerido';
                          if (value.length != 8 ||
                              !RegExp(r'^[0-9]+$').hasMatch(value))
                            return 'Debe tener 8 dígitos';
                          return null;
                        },
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Cancelar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 14 : 16,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _addStudent,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Registrar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 14 : 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  void _showEditDialog() {
    if (_selectedStudent == null) return;
    final data = _selectedStudent!['data'];
    _nombreController.text = data['nomEstudiante'] ?? '';
    _apePaController.text = data['apePaEstudiante'] ?? '';
    _apeMaController.text = data['apeMaEstudiante'] ?? '';
    _emailController.text = data['correoEstudiante'] ?? '';
    _direccionController.text = data['direcEstudiante'] ?? '';
    _dniController.text = data['dniEstudiante'] ?? '';
    _passwordController.text = data['pswEstudiante'] ?? '';
    final isMobile = MediaQuery.of(context).size.width < 600;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              width: isMobile ? double.infinity : 500,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              padding: EdgeInsets.all(isMobile ? 12 : 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[100]!, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'EDITAR ESTUDIANTE',
                        style: TextStyle(
                          fontSize: isMobile ? 18 : 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _nombreController,
                        decoration: InputDecoration(
                          labelText: 'Nombres',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: isMobile ? 10 : 12,
                          ),
                        ),
                        validator:
                            (value) => value!.isEmpty ? 'Requerido' : null,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _apePaController,
                        decoration: InputDecoration(
                          labelText: 'Apellido Paterno',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: isMobile ? 10 : 12,
                          ),
                        ),
                        validator:
                            (value) => value!.isEmpty ? 'Requerido' : null,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _apeMaController,
                        decoration: InputDecoration(
                          labelText: 'Apellido Materno',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: isMobile ? 10 : 12,
                          ),
                        ),
                        validator:
                            (value) => value!.isEmpty ? 'Requerido' : null,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Correo Institucional',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: isMobile ? 10 : 12,
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) return 'Requerido';
                          if (!value.endsWith('@hashira.edu.pe'))
                            return 'Debe ser correo institucional';
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _direccionController,
                        decoration: InputDecoration(
                          labelText: 'Dirección',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: isMobile ? 10 : 12,
                          ),
                        ),
                        validator:
                            (value) => value!.isEmpty ? 'Requerido' : null,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _dniController,
                        decoration: InputDecoration(
                          labelText: 'DNI (8 dígitos)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: isMobile ? 10 : 12,
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) return 'Requerido';
                          if (value.length != 8 ||
                              !RegExp(r'^[0-9]+$').hasMatch(value))
                            return 'DNI debe tener 8 dígitos';
                          return null;
                        },
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Contraseña (8 dígitos)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: isMobile ? 10 : 12,
                          ),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value!.isEmpty) return 'Requerido';
                          if (value.length != 8 ||
                              !RegExp(r'^[0-9]+$').hasMatch(value))
                            return 'Debe tener 8 dígitos';
                          return null;
                        },
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Cancelar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 14 : 16,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _updateStudent,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Guardar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 14 : 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  void _confirmDeleteStudent(Map<String, dynamic> student) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              width: isMobile ? double.infinity : 400,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[100]!, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Confirmación',
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('¿Estás seguro que deseas eliminar al estudiante?'),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'No',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteStudent(student);
                        },
                        child: Text(
                          'Sí',
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final filteredStudents =
        _students
            .where(
              (student) => student['nombreCompleto'].toLowerCase().contains(
                _searchController.text.toLowerCase(),
              ),
            )
            .toList();

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
              ? 'GESTION DE ESTUDIANTES'
              : 'Detalles de Estudiante',
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
                  ? _buildMobileList(filteredStudents)
                  : _buildMobileDetails(_selectedStudent!))
              : _buildDesktopBody(filteredStudents),
      floatingActionButton:
          _selectedStudent == null
              ? FloatingActionButton(
                onPressed: _showAddDialog,
                backgroundColor: Colors.blue[700],
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: isMobile ? 24 : 30,
                ),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              )
              : SizedBox.shrink(),
    );
  }

  Widget _buildMobileList(List<Map<String, dynamic>> filteredStudents) {
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
            onChanged: (value) => setState(() {}),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredStudents.length,
            itemBuilder: (context, index) {
              final student = filteredStudents[index];
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    student['email'],
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  onTap: () => setState(() => _selectedStudent = student),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red[700], size: 20),
                    onPressed: () => _confirmDeleteStudent(student),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMobileDetails(Map<String, dynamic> student) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: Colors.blue[700], size: 30),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  student['nombreCompleto'],
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildDetailRow(Icons.email, 'Correo', student['email']),
          SizedBox(height: 15),
          _buildDetailRow(
            Icons.card_membership,
            'DNI',
            student['data']['dniEstudiante'],
          ),
          SizedBox(height: 15),
          _buildDetailRow(
            Icons.location_on,
            'Dirección',
            student['data']['direcEstudiante'],
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _showEditDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 25),
                ),
                child: Text(
                  'Editar',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () => _confirmDeleteStudent(student),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 25),
                ),
                child: Text(
                  'Eliminar',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopBody(List<Map<String, dynamic>> filteredStudents) {
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
                  onChanged: (value) => setState(() {}),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredStudents.length,
                  itemBuilder: (context, index) {
                    final student = filteredStudents[index];
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
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          student['email'],
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        selected: _selectedStudent == student,
                        selectedTileColor: Colors.blue[100],
                        onTap: () => setState(() => _selectedStudent = student),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red[700]),
                          onPressed: () => _confirmDeleteStudent(student),
                        ),
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
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 80,
                            color: Colors.blue[300],
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Selecciona un estudiante',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                    : Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue[50]!, Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  color: Colors.blue[700],
                                  size: 30,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  _selectedStudent!['nombreCompleto'],
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[900],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            _buildDetailRow(
                              Icons.email,
                              'Correo',
                              _selectedStudent!['email'],
                            ),
                            SizedBox(height: 15),
                            _buildDetailRow(
                              Icons.card_membership,
                              'DNI',
                              _selectedStudent!['data']['dniEstudiante'],
                            ),
                            SizedBox(height: 15),
                            _buildDetailRow(
                              Icons.location_on,
                              'Dirección',
                              _selectedStudent!['data']['direcEstudiante'],
                            ),
                            SizedBox(height: 20),
                            Center(
                              child: ElevatedButton(
                                onPressed: _showEditDialog,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[700],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 25,
                                  ),
                                ),
                                child: Text(
                                  'Editar',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Row(
      children: [
        Icon(icon, color: Colors.blue[700], size: isMobile ? 20 : 24),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
