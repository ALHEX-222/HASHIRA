import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:validators/validators.dart';

List<Map<String, dynamic>> historialConversacion = [];
Set<String> emocionesDetectadas = {};
List<String> situacionesEmocionales = [];
String? correoAlumno;
DocumentReference? documentoEmocionRef;
String? primerMensaje;
String? ultimaEmocion;
String? ultimoTema;

late final GenerativeModel model;

void configureModel(String apiKey) {
  if (apiKey.isEmpty) {
    throw Exception('API_KEY no configurada. Verifica .env o el código.');
  }
  model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
}

class UserRequest {
  final String email;
  final String password;
  final String? nombre;
  final String? apellidoPaterno;
  final String? apellidoMaterno;
  final String? direccion;
  final String? dni;

  UserRequest({
    required this.email,
    required this.password,
    this.nombre,
    this.apellidoPaterno,
    this.apellidoMaterno,
    this.direccion,
    this.dni,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'nombre': nombre,
    'apellidoPaterno': apellidoPaterno,
    'apellidoMaterno': apellidoMaterno,
    'direccion': direccion,
    'dni': dni,
  };
}

class ChatRequest {
  final String message;

  ChatRequest({required this.message});

  Map<String, dynamic> toJson() => {'message': message};
}

class WelcomeRequest {
  final String email;

  WelcomeRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

// Funciones auxiliares
bool esAgradecimiento(String texto) {
  return RegExp(
    r'(gracias|muchas gracias|agradecido|agradecida)',
    caseSensitive: false,
  ).hasMatch(texto);
}

bool necesitaRecomendaciones(String texto) {
  return RegExp(
    r'(consejos|tips|recomendación|qué hago|no sé|ayúdame)',
    caseSensitive: false,
  ).hasMatch(texto);
}

Future<bool> esMismoTema(String mensajeAnterior, String mensajeActual) async {
  final prompt = """¿Estos dos mensajes tratan sobre el mismo tema principal?
Mensaje 1: "$mensajeAnterior"
Mensaje 2: "$mensajeActual"
Responde solo con "sí" o "no".""";
  try {
    final content = Content.text(prompt);
    final response = await model.generateContent([content]);
    return response.text?.trim().toLowerCase() == 'sí';
  } catch (e) {
    debugPrint('Error en esMismoTema: $e');
    return false;
  }
}

Future<String> detectarEmocion(String texto) async {
  try {
    final content = Content.text(
      'Identifica la emoción principal en este texto: \'$texto\'. Devuelve solo una palabra.',
    );
    final response = await model.generateContent([content]);
    return (response.text ?? '').trim().toTitleCase();
  } catch (e) {
    debugPrint('Error en detectarEmocion: $e');
    return '';
  }
}

extension StringExtension on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}

Future<Map<String, dynamic>> register(UserRequest user) async {
  final correo = user.email.toLowerCase().trim();
  final password = user.password.trim();
  final dni = user.dni?.trim() ?? '';

  if (!isEmail(correo) ||
      !RegExp(r'^[a-z]+\.[a-z]+@spc\.edu\.pe$').hasMatch(correo)) {
    return {
      'success': false,
      'error': 'El correo debe tener el formato nombre.apellido@hashira.edu.pe',
    };
  }

  if (password.length != 8 || !RegExp(r'^\d{8}$').hasMatch(password)) {
    return {'success': false, 'error': 'La contraseña debe tener 8 dígitos.'};
  }

  if (dni.isNotEmpty &&
      (dni.length != 8 || !RegExp(r'^\d{8}$').hasMatch(dni))) {
    return {'success': false, 'error': 'El DNI debe tener 8 dígitos.'};
  }

  final usuariosRef = FirebaseFirestore.instance.collection('estudiantesSPC');
  final snapshot =
      await usuariosRef
          .where('correoEstudiante', isEqualTo: correo)
          .limit(1)
          .get();

  if (snapshot.docs.isNotEmpty) {
    return {'success': false, 'error': 'El correo ya está registrado.'};
  }

  final usuarioData = {
    'nomEstudiante': user.nombre?.trim() ?? '',
    'apePaEstudiante': user.apellidoPaterno?.trim() ?? '',
    'apeMaEstudiante': user.apellidoMaterno?.trim() ?? '',
    'correoEstudiante': correo,
    'direcEstudiante': user.direccion?.trim() ?? '',
    'dniEstudiante': dni,
    'pswEstudiante': password,
  };

  await usuariosRef.add(usuarioData);
  return {'success': true, 'user_id': correo};
}

Future<Map<String, dynamic>> login(UserRequest user) async {
  final correo = user.email.toLowerCase().trim();
  final password = user.password.trim();

  final usuariosRef = FirebaseFirestore.instance.collection('estudiantesSPC');
  final snapshot =
      await usuariosRef
          .where('correoEstudiante', isEqualTo: correo)
          .where('pswEstudiante', isEqualTo: password)
          .limit(1)
          .get();

  if (snapshot.docs.isNotEmpty) {
    return {'success': true, 'user_id': correo};
  }
  return {'success': false, 'error': 'Credenciales incorrectas.'};
}

Future<String> bienvenida(WelcomeRequest user) async {
  historialConversacion = [];
  emocionesDetectadas.clear();
  situacionesEmocionales.clear();
  correoAlumno = user.email.toLowerCase().trim();
  documentoEmocionRef = null;
  primerMensaje = null;
  ultimaEmocion = null;
  ultimoTema = null;

  final nombre = user.email.split('@')[0].replaceAll('.', ' ');
  final nombreCap = nombre.split(' ').map((p) => p.toTitleCase()).join(' ');
  final saludo =
      '¡Hola $nombreCap! 👋 Soy Hashira AI, tu asistente emocional. ¿Cómo te sientes hoy? 💭';

  historialConversacion.add({
    'role': 'assistant',
    'parts': [saludo],
  });
  return saludo;
}

Future<String> chat(ChatRequest chat) async {
  return await generarRespuestaEmocional(chat.message);
}

Future<String> generarRespuestaEmocional(String mensajeUsuario) async {
  primerMensaje ??= mensajeUsuario;

  try {
    if (esAgradecimiento(mensajeUsuario)) {
      return '¡De nada! 😊 Aquí estaré cuando me necesites. 💙';
    }

    historialConversacion.add({
      'role': 'user',
      'parts': [mensajeUsuario],
    });

    if (primerMensaje == null) {
      primerMensaje = mensajeUsuario;
    }

    final content = Content.text(
      'Identifica la emoción principal en: \'$mensajeUsuario\'. Responde solo con una palabra.',
    );
    final emocionResponse = await model.generateContent([content]);
    final emocionDetectada = (emocionResponse.text ?? '').trim().toTitleCase();

    if (emocionDetectada.isNotEmpty) {
      await guardarEmocionFirestore(emocionDetectada, mensajeUsuario);
    }

    bool mismoTema = false;
    if (historialConversacion.length > 1) {
      final recentHistory = historialConversacion.sublist(
        historialConversacion.length - min(3, historialConversacion.length),
      );
      final mensajesAnteriores =
          recentHistory
              .where((m) => m['role'] == 'user')
              .map((m) => m['parts'][0] as String)
              .toList();
      if (mensajesAnteriores.isNotEmpty) {
        mismoTema = await esMismoTema(mensajesAnteriores.first, mensajeUsuario);
      }
    }

    ultimaEmocion = emocionDetectada;

    final contexto = historialConversacion
        .sublist(
          historialConversacion.length - min(5, historialConversacion.length),
        )
        .map((m) => '${m['role']}: ${m['parts'][0]}')
        .join('\n');

    final mencionEmocion =
        mismoTema
            ? 'NO menciones "Emoción detectada"'
            : 'Comienza con \'Emoción detectada: $emocionDetectada\' solo si es un tema nuevo';

    final prompt = '''
Eres Hashira AI, un asistente emocional empático. Usa emojis adecuados.

Contexto:
$contexto

Mensaje del usuario: "$mensajeUsuario"
Emoción detectada: $emocionDetectada

Genera una respuesta que:
1. $mencionEmocion
2. Usa 1-2 emojis relevantes
3. Incluye SIEMPRE una pregunta relacionada para continuar la conversación
4. Muestra empatía y comprensión genuina
5. Si pide consejos, da exactamente 3 con 🔹
6. Máximo 3 oraciones cortas

Ejemplo de respuesta buena:
"¡Qué alegría que hayas jugado con tus primos! 👫 ¿Qué juegos disfrutaron más?"

Ejemplo de respuesta mala:
"Emoción detectada: Alegría. Me alegra que hayas jugado con tus primos."
''';

    final response = await model.generateContent([Content.text(prompt)]);
    var textoRespuesta = response.text?.trim() ?? '';

    if (necesitaRecomendaciones(mensajeUsuario)) {
      final promptConsejos =
          '''Da 3 consejos breves (con 🔹) sobre: "$mensajeUsuario". 
Considera la emoción: $emocionDetectada. Usa emojis donde sea apropiado.
Formato:
🔹 Consejo 1 (emoji si corresponde)
🔹 Consejo 2 (emoji si corresponde)
🔹 Consejo 3 (emoji si corresponde)''';
      final consejosResponse = await model.generateContent([
        Content.text(promptConsejos),
      ]);
      final consejos =
          (consejosResponse.text ?? '')
              .split('\n')
              .where((c) => c.trim().isNotEmpty)
              .take(3)
              .toList();
      textoRespuesta =
          '¡Claro! Aquí tienes algunos consejos: 💡\n' +
          consejos.map((c) => '🔹 ${c.trim()}').join('\n');
    }

    historialConversacion.add({
      'role': 'assistant',
      'parts': [textoRespuesta],
    });
    return textoRespuesta;
  } catch (e) {
    debugPrint('Error en generarRespuestaEmocional: $e');
    return '¡Vaya! Algo no ha ido bien. ¿Podrías intentarlo de nuevo? 😟';
  }
}

Future<void> guardarEmocionFirestore(String emocion, String mensaje) async {
  if (emocion.isEmpty || correoAlumno == null) return;

  try {
    final emocionesRef = FirebaseFirestore.instance.collection(
      'emocionesDetectadas',
    );

    if (documentoEmocionRef != null) {
      await documentoEmocionRef!.update({
        'emociones': FieldValue.arrayUnion([emocion.toTitleCase()]),
        'situaciones': FieldValue.arrayUnion([mensaje]),
        'ultimaActualizacion': FieldValue.serverTimestamp(),
      });
    } else {
      final docRef = await emocionesRef.add({
        'alumno': correoAlumno,
        'emociones': [emocion.toTitleCase()],
        'situaciones': [mensaje],
        'fechaHora': FieldValue.serverTimestamp(),
      });
      documentoEmocionRef = docRef;
    }
  } catch (e) {
    debugPrint('Error al guardar emoción: $e');
  }
}
