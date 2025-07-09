import 'package:flutter/material.dart';

class ThreadCard extends StatelessWidget {
  final String forumId; // ¡ID del foro padre!
  final String threadId; // ID del hilo/post
  final String title; // Título del hilo
  final String authorName; // Nombre del autor del post principal
  final String contentPreview; // Contenido principal del post (o un resumen)
  final String? currentUserId; // ID del usuario actual (para pasar a la pantalla de detalle)
  final VoidCallback? onTap; // ¡AÑADIDA: Propiedad para el callback de toque!

  const ThreadCard({
    super.key,
    required this.forumId, // ¡Ahora es requerido!
    required this.threadId,
    required this.title,
    required this.authorName,
    required this.contentPreview,
    this.currentUserId,
    this.onTap, // ¡AÑADIDA: Inicialización de la propiedad onTap!
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15.0), // Margen inferior para separar las tarjetas
      elevation: 5, // Sombra para dar un efecto de elevación
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // Bordes redondeados
      child: InkWell( // ¡ENVUELVE EL CONTENIDO CON InkWell para hacerlo interactivo!
        onTap: onTap, // ¡ASIGNA EL CALLBACK onTap AQUÍ!
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título del hilo
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xff2E4D4D), // Color de tu tema
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Autor del post
              Text(
                'Por: $authorName',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              // Contenido principal del post (vista previa)
              Text(
                contentPreview,
                style: const TextStyle(fontSize: 16),
                maxLines: 4, // Limita las líneas para la vista previa
                overflow: TextOverflow.ellipsis, // Añade puntos suspensivos si el texto es muy largo
              ),
              // El botón "Comentar" se ha eliminado porque toda la tarjeta ahora es interactiva
              // a través del onTap.
            ],
          ),
        ),
      ),
    );
  }
}