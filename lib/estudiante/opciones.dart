import 'package:flutter/material.dart';
import 'package:frontend_spc/estudiante/chat.dart';
import 'package:frontend_spc/estudiante/perfilEstudiante.dart';
import 'package:frontend_spc/login.dart';
import 'package:url_launcher/url_launcher.dart';

class MainAIScreen extends StatefulWidget {
  final String userId;

  const MainAIScreen({super.key, required this.userId});

  @override
  State<MainAIScreen> createState() => _MainAIScreenState();
}

class _MainAIScreenState extends State<MainAIScreen> {
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
                    '¿DESEA SALIR DE HASHIRA AI?',
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

  void _showCamDialog() {
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
                    'Esta opcion te enviara a HASHIRA FACE ¿Estas seguro que deseas continuar?',
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
                        onPressed: () async {
                          Navigator.of(context).pop();
                          final Uri url = Uri.parse(
                            'https://hashiraface-b2be2.web.app',
                          );
                          try {
                            await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('No se pudo abrir el enlace'),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Si',
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

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        title: Text(
          isMobile ? 'HASHIRA AI' : 'HASHIRA - ASISTENTE EMOCIONAL',
          style: TextStyle(fontSize: isMobile ? 18 : 20),
        ),
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.chat, size: isMobile ? 24 : 28),
            tooltip: 'CHAT',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => Scaffold(
                        appBar: AppBar(
                          title: Text('CHAT AI'),
                          backgroundColor: Colors.blue[800],
                          foregroundColor: Colors.white,
                        ),
                        body: ChatBody(userId: widget.userId),
                      ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.camera_alt, size: isMobile ? 24 : 28),
            tooltip: 'CAM',
            onPressed: _showCamDialog,
          ),
          IconButton(
            icon: Icon(Icons.account_circle, size: isMobile ? 24 : 28),
            tooltip: 'Perfil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PerfilEstudiante(userId: widget.userId),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, size: isMobile ? 24 : 28),
            tooltip: 'Cerrar Sesión',
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.psychology, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Bienvenido a HASHIRA AI',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Asistente Emocional Inteligente',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
