import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdministradorScreen extends StatefulWidget {
  @override
  _AdministradorScreenState createState() => _AdministradorScreenState();
}

class _AdministradorScreenState extends State<AdministradorScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadAdmins() async {
    setState(() => _isLoading = true);
    try {
      final querySnapshot =
          await _firestore.collection('administradorSPC').get();
      _admins =
          querySnapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                'correo': data['correoAdmin'] ?? '',
                'password': data['pswAdmin'] ?? '',
                'data': data,
              };
            }).toList()
            ..sort((a, b) => a['correo'].compareTo(b['correo']));
      setState(() => _isLoading = false);
    } catch (e) {
      _showError(context, 'Error al cargar administradores: ${e.toString()}');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addAdmin() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      setState(() => _isLoading = true);
      final emailExists = await _firestore
          .collection('administradorSPC')
          .where('correoAdmin', isEqualTo: _emailController.text.trim())
          .get()
          .then((snapshot) => snapshot.docs.isNotEmpty);
      if (emailExists) {
        _showError(context, 'El correo ya está registrado');
        return;
      }
      await _firestore.collection('administradorSPC').add({
        'correoAdmin': _emailController.text.trim(),
        'pswAdmin': _passwordController.text.trim(),
      });
      _showSuccess(context, 'Administrador registrado con éxito');
      _clearControllers();
      _loadAdmins();
    } catch (e) {
      _showError(context, 'Error al registrar administrador: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateAdmin(String adminId, String currentEmail) async {
    if (!_formKey.currentState!.validate()) return;
    try {
      setState(() => _isLoading = true);
      final emailExists = await _firestore
          .collection('administradorSPC')
          .where('correoAdmin', isEqualTo: _emailController.text.trim())
          .get()
          .then(
            (snapshot) =>
                snapshot.docs.isNotEmpty && snapshot.docs.first.id != adminId,
          );
      if (emailExists) {
        _showError(
          context,
          'El correo ya está registrado por otro administrador',
        );
        return;
      }
      await _firestore.collection('administradorSPC').doc(adminId).update({
        'correoAdmin': _emailController.text.trim(),
        'pswAdmin': _passwordController.text.trim(),
      });
      _showSuccess(context, 'Datos actualizados con éxito');
      _clearControllers();
      _loadAdmins();
    } catch (e) {
      _showError(context, 'Error al actualizar administrador: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAdmin(String adminId) async {
    try {
      setState(() => _isLoading = true);
      await _firestore.collection('administradorSPC').doc(adminId).delete();
      _showSuccess(context, 'Administrador eliminado con éxito');
      _loadAdmins();
    } catch (e) {
      _showError(context, 'Error al eliminar administrador: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearControllers() {
    _emailController.clear();
    _passwordController.clear();
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showAddDialog() {
    _clearControllers();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => SizedBox(
                  width: 250,
                  child: Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(12),
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
                                'REGISTRAR ADMINISTRADOR',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900],
                                ),
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Correo Institucional',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
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
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Contraseña (8 dígitos)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: _addAdmin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green[700],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      'Registrar',
                                      style: TextStyle(color: Colors.white),
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
                ),
          ),
    );
  }

  void _showEditDialog(String adminId, String currentEmail) {
    final admin = _admins.firstWhere((a) => a['id'] == adminId);
    _emailController.text = admin['correo'];
    _passwordController.text = admin['password'];
    bool localShowPassword = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: 250,
                child: Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(12),
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
                              'EDITAR ADMINISTRADOR',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Correo Institucional',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
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
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Contraseña (8 dígitos)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    localShowPassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed:
                                      () => setState(
                                        () =>
                                            localShowPassword =
                                                !localShowPassword,
                                      ),
                                ),
                              ),
                              obscureText: !localShowPassword,
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
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _updateAdmin(adminId, currentEmail);
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[700],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Guardar',
                                    style: TextStyle(color: Colors.white),
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
            },
          ),
    );
  }

  void _confirmDeleteAdmin(String adminId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              'Confirmación',
              style: TextStyle(color: Colors.blue[900]),
            ),
            content: Text(
              '¿Estás seguro que deseas eliminar al administrador?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('No', style: TextStyle(color: Colors.grey[700])),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteAdmin(adminId);
                },
                child: Text('Sí', style: TextStyle(color: Colors.red[700])),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'GESTION DE ADMINISTRADORES',
          style: TextStyle(color: Colors.white),
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
              : Row(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.blue[50],
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Buscar administrador...',
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.blue[700],
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _admins =
                                      _admins
                                          .where(
                                            (admin) => admin['correo']
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
                              itemCount: _admins.length,
                              itemBuilder: (context, index) {
                                final admin = _admins[index];
                                return Card(
                                  margin: EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 8,
                                  ),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.all(10),
                                    title: Text(admin['correo']),
                                    subtitle: Text('Contraseña: ******'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            color: Colors.blue[700],
                                          ),
                                          onPressed:
                                              () => _showEditDialog(
                                                admin['id'],
                                                admin['correo'],
                                              ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red[700],
                                          ),
                                          onPressed:
                                              () => _confirmDeleteAdmin(
                                                admin['id'],
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
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.blue[700],
        child: Icon(Icons.add, color: Colors.white, size: 30),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
