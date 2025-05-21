import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AoD extends StatelessWidget {
  final String documentId;
  final Map<String, dynamic> libro;

  const AoD({ super.key, required this.documentId, required this.libro,});

  Future<void> _abrirArchivo() async {
    try {
      final url = libro['archivoUrl'];
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'No se pudo abrir el archivo';
      }
    } catch (e) {
      debugPrint('Error al abrir archivo: $e');
    }
  }

  Future<void> _verPortada() async {
    try {
      final url = libro['portadaUrl'];
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'No se pudo abrir la imagen';
      }
    } catch (e) {
      debugPrint('Error al abrir portada: $e');
    }
  }

  void _aprobarLibro(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aprobar libro'),
        content: Text('¿Estás seguro de aprobar "${libro['titulo']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // Lógica para aprobar el libro
              // Aquí deberías actualizar el estado del libro en Firestore
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${libro['titulo']}" ha sido aprobado'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Aprobar'),
          ),
        ],
      ),
    );
  }

  void _rechazarLibro(BuildContext context) {
    final TextEditingController motivoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechazar libro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Estás seguro de rechazar "${libro['titulo']}"?'),
            const SizedBox(height: 16),
            TextField(
              controller: motivoController,
              decoration: const InputDecoration(
                labelText: 'Motivo del rechazo',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (motivoController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Debes especificar un motivo'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              // Lógica para rechazar el libro
              // Aquí deberías actualizar el estado del libro en Firestore
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${libro['titulo']}" ha sido rechazado'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorPrincipal = const Color(0xff2E4D4D);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          libro['titulo'],
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorPrincipal,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portada del libro
            GestureDetector(
              onTap: _verPortada,
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: libro['portadaUrl'] != null
                    ? CachedNetworkImage(
                        imageUrl: libro['portadaUrl'],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            color: colorPrincipal,
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      )
                    : Center(
                        child: Text(
                          'No hay portada disponible',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Botón para abrir archivo
            Center(
              child: ElevatedButton(
                onPressed: _abrirArchivo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorPrincipal,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.insert_drive_file, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Ver Archivo del Libro', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Información del libro
            Text(
              libro['titulo'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            if (libro['autor'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Autor: ${libro['autor']}',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            
            if (libro['editorial'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Editorial: ${libro['editorial']}',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            
            if (libro['fechaSubida'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Fecha de solicitud: ${DateFormat('dd/MM/yyyy HH:mm').format((libro['fechaSubida'] as Timestamp).toDate())}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Etiquetas
            if (libro['etiquetas'] != null && (libro['etiquetas'] as List).isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: (libro['etiquetas'] as List<dynamic>).map((etiqueta) {
                  return Chip(
                    label: Text(etiqueta.toString()),
                    backgroundColor: colorPrincipal.withOpacity(0.1),
                  );
                }).toList(),
              ),
            
            const SizedBox(height: 20),
            
            // Sinopsis
            const Text(
              'Sinopsis:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              libro['sinopsis'] ?? 'No hay sinopsis disponible',
              style: const TextStyle(fontSize: 16),
            ),
            
            const SizedBox(height: 30),
            
            // Botones de aprobación/rechazo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _aprobarLibro(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrincipal,
                    minimumSize: const Size(120, 50),
                  ),
                  child: const Text('Aprobar', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () => _rechazarLibro(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(120, 50),
                  ),
                  child: const Text('Rechazar', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}