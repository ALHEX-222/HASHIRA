import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend_spc/login.dart';

class PerfilEstudiante extends StatefulWidget {
  final String userId;

  const PerfilEstudiante({super.key, required this.userId});

  @override
  _PerfilEstudianteState createState() => _PerfilEstudianteState();
}

class _PerfilEstudianteState extends State<PerfilEstudiante> {
  Map<String, dynamic> _studentData = {};
  String? _docId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fetchStudentData();
    });
  }

  Future<void> _fetchStudentData() async {
    setState(() => _isLoading = true);
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('estudiantesSPC')
              .where('correoEstudiante', isEqualTo: widget.userId)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        setState(() {
          _studentData = doc.data();
          _docId = doc.id;
          _isLoading = false;
        });
      } else {
        throw Exception(
          'No se encontró el estudiante con el correo: ${widget.userId}',
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo cargar el perfil: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  Future<void> _updateStudentData() async {
    final direcController = TextEditingController(
      text: _studentData['direcEstudiante'] ?? '',
    );
    final pswController = TextEditingController(
      text: _studentData['pswEstudiante'] ?? '',
    );
    final formKey = GlobalKey<FormState>();
    bool obscurePassword = true;

    final isMobile = MediaQuery.of(context).size.width < 600;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              return Dialog(
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
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'EDITAR DATOS PERSONALES',
                            style: TextStyle(
                              fontSize: isMobile ? 18 : 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: direcController,
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
                            controller: pswController,
                            decoration: InputDecoration(
                              labelText: 'Contraseña (8 dígitos)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: isMobile ? 10 : 12,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed:
                                    () => setDialogState(
                                      () => obscurePassword = !obscurePassword,
                                    ),
                              ),
                            ),
                            obscureText: obscurePassword,
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
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    try {
                                      await FirebaseFirestore.instance
                                          .collection('estudiantesSPC')
                                          .doc(_docId)
                                          .update({
                                            'direcEstudiante':
                                                direcController.text.trim(),
                                            'pswEstudiante':
                                                pswController.text.trim(),
                                          });
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Datos actualizados con éxito',
                                          ),
                                          backgroundColor: Colors.green[700],
                                        ),
                                      );
                                      _fetchStudentData();
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Error al actualizar: $e',
                                          ),
                                          backgroundColor: Colors.red[700],
                                        ),
                                      );
                                    }
                                  }
                                },
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
              );
            },
          ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              padding: EdgeInsets.all(16),
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
                    '¿Desea cerrar sesión?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AuthScreen(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Sí',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'No',
                          style: TextStyle(color: Colors.white),
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

  String _getInitials(String email) {
    final name = email.split('@')[0];
    final parts = name.split('.');
    if (parts.length >= 2) {
      return parts[0][0].toUpperCase() + parts[1][0].toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        title: Text(
          'PERFIL DEL ESTUDIANTE',
          style: TextStyle(fontSize: isMobile ? 18 : 20),
        ),
        elevation: 4,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: isMobile ? 24 : 28),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit,
              size: isMobile ? 24 : 28,
              color: Colors.white,
            ),
            onPressed: _showUpdateDialog,
          ),
          IconButton(
            icon: Icon(Icons.logout, size: isMobile ? 24 : 28),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[50]!, Colors.blue[100]!],
          ),
        ),
        child:
            _isLoading
                ? Center(
                  child: CircularProgressIndicator(color: Colors.blue[700]),
                )
                : SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[100]!, Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue[700]!.withOpacity(0.3),
                                  spreadRadius: 5,
                                  blurRadius: 15,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: isMobile ? 50 : 70,
                              backgroundColor: Colors.blue[700],
                              child: Text(
                                _getInitials(widget.userId),
                                style: TextStyle(
                                  fontSize: isMobile ? 30 : 40,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            '${_studentData['nomEstudiante'] ?? 'No disponible'} '
                                    '${_studentData['apePaEstudiante'] ?? ''} '
                                    '${_studentData['apeMaEstudiante'] ?? ''}'
                                .trim(),
                            style: TextStyle(
                              fontSize: isMobile ? 24 : 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Estudiante',
                            style: TextStyle(
                              fontSize: isMobile ? 16 : 18,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 30),
                          _buildInfoSection(
                            icon: Icons.email,
                            label: 'Correo',
                            value: _studentData['correoEstudiante'],
                            isEditable: false,
                          ),
                          _buildInfoSection(
                            icon: Icons.credit_card,
                            label: 'DNI',
                            value: _studentData['dniEstudiante'],
                            isEditable: false,
                          ),
                          _buildInfoSection(
                            icon: Icons.location_on,
                            label: 'Dirección',
                            value: _studentData['direcEstudiante'],
                            isEditable: true,
                          ),
                          _buildInfoSection(
                            icon: Icons.lock,
                            label: 'Contraseña',
                            value:
                                _studentData['pswEstudiante'] != null
                                    ? '********'
                                    : 'No disponible',
                            isEditable: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
      ),
    );
  }

  void _showUpdateDialog() {
    _updateStudentData();
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String label,
    String? value,
    required bool isEditable,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue[700], size: 28),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue[900],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value ?? 'No disponible',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            if (isEditable)
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue[700]),
                onPressed: _showUpdateDialog,
              ),
          ],
        ),
      ),
    );
  }
}
