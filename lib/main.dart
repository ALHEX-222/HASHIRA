import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'login.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  String? apiKey = dotenv.env['API_KEY'];

  if (apiKey == null || apiKey.isEmpty) {
    runApp(ErrorApp(message: "No se encontró la API_KEY en el archivo .env"));
    return;
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  configureModel(apiKey);
  runApp(const MyApp());
}

class ErrorApp extends StatelessWidget {
  final String message;

  const ErrorApp({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}
