import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend_spc/estudiante/opciones.dart';
import 'administrador/admin.dart';
import 'services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _userId;
  String _selectedRole = 'Estudiante';
  bool _isLoading = false;
  bool _showPassword = false;
  int _currentIndex = 0;
  late Timer _timer;
  final List<String> _carouselImages = [
    'assets/images/banner1.png',
    'assets/images/banner2.png',
    'assets/images/banner3.png',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _carouselImages.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _auth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    showDialog(
      context: context,
      barrierDismissible: false,
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
                  CircularProgressIndicator(color: Colors.blue[700]),
                  SizedBox(height: 10),
                  Text(
                    'Iniciando sesión...',
                    style: TextStyle(color: Colors.blue[900], fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
    );

    try {
      if (_selectedRole == 'Estudiante') {
        final user = UserRequest(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        final data = await login(user);

        Navigator.of(context).pop();

        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('¡Bienvenido!'),
              backgroundColor: Colors.green[700],
            ),
          );
          setState(() {
            _userId = data['user_id'] ?? 'demo_user';
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['error'] ?? 'Error desconocido'),
              backgroundColor: Colors.red[700],
            ),
          );
        }
      } else if (_selectedRole == 'Administrador') {
        final querySnapshot =
            await FirebaseFirestore.instance
                .collection('administradorSPC')
                .where('correoAdmin', isEqualTo: _emailController.text.trim())
                .where('pswAdmin', isEqualTo: _passwordController.text.trim())
                .limit(1)
                .get();

        Navigator.of(context).pop();

        if (querySnapshot.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('¡Bienvenido, Administrador!'),
              backgroundColor: Colors.green[700],
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdminScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Correo o contraseña incorrectos para Administrador.',
              ),
              backgroundColor: Colors.red[700],
            ),
          );
        }
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error en la autenticación: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return _userId == null
        ? Scaffold(
          backgroundColor: Colors.blue[50],
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/images/fondoLogin.png', fit: BoxFit.cover),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blue[800]!.withOpacity(0.3),
                      Colors.blue[200]!.withOpacity(0.5),
                    ],
                  ),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      width: isMobile ? double.infinity : 1050,
                      padding: EdgeInsets.all(isMobile ? 20.0 : 40.0),
                      margin: isMobile ? const EdgeInsets.all(16) : null,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[100]!, Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child:
                          isMobile
                              ? _buildMobileAuthContent()
                              : _buildDesktopAuthContent(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
        : MainAIScreen(userId: _userId!);
  }

  Widget _buildDesktopAuthContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: _buildAuthForm(),
          ),
        ),
        VerticalDivider(width: 1, thickness: 1, color: Colors.grey[300]),
        Expanded(flex: 2, child: _buildCarousel()),
      ],
    );
  }

  Widget _buildMobileAuthContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [_buildAuthForm(), SizedBox(height: 25), _buildCarousel()],
    );
  }

  Widget _buildCarousel() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final carouselHeight = isMobile ? 150.0 : 220.0;
    final dotSize = isMobile ? 8.0 : 12.0;
    final dotHeight = isMobile ? 6.0 : 8.0;

    return Column(
      children: [
        Container(
          height: carouselHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 700),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Image.asset(
                _carouselImages[_currentIndex],
                key: ValueKey(_carouselImages[_currentIndex]),
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_carouselImages.length, (index) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: isMobile ? 3 : 4),
              width: _currentIndex == index ? dotSize : dotSize * 0.67,
              height: dotHeight,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    _currentIndex == index
                        ? Colors.blue[700]
                        : Colors.grey[400],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildAuthForm() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final titleFontSize = isMobile ? 24.0 : 28.0;
    final subtitleFontSize = isMobile ? 16.0 : 18.0;
    final fieldPaddingVertical = isMobile ? 12.0 : 14.0;
    final iconSize = isMobile ? 18.0 : 20.0;
    final buttonPaddingHorizontal = isMobile ? 30.0 : 40.0;
    final buttonPaddingVertical = isMobile ? 12.0 : 15.0;
    final buttonFontSize = isMobile ? 14.0 : 16.0;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'ASISTENTE VIRTUAL - HASHIRA AI',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 15),
          Text(
            '${_selectedRole.toUpperCase()} INGRESA A TU CUENTA',
            style: TextStyle(
              fontSize: subtitleFontSize,
              fontWeight: FontWeight.w500,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 30),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Correo institucional',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(
                Icons.email,
                color: Colors.blue[700],
                size: iconSize,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: fieldPaddingVertical,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue[200]!),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Requerido';
              if (!value.endsWith('@hashira.edu.pe'))
                return 'Debe ser correo institucional';
              return null;
            },
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.blue[700],
                size: iconSize,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _showPassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.blue[700],
                  size: iconSize,
                ),
                onPressed: () => setState(() => _showPassword = !_showPassword),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: fieldPaddingVertical,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue[200]!),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            obscureText: !_showPassword,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Requerido';
              if (_selectedRole == 'Administrador' &&
                  (value.length != 8 || !RegExp(r'^[0-9]+$').hasMatch(value))) {
                return 'Debe tener 8 dígitos';
              }
              return null;
            },
            keyboardType:
                _selectedRole == 'Administrador'
                    ? TextInputType.number
                    : TextInputType.text,
          ),
          SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildRoleButton('Estudiante', Colors.blue, Icons.person),
              SizedBox(width: isMobile ? 15 : 20),
              _buildRoleButton('Administrador', Colors.blue, Icons.settings),
            ],
          ),
          SizedBox(height: 25),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _auth,
            icon: Icon(Icons.login, color: Colors.white, size: iconSize),
            label: Text(
              'Ingresar',
              style: TextStyle(
                fontSize: buttonFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isLoading ? Colors.grey[400] : Colors.blue[700],
              padding: EdgeInsets.symmetric(
                horizontal: buttonPaddingHorizontal,
                vertical: buttonPaddingVertical,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
              shadowColor: Colors.black26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleButton(String role, Color color, IconData icon) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    bool isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 25,
          vertical: isMobile ? 10 : 12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[100] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue[700]! : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isSelected
                      ? Colors.blue[700]!.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue[700] : Colors.grey[600],
              size: isMobile ? 16 : 18,
            ),
            SizedBox(width: 8),
            Text(
              role,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.blue[900] : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
