import 'package:flutter/material.dart';
import 'package:frontend_spc/login.dart';
import 'estudiante.dart';
import 'administrador.dart';
import 'emociones.dart';
import 'dashboard.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;
  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Inicio', 'icon': Icons.home},
    {'title': 'Estudiantes', 'icon': Icons.person},
    {'title': 'Administradores', 'icon': Icons.people},
    {'title': 'Reportes', 'icon': Icons.bar_chart},
    {'title': 'Dashboard', 'icon': Icons.dashboard},
  ];
  final List<Widget> _screens = [
    SizedBox.shrink(),
    EstudianteScreen(),
    AdministradorScreen(),
    EmocionesScreen(),
    DashboardScreen(),
  ];

  bool _isMenuExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PANEL DE ADMINISTRACIÓN',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[800],
        elevation: 4,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text('¿Quiere cerrar sesión?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AuthScreen(),
                              ),
                              (Route<dynamic> route) => false,
                            );
                          },
                          child: Text('Sí'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('No'),
                        ),
                      ],
                    ),
              );
            },
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: Row(
        children: [
          MouseRegion(
            onEnter: (_) => setState(() => _isMenuExpanded = true),
            onExit: (_) => setState(() => _isMenuExpanded = false),
            child: Container(
              width: _isMenuExpanded ? 200 : 60,
              color: Colors.blue[700],
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: _menuItems.length,
                      itemBuilder: (context, index) {
                        final item = _menuItems[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedIndex = index);
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            color:
                                _selectedIndex == index
                                    ? Colors.blue[900]
                                    : Colors.transparent,
                            padding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 12,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  item['icon'] as IconData,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                if (_isMenuExpanded)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12.0),
                                    child: Text(
                                      item['title'] as String,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child:
                  _selectedIndex == 0
                      ? LayoutBuilder(
                        builder: (context, constraints) {
                          bool localIsMobile = constraints.maxWidth < 600;
                          if (localIsMobile) {
                            return SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20.0,
                                ),
                                child: Column(
                                  children: [
                                    _buildActionCard(
                                      'REGISTRO DE ESTUDIANTES',
                                      'Gestiona el registro de estudiantes.',
                                      () => setState(() => _selectedIndex = 1),
                                      isMobile: true,
                                    ),
                                    _buildActionCard(
                                      'REGISTRO DE ADMINISTRADORES',
                                      'Administra los administradores.',
                                      () => setState(() => _selectedIndex = 2),
                                      isMobile: true,
                                    ),
                                    _buildActionCard(
                                      'REPORTE DE EMOCIONES',
                                      'Visualiza reportes de emociones.',
                                      () => setState(() => _selectedIndex = 3),
                                      isMobile: true,
                                    ),
                                    _buildActionCard(
                                      'DASHBOARD GENERAL',
                                      'Revisa estadísticas generales.',
                                      () => setState(() => _selectedIndex = 4),
                                      isMobile: true,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildActionCard(
                                    'REGISTRO DE ESTUDIANTES',
                                    'Gestiona el registro de estudiantes.',
                                    () => setState(() => _selectedIndex = 1),
                                    isMobile: false,
                                  ),
                                  _buildActionCard(
                                    'REGISTRO DE ADMINISTRADORES',
                                    'Administra los administradores.',
                                    () => setState(() => _selectedIndex = 2),
                                    isMobile: false,
                                  ),
                                  _buildActionCard(
                                    'REPORTE DE EMOCIONES',
                                    'Visualiza reportes de emociones.',
                                    () => setState(() => _selectedIndex = 3),
                                    isMobile: false,
                                  ),
                                  _buildActionCard(
                                    'DASHBOARD GENERAL',
                                    'Revisa estadísticas generales.',
                                    () => setState(() => _selectedIndex = 4),
                                    isMobile: false,
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      )
                      : _screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String description,
    VoidCallback onTap, {
    required bool isMobile,
  }) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          width: isMobile ? double.infinity : 300,
          height: 220,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[200]!, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.blue[100]!.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                child: Text(
                  'Ir a conocer',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
