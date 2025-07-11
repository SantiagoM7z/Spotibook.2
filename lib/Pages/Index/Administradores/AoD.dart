import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotibook2/Services/Auth_Service.dart';
import 'package:spotibook2/Pages/Inicio/SingIn.dart';
import 'package:spotibook2/Services/firestore_service.dart'; // Asegúrate de tener este archivo y clase
import 'package:spotibook2/Services/DropboxService.dart'; // Asegúrate de tener este archivo y clase
import 'package:path_provider/path_provider.dart'; // Para obtener directorios temporales
import 'dart:io'; // Para manejar archivos
import 'package:http/http.dart' as http; // Para descargar archivos desde URL

class AoD extends StatelessWidget {
  final String documentId; // El ID del documento en 'solicitudes_publicacion'
  final Map<String, dynamic> libro; // Los datos del libro de 'solicitudes_publicacion'

  const AoD({
    super.key,
    required this.documentId,
    required this.libro,
  });

  Future<void> _abrirArchivo(BuildContext context) async {
    try {
      final url = libro['archivoUrlRevision'];
      if (url != null && await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir el archivo de revisión. URL no válida o disponible.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error al abrir archivo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al abrir archivo: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _verPortada(BuildContext context) async {
    try {
      final url = libro['portadaUrlRevision'];
      if (url != null && await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir la portada de revisión. URL no válida o disponible.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error al abrir portada: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al abrir portada: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _aprobarLibro(BuildContext context) async {
    final FirestoreService firestoreService = FirestoreService();
    final DropboxService dropboxService = DropboxService();

    // Context para el diálogo de progreso
    BuildContext? progressDialogContext; 

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) { // Cambiado a ctx para evitar colisión con 'context' de AoD
        progressDialogContext = ctx; // Captura el contexto del diálogo de progreso
        return const AlertDialog(
          title: Text('Aprobando libro...'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Por favor espera, moviendo archivos y actualizando base de datos.'),
            ],
          ),
        );
      },
    );

    try {
      String? portadaUrlPublicado;
      String? archivoUrlPublicado;

      final String? portadaUrlRevision = libro['portadaUrlRevision'];
      if (portadaUrlRevision != null && portadaUrlRevision.isNotEmpty) {
        final String fileName = 'portada_${documentId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String dropboxPath = '/Publicaciones/Portadas/${fileName}';

        try {
          final response = await http.get(Uri.parse(portadaUrlRevision));
          if (response.statusCode == 200) {
            final tempDir = await getTemporaryDirectory();
            final File tempFile = File('${tempDir.path}/$fileName');
            await tempFile.writeAsBytes(response.bodyBytes);

            portadaUrlPublicado = await dropboxService.uploadFile(tempFile, dropboxPath);
            await tempFile.delete();
            debugPrint('Portada publicada en Dropbox: $portadaUrlPublicado');
          } else {
            debugPrint('Error al descargar portada de revisión: ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('Excepción al descargar/subir portada: $e');
        }
      }

      final String? archivoUrlRevision = libro['archivoUrlRevision'];
      if (archivoUrlRevision != null && archivoUrlRevision.isNotEmpty) {
        String fileExtension = '.pdf';
        if (archivoUrlRevision.contains('.')) {
          fileExtension = '.' + archivoUrlRevision.split('.').last;
        }
        final String fileName = 'libro_${documentId}_${DateTime.now().millisecondsSinceEpoch}${fileExtension}';
        final String dropboxPath = '/Publicaciones/Libros/${fileName}';

        try {
          final response = await http.get(Uri.parse(archivoUrlRevision));
          if (response.statusCode == 200) {
            final tempDir = await getTemporaryDirectory();
            final File tempFile = File('${tempDir.path}/$fileName');
            await tempFile.writeAsBytes(response.bodyBytes);

            archivoUrlPublicado = await dropboxService.uploadFile(tempFile, dropboxPath);
            await tempFile.delete();
            debugPrint('Archivo de libro publicado en Dropbox: $archivoUrlPublicado');
          } else {
            debugPrint('Error al descargar archivo de revisión: ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('Excepción al descargar/subir archivo: $e');
        }
      }

      Map<String, dynamic> libroPublicadoData = Map.from(libro);
      libroPublicadoData['portadaUrl'] = portadaUrlPublicado;
      libroPublicadoData['archivoUrl'] = archivoUrlPublicado;
      libroPublicadoData['estado'] = 'publicado';
      libroPublicadoData['fechaPublicacion'] = Timestamp.now();

      libroPublicadoData.remove('portadaUrlRevision');
      libroPublicadoData.remove('archivoUrlRevision');
      if (libroPublicadoData.containsKey('fechaSubida') && !libroPublicadoData.containsKey('fechaSolicitud')) {
        libroPublicadoData['fechaSolicitud'] = libroPublicadoData['fechaSubida'];
        libroPublicadoData.remove('fechaSubida');
      }

      await firestoreService.publishBook(libroPublicadoData);
      await firestoreService.updateBookRequestStatus(documentId, 'aprobado');

      // Usar el contexto capturado para cerrar el diálogo de progreso
      if (progressDialogContext != null && Navigator.of(progressDialogContext!).canPop()) {
        Navigator.pop(progressDialogContext!);
      }
      
      // Volver a la pantalla de Verificaciones (usa el context original de AoD)
      Navigator.pop(context); 

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${libro['titulo'] ?? 'El libro'}" ha sido aprobado y publicado.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Error general al aprobar libro: $e');
      // Asegurarse de cerrar el diálogo de progreso incluso en caso de error
      if (progressDialogContext != null && Navigator.of(progressDialogContext!).canPop()) {
        Navigator.pop(progressDialogContext!);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al aprobar "${libro['titulo'] ?? 'el libro'}". Intenta de nuevo. Detalles: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rechazarLibro(BuildContext context) async {
    final FirestoreService firestoreService = FirestoreService();
    final TextEditingController motivoController = TextEditingController();

    // Context para el diálogo de progreso
    BuildContext? progressDialogContext; // <-- Variable para guardar el contexto del diálogo de progreso

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog( // Renombrado para claridad
        title: const Text('Rechazar libro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Estás seguro de rechazar "${libro['titulo'] ?? 'el libro'}"?'),
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
            onPressed: () => Navigator.pop(dialogContext), // Usa dialogContext para cerrar este diálogo
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (motivoController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Debes especificar un motivo'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(dialogContext); // Cierra el diálogo de confirmación de "Rechazar libro"

              showDialog( // Mostrar diálogo de progreso
                context: context, // Usamos el context del widget principal para mostrarlo
                barrierDismissible: false,
                builder: (ctx) { // Captura el contexto de este nuevo diálogo de progreso
                  progressDialogContext = ctx;
                  return const AlertDialog(
                    title: Text('Rechazando libro...'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Actualizando estado en base de datos.'),
                      ],
                    ),
                  );
                },
              );

              try {
                // Actualizar el estado del documento original en 'solicitudes_publicacion' a 'rechazado'
                await firestoreService.updateBookRequestStatus(
                  documentId,
                  'rechazado',
                  motivoRechazo: motivoController.text.trim(),
                );

                // --- Líneas corregidas ---
                // Cerrar el diálogo de progreso usando su propio contexto capturado
                if (progressDialogContext != null && Navigator.of(progressDialogContext!).canPop()) {
                  Navigator.pop(progressDialogContext!);
                }
                
                // Volver a la pantalla de Verificaciones usando el contexto original del AoD widget
                Navigator.pop(context); 

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('"${libro['titulo'] ?? 'El libro'}" ha sido rechazado.'),
                    backgroundColor: Colors.red,
                  ),
                );
              } catch (e) {
                debugPrint('Error al rechazar libro: $e');
                // Asegurarse de cerrar el diálogo de progreso incluso en caso de error
                if (progressDialogContext != null && Navigator.of(progressDialogContext!).canPop()) {
                  Navigator.pop(progressDialogContext!);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al rechazar "${libro['titulo'] ?? 'el libro'}". Intenta de nuevo. Detalles: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
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
          libro['titulo'] ?? 'Detalles del Libro',
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
            GestureDetector(
              onTap: () => _verPortada(context),
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: libro['portadaUrlRevision'] != null && (libro['portadaUrlRevision'] as String).isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: libro['portadaUrlRevision'],
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
            Center(
              child: ElevatedButton(
                onPressed: () => _abrirArchivo(context),
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
            Text(
              libro['titulo'] ?? 'Título Desconocido',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (libro['autor'] != null && (libro['autor'] as String).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Autor: ${libro['autor']}',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            if (libro['editorial'] != null && (libro['editorial'] as String).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Editorial: ${libro['editorial']}',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            if (libro['fechaSolicitud'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Fecha de solicitud: ${DateFormat('dd/MM/yyyy HH:mm').format((libro['fechaSolicitud'] as Timestamp).toDate())}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            const SizedBox(height: 16),
            if (libro['etiquetas'] != null && (libro['etiquetas'] is List) && (libro['etiquetas'] as List).isNotEmpty)
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xff2E4D4D)),
              child: Text(
                'Menú',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              title: const Text('Cerrar sesión'),
              onTap: () async {
                await AuthService().signOut();
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SingIn()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}