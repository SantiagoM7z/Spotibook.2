import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotibook2/Services/Auth_Service.dart';
import 'package:spotibook2/Pages/Inicio/SingIn.dart';
import 'package:spotibook2/Services/Firestore_service.dart'; // Asegúrate de tener este archivo y clase
import 'package:spotibook2/Services/DropboxService.dart'; // Asegúrate de tener este archivo y clase
import 'package:path_provider/path_provider.dart'; // Para obtener directorios temporales
import 'dart:io'; // Para manejar archivos
import 'package:http/http.dart' as http; // Para descargar archivos desde URL

class AoD extends StatefulWidget {
  final String documentId; // El ID del documento en 'solicitudes_publicacion'
  final Map<String, dynamic> libro; // Los datos del libro de 'solicitudes_publicacion'

  const AoD({
    super.key,
    required this.documentId,
    required this.libro,
  });

  @override
  State<AoD> createState() => _AoDState();
}

class _AoDState extends State<AoD> {
  // 1. Estado para la selección del tipo de libro (premium/gratuito)
  // 'null' inicialmente para indicar que no se ha seleccionado nada.
  bool? _isPremium; 

  // Función para obtener el nombre de una etiqueta dado su ID
  Future<String> _getTagName(String tagId) async {
    try {
      DocumentSnapshot tagDoc = await FirebaseFirestore.instance.collection('etiquetas').doc(tagId).get();
      if (tagDoc.exists) {
        return tagDoc.get('nombre') ?? 'Etiqueta Desconocida';
      }
      return 'Etiqueta no encontrada';
    } catch (e) {
      debugPrint('Error al obtener nombre de etiqueta $tagId: $e');
      return 'Error al cargar etiqueta';
    }
  }

