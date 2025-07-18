import 'package:flutter/material.dart';
import 'package:spotibook2/Services/Firestore_service.dart'; // Para interactuar con Firestore
import 'package:cloud_firestore/cloud_firestore.dart'; // Para el tipo Timestamp

class Hilos extends StatefulWidget {
  final String forumId; // ¡ID del foro padre!
  final String threadId; // ID del hilo/post que se va a mostrar
  final String threadTitle; // Título del hilo
  final String? currentUserId; // ID del usuario actual

  const Hilos({
    super.key,
    required this.forumId, // ¡Ahora es requerido!
    required this.threadId,
    required this.threadTitle,
    this.currentUserId,
  });

  @override
  State<Hilos> createState() => _HilosState();
}

class _HilosState extends State<Hilos> {
  final TextEditingController _commentController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  String? _currentUserName; // Nombre del usuario actual, para mostrar en los comentarios

  // Datos del hilo principal (se cargarán de Firestore)
  Map<String, dynamic>? _threadData;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserName(); // Carga el nombre del usuario al iniciar
    _loadThreadData(); // Carga los datos del hilo principal
  }

  // Carga el nombre del usuario actual (asumiendo que lo tienes en un perfil de usuario en Firestore)
  Future<void> _loadCurrentUserName() async {
    if (widget.currentUserId != null) {
      Map<String, dynamic>? userProfile = await _firestoreService.getUserData(widget.currentUserId!); // Usar getUserData
      if (mounted) {
        setState(() {
          _currentUserName = userProfile?['username'] ?? 'Usuario'; // Asume que el nombre de usuario está en 'username'
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _currentUserName = 'Anónimo'; // Si no hay usuario logueado
        });
      }
    }
  }

  // Carga los datos del hilo principal
  Future<void> _loadThreadData() async {
    try {
      // ¡Ahora usa forumId para obtener el hilo correctamente!
      Map<String, dynamic>? data = await _firestoreService.getThreadDetails(widget.forumId, widget.threadId);
      if (mounted) {
        setState(() {
          _threadData = data;
        });
      }
    } catch (e) {
      print("Error al cargar datos del hilo ${widget.threadId} en foro ${widget.forumId}: $e");
    }
  }

  // Envía un nuevo comentario al hilo
  void _sendComment() async {
    if (_commentController.text.trim().isEmpty) return; // No enviar comentarios vacíos

    if (widget.currentUserId == null || _currentUserName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para enviar comentarios.')),
      );
      return;
    }

    await _firestoreService.addCommentToThread(
      forumId: widget.forumId, // ¡Pasa el forumId!
      threadId: widget.threadId,
      texto: _commentController.text.trim(),
      uidcomentario: widget.currentUserId!,
      autorcomentarioname: _currentUserName!,
    );

    _commentController.clear(); // Limpiar el campo de texto después de enviar
  }

  @override
  Widget build(BuildContext context) {
    // Contenido del hilo principal
    final String threadAuthorName = _threadData?['autorpostname'] ?? 'Anónimo';
    final String threadContent = _threadData?['contenido'] ?? 'Contenido no disponible.';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.threadTitle, // Título del hilo
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xff2E4D4D),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Contenido principal del Hilo/Post
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.threadTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Color(0xff2E4D4D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Por: $threadAuthorName',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const Divider(height: 25, thickness: 1),
                  Text(
                    threadContent,
                    style: const TextStyle(fontSize: 18, height: 1.5),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Comentarios:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Lista de Comentarios
                  StreamBuilder<List<Map<String, dynamic>>>(
                    // ¡Ahora usa forumId y threadId para obtener los comentarios correctamente!
                    stream: _firestoreService.getCommentsForThread(widget.forumId, widget.threadId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        print("Error en StreamBuilder de comentarios: ${snapshot.error}");
                        return Center(child: Text('Error al cargar comentarios: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('Sé el primero en comentar.'));
                      }

                      List<Map<String, dynamic>> comments = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true, // Importante para que ListView.builder funcione dentro de Column/SingleChildScrollView
                        physics: const NeverScrollableScrollPhysics(), // Evita que el ListView interno tenga su propio scroll
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          var comment = comments[index];
                          bool isMe = widget.currentUserId != null && comment['uidcomentario'] == widget.currentUserId;

                          // Formatea la fecha
                          Timestamp? timestamp = comment['publicacion'] as Timestamp?;
                          String time = timestamp != null
                              ? TimeOfDay.fromDateTime(timestamp.toDate()).format(context)
                              : 'Ahora';

                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isMe ? const Color(0xff2E4D4D) : Colors.grey[300],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    comment['autorcomentarioname'] ?? 'Desconocido',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isMe ? Colors.white : Colors.black87,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    comment['texto'] ?? '',
                                    style: TextStyle(
                                      color: isMe ? Colors.white : Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    time,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isMe ? Colors.white70 : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Campo para escribir nuevo comentario
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Escribe un comentario...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    onSubmitted: (_) => _sendComment(), // Permite enviar con Enter
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendComment,
                  backgroundColor: const Color(0xff2E4D4D),
                  foregroundColor: Colors.white,
                  mini: true,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}