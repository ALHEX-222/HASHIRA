import 'package:flutter/material.dart';
import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../services/auth_service.dart';

class ChatBody extends StatefulWidget {
  final String userId;

  const ChatBody({super.key, required this.userId});

  @override
  _ChatBodyState createState() => _ChatBodyState();
}

class _ChatBodyState extends State<ChatBody> with TickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  late AnimationController _gradientController;
  late Animation<Color?> _gradientAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechInitialized = false;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    _gradientAnimation = ColorTween(
      begin: Colors.blue[50],
      end: Colors.blue[100],
    ).animate(_gradientController)..addListener(() {
      setState(() {});
    });
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _gradientController.forward();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechInitialized = await _speech.initialize(
      onStatus: (status) {
        debugPrint('Estado: $status');
        if (status == 'done' || status == 'notListening') {
          if (mounted) {
            setState(() => _isListening = false);
            _pulseController.stop();
          }
        }
      },
      onError: (error) {
        debugPrint('Error: $error');
        if (mounted) {
          setState(() => _isListening = false);
          _pulseController.stop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error de micrófono: $error'),
              backgroundColor: Colors.red[700],
            ),
          );
        }
      },
    );
    if (!_speechInitialized && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'El reconocimiento de voz no está disponible en este dispositivo.',
          ),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_messages.isEmpty) {
      _cargarBienvenida();
    }
  }

  Future<void> _cargarBienvenida() async {
    try {
      final saludo = await bienvenida(WelcomeRequest(email: widget.userId));
      if (mounted) {
        setState(() {
          _messages.add({
            'text': saludo,
            'isUser': false,
            'time': TimeOfDay.now().format(context),
          });
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar mensaje de bienvenida: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  Future<void> _sendMessage(String message) async {
    if (message.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor, escribe un mensaje.'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
      return;
    }

    if (mounted) {
      setState(() {
        _messages.add({
          'text': message,
          'isUser': true,
          'time': TimeOfDay.now().format(context),
        });
        _isTyping = true;
      });
    }

    try {
      final respuesta = await chat(ChatRequest(message: message));
      if (mounted) {
        setState(() {
          _messages.add({
            'text': respuesta,
            'isUser': false,
            'time': TimeOfDay.now().format(context),
          });
          _isTyping = false;
          _messageController.clear();
        });
      }

      await Future.delayed(const Duration(milliseconds: 100));
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar mensaje: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
        setState(() => _isTyping = false);
      }
    }
  }

  void _startListening() async {
    if (!_speechInitialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reconocimiento de voz no disponible.'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
      return;
    }

    if (!_isListening) {
      if (mounted) {
        setState(() {
          _isListening = true;
          _messageController.text = '';
        });
      }
      _pulseController.repeat(reverse: true);
      _speech.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _messageController.text = result.recognizedWords;
            });
          }
        },
        localeId: 'es-ES',
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      );
    }
  }

  void _stopListening() async {
    if (_isListening && mounted) {
      setState(() => _isListening = false);
      _pulseController.stop();
      await _speech.stop();
      if (_messageController.text.isNotEmpty) {
        await _sendMessage(_messageController.text);
        if (mounted) {
          setState(() {
            _messageController.clear();
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _messageController.clear();
          });
        }
      }
    }
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
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _gradientController.dispose();
    _pulseController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_gradientAnimation.value!, Colors.blue[50]!],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  itemCount: _messages.length,
                  itemBuilder: (ctx, index) {
                    final message = _messages[index];
                    final isUser = message['isUser'] == true;
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.only(
                        top: 8,
                        bottom: 8,
                        left: isUser ? 50 : 12,
                        right: isUser ? 12 : 50,
                      ),
                      child: Row(
                        mainAxisAlignment:
                            isUser
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isUser)
                            Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: CircleAvatar(
                                backgroundImage: AssetImage(
                                  'assets/images/perfilHashira.png',
                                ),
                                radius: isMobile ? 16 : 20,
                                backgroundColor: Colors.blue[200],
                              ),
                            ),
                          Flexible(
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Container(
                                padding: EdgeInsets.all(isMobile ? 12 : 16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors:
                                        isUser
                                            ? [
                                              Colors.blue[200]!,
                                              Colors.blue[100]!,
                                            ]
                                            : [Colors.white, Colors.blue[50]!],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      isUser
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message['text'] ?? '',
                                      style: TextStyle(
                                        fontSize: isMobile ? 14 : 16,
                                        color: Colors.blue[900],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      message['time'] ?? '',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (isUser)
                            Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: CircleAvatar(
                                radius: isMobile ? 16 : 20,
                                backgroundColor: Colors.blue[700],
                                foregroundColor: Colors.white,
                                child: Text(
                                  _getInitials(widget.userId),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (_isTyping)
                Padding(
                  padding: EdgeInsets.only(bottom: 10, left: 20),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.blue[700],
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Escribiendo...',
                          style: TextStyle(color: Colors.blue[900]),
                        ),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.fromLTRB(12, 8, 12, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        enabled: !_isListening,
                        decoration: InputDecoration(
                          hintText: 'Escribe tu mensaje...',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: isMobile ? 12 : 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.blue[200]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: Colors.blue[700]!,
                              width: 2,
                            ),
                          ),
                        ),
                        style: TextStyle(color: Colors.blue[900]),
                        onSubmitted: (value) => _sendMessage(value),
                      ),
                    ),
                    SizedBox(width: 8),
                    CircleAvatar(
                      radius: isMobile ? 22 : 24,
                      backgroundColor: Colors.blue[700],
                      child: IconButton(
                        icon: Icon(
                          Icons.send,
                          color: Colors.white,
                          size: isMobile ? 20 : 24,
                        ),
                        onPressed: () => _sendMessage(_messageController.text),
                      ),
                    ),
                    SizedBox(width: 8),
                    CircleAvatar(
                      radius: isMobile ? 22 : 24,
                      backgroundColor: Colors.blue[700],
                      child: IconButton(
                        icon: Icon(
                          _isListening ? Icons.stop : Icons.mic,
                          color: Colors.white,
                          size: isMobile ? 20 : 24,
                        ),
                        onPressed:
                            _isListening ? _stopListening : _startListening,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_isListening)
          Positioned.fill(
            child: GestureDetector(
              onTap: _stopListening,
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
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
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: Icon(
                              Icons.mic,
                              size: 60,
                              color: Colors.blue[700],
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Escuchando...',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                          SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _stopListening,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Detener y enviar mensaje',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