  Future<void> _abrirArchivo(BuildContext context) async {
    try {
      final url = widget.libro['archivoUrlRevision'];
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
      final url = widget.libro['portadaUrlRevision'];
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
    // Asegurarse de que se ha seleccionado una opción antes de proceder
    if (_isPremium == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar si el libro es Premium o Gratuito.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final FirestoreService firestoreService = FirestoreService();
    final DropboxService dropboxService = DropboxService();

    BuildContext? progressDialogContext;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        progressDialogContext = ctx;
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

      final String? portadaUrlRevision = widget.libro['portadaUrlRevision'];
      if (portadaUrlRevision != null && portadaUrlRevision.isNotEmpty) {
        final String fileName = 'portada_${widget.documentId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
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

      final String? archivoUrlRevision = widget.libro['archivoUrlRevision'];
      if (archivoUrlRevision != null && archivoUrlRevision.isNotEmpty) {
        String fileExtension = '.pdf';
        if (archivoUrlRevision.contains('.')) {
          fileExtension = '.' + archivoUrlRevision.split('.').last;
        }
        final String fileName = 'libro_${widget.documentId}_${DateTime.now().millisecondsSinceEpoch}${fileExtension}';
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

      Map<String, dynamic> libroPublicadoData = Map.from(widget.libro);
      libroPublicadoData['portadaUrl'] = portadaUrlPublicado;
      libroPublicadoData['archivoUrl'] = archivoUrlPublicado;
      libroPublicadoData['estado'] = 'publicado';
      libroPublicadoData['fechaPublicacion'] = Timestamp.now();
      libroPublicadoData['isPremium'] = _isPremium; // 2. Agregar el campo isPremium

      // Manejo de Etiquetas: Convertir IDs a Nombres antes de publicar
      if (libroPublicadoData.containsKey('etiquetas') && libroPublicadoData['etiquetas'] is List) {
        List<String> tagIds = List<String>.from(libroPublicadoData['etiquetas']);
        List<String> tagNames = [];
        for (String id in tagIds) {
          String name = await _getTagName(id);
          tagNames.add(name);
        }
        libroPublicadoData['etiquetas'] = tagNames;
      }

      libroPublicadoData.remove('portadaUrlRevision');
      libroPublicadoData.remove('archivoUrlRevision');
      if (libroPublicadoData.containsKey('fechaSubida') && !libroPublicadoData.containsKey('fechaSolicitud')) {
        libroPublicadoData['fechaSolicitud'] = libroPublicadoData['fechaSubida'];
        libroPublicadoData.remove('fechaSubida');
      }

      await firestoreService.publishBook(libroPublicadoData);
      await firestoreService.updateBookRequestStatus(widget.documentId, 'aprobado');

      if (progressDialogContext != null && Navigator.of(progressDialogContext!).canPop()) {
        Navigator.pop(progressDialogContext!);
      }

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${widget.libro['titulo'] ?? 'El libro'}" ha sido aprobado y publicado.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Error general al aprobar libro: $e');
      if (progressDialogContext != null && Navigator.of(progressDialogContext!).canPop()) {
        Navigator.pop(progressDialogContext!);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al aprobar "${widget.libro['titulo'] ?? 'el libro'}". Intenta de nuevo. Detalles: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rechazarLibro(BuildContext context) async {
    final FirestoreService firestoreService = FirestoreService();
    final TextEditingController motivoController = TextEditingController();

    BuildContext? progressDialogContext;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rechazar libro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Estás seguro de rechazar "${widget.libro['titulo'] ?? 'el libro'}"?'),
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
            onPressed: () => Navigator.pop(dialogContext),
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

              Navigator.pop(dialogContext);

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) {
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
                await firestoreService.updateBookRequestStatus(
                  widget.documentId,
                  'rechazado',
                  motivoRechazo: motivoController.text.trim(),
                );

                if (progressDialogContext != null && Navigator.of(progressDialogContext!).canPop()) {
                  Navigator.pop(progressDialogContext!);
                }

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('"${widget.libro['titulo'] ?? 'El libro'}" ha sido rechazado.'),
                    backgroundColor: Colors.red,
                  ),
                );
              } catch (e) {
                debugPrint('Error al rechazar libro: $e');
                if (progressDialogContext != null && Navigator.of(progressDialogContext!).canPop()) {
                  Navigator.pop(progressDialogContext!);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al rechazar "${widget.libro['titulo'] ?? 'el libro'}". Intenta de nuevo. Detalles: ${e.toString()}'),
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
          widget.libro['titulo'] ?? 'Detalles del Libro',
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
                child: widget.libro['portadaUrlRevision'] != null && (widget.libro['portadaUrlRevision'] as String).isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: widget.libro['portadaUrlRevision'],
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
              widget.libro['titulo'] ?? 'Título Desconocido',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (widget.libro['autor'] != null && (widget.libro['autor'] as String).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Autor: ${widget.libro['autor']}',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            if (widget.libro['editorial'] != null && (widget.libro['editorial'] as String).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Editorial: ${widget.libro['editorial']}',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            if (widget.libro['fechaSolicitud'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Fecha de solicitud: ${DateFormat('dd/MM/yyyy HH:mm').format((widget.libro['fechaSolicitud'] as Timestamp).toDate())}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            const SizedBox(height: 16),
            // Modificación aquí para mostrar nombres de etiquetas
            if (widget.libro['etiquetas'] != null && (widget.libro['etiquetas'] is List) && (widget.libro['etiquetas'] as List).isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: (widget.libro['etiquetas'] as List<dynamic>).map((tagId) {
                  return FutureBuilder<String>(
                    future: _getTagName(tagId.toString()),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Chip(
                          label: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                          ),
                          backgroundColor: colorPrincipal.withOpacity(0.1),
                        );
                      } else if (snapshot.hasError) {
                        debugPrint('Error al cargar nombre de etiqueta: ${snapshot.error}');
                        return Chip(
                          label: const Text('Error', style: TextStyle(color: Colors.red)),
                          backgroundColor: Colors.red.withOpacity(0.1),
                        );
                      } else if (snapshot.hasData) {
                        return Chip(
                          label: Text(snapshot.data!),
                          backgroundColor: colorPrincipal.withOpacity(0.1),
                        );
                      }
                      return Chip(
                        label: const Text('Cargando...'),
                        backgroundColor: colorPrincipal.withOpacity(0.1),
                      );
                    },
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
              widget.libro['sinopsis'] ?? 'No hay sinopsis disponible',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            // --- Nueva sección para el tipo de libro (Premium/Gratuito) ---
            const Text('Tipo de Libro:',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Premium💎',style: TextStyle(fontSize: 15)),
                    value: true,
                    groupValue: _isPremium,
                    onChanged: (bool? value) {
                      setState(() {
                        _isPremium = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Gratuito📚',style: TextStyle(fontSize: 15)),
                    value: false,
                    groupValue: _isPremium,
                    onChanged: (bool? value) {
                      setState(() {
                        _isPremium = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // 3. Botones de acción, con el botón "Aprobar" deshabilitado si no hay selección
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _isPremium == null ? null : () => _aprobarLibro(context), // Deshabilitado si _isPremium es null
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrincipal,
                    minimumSize: const Size(120, 50),
                    // Si el botón está deshabilitado, el color del texto también debe adaptarse
                    foregroundColor: _isPremium == null ? Colors.grey : Colors.white,
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