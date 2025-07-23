import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotibook2/Services/Auth_Service.dart';
import 'package:spotibook2/Pages/Inicio/SingIn.dart';
import 'package:spotibook2/Services/Firestore_service.dart';
import 'package:spotibook2/Services/DropboxService.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:epub_view/epub_view.dart';

//* Vistas para PDF y EPUB (cargan desde archivo local)
class PDFViewPage extends StatelessWidget {
  final File localPdfFile; 

  const PDFViewPage({super.key, required this.localPdfFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista previa del libro (PDF)', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff2E4D4D),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SfPdfViewer.file(localPdfFile),
    );
  }
}

class EpubViewPage extends StatefulWidget {
  final File localEpubFile;

  const EpubViewPage({super.key, required this.localEpubFile});

  @override
  _EpubViewPageState createState() => _EpubViewPageState();
}

class _EpubViewPageState extends State<EpubViewPage> {
  late EpubController _epubController;
  bool _isLoading = true;
  String? _errorMessage;

  //* Inicialización y carga de EPUB
  @override
  void initState() {
    super.initState();
    _loadEpub();
  }

  //* Función para cargar el archivo EPUB local
  Future<void> _loadEpub() async {
    try {
      _epubController = EpubController(
        document: EpubReader.readBook(widget.localEpubFile.readAsBytesSync()),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error al cargar ePUB localmente: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al cargar el ePUB localmente: ${e.toString()}';
      });
    }
  }

  //* Liberación de recursos del controlador EPUB
  @override
  void dispose() {
    _epubController.dispose();
    super.dispose();
  }

  //* Construcción de la interfaz de usuario para el visor EPUB
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cargando libro (EPUB)...', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xff2E4D4D),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error al cargar EPUB', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xff2E4D4D),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _errorMessage!, textAlign: TextAlign.center, 
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: EpubViewActualChapter(
          controller: _epubController,
          builder: (chapterValue) => Text(
            chapterValue?.chapter?.Title ?? 'Libro (EPUB)',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: const Color(0xff2E4D4D),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: EpubView(controller: _epubController),
    );
  }
}

//* Clase principal de la vista de detalles del libro (AoD)
class AoD extends StatefulWidget {
  final String documentId;
  final Map<String, dynamic> libro;

  const AoD({
    super.key,
    required this.documentId,
    required this.libro,
  });

  @override
  State<AoD> createState() => _AoDState();
}

class _AoDState extends State<AoD> {
  bool? _isPremium;

  //* Extraer la extensión del archivo limpiamente
  String _extractFileExtension(String url) {
    String cleanUrl = url.split('?').first;
    int dotIndex = cleanUrl.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < cleanUrl.length - 1) {
      return cleanUrl.substring(dotIndex + 1).toLowerCase();
    }
    return '';
  }

  //* Función para descargar archivos a una ubicación temporal
  Future<File?> _downloadFile(String url, String fileExtension) async {
    debugPrint('[_downloadFile] Intentando descargar de: $url');
    try {
      final response = await http.get(Uri.parse(url));
      debugPrint('[_downloadFile] Código de estado de la respuesta: ${response.statusCode}');

      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final fileName = 'temp_file_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        debugPrint('[_downloadFile] Archivo descargado localmente a: ${file.path}');
        return file;
      } else {
        debugPrint('[_downloadFile] Error al descargar archivo desde $url: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('[_downloadFile] Excepción al descargar archivo desde $url: $e');
      return null;
    }
  }

  //* Función para obtener el nombre de una etiqueta por su ID de Firestore
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

//* Función principal para abrir el archivo del libro
  Future<void> _abrirArchivo(BuildContext context) async {
    final url = widget.libro['archivoUrlRevision'];
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay URL de archivo de revisión disponible.'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('[_abrirArchivo] URL de archivo de revisión nula o vacía.');
      return;
    }

    //* Procesamiento de URL de Dropbox para descarga directa
    String finalUrl = url;
    // CAMBIO CLAVE: Lógica actualizada para enlaces de Dropbox
    if (url.contains('www.dropbox.com/scl/fi/')) { // Detecta el nuevo tipo de enlace
      if (url.contains('?')) {
        finalUrl = url + '&raw=1'; // Si ya tiene parámetros, añade &raw=1
      } else {
        finalUrl = url + '?raw=1'; // Si no tiene parámetros, añade ?raw=1
      }
    } else if (url.contains('www.dropbox.com/s/')) { // Lógica para enlaces antiguos (mantener por si acaso)
      finalUrl = url.replaceFirst('www.dropbox.com/s/', 'www.dl.dropboxusercontent.com/s/');
      if (finalUrl.contains('?dl=0')) {
        finalUrl = finalUrl.replaceFirst('?dl=0', '');
      }
      if (!finalUrl.contains('dl=1')) { // Asegura dl=1 si es un enlace antiguo
        if (finalUrl.contains('?')) {
          finalUrl += '&dl=1';
        } else {
          finalUrl += '?dl=1';
        }
      }
    }

    debugPrint('[_abrirArchivo] URL ORIGINAL: $url');
    debugPrint('[_abrirArchivo] URL FINAL PARA DESCARGA: $finalUrl');

    //* Extracción de la extensión del archivo
    final fileExtension = _extractFileExtension(finalUrl);
    debugPrint('[_abrirArchivo] EXTENSIÓN DETECTADA: $fileExtension');

    //* Mostrar un diálogo de carga mientras se descarga
    BuildContext? dialogContext;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        dialogContext = ctx;
        return const AlertDialog(
          title: Text('Abriendo libro...'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Descargando archivo, por favor espera.'),
            ],
          ),
        );
      },
    );

    File? localFile;
    try {
      //* Intento de descarga del archivo localmente
      localFile = await _downloadFile(finalUrl, fileExtension);
    } catch (e) {
      debugPrint('[_abrirArchivo] Error durante la descarga del archivo: $e');
      localFile = null;
    } finally {
      //* Cerrar el diálogo de carga
      if (dialogContext != null && Navigator.of(dialogContext!).canPop()) {
        Navigator.pop(dialogContext!);
        debugPrint('[_abrirArchivo] Diálogo de carga cerrado.');
      }
    }

    //* Lógica post-descarga: Verificación y visualización
    if (localFile != null) {
      debugPrint('[_abrirArchivo] Archivo descargado exitosamente. Intentando abrir con visor interno.');
      if (fileExtension == 'pdf') {
        //* Abrir PDF con visor interno
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PDFViewPage(localPdfFile: localFile!),
          ),
        ).then((_) async {
          //* Eliminar el archivo temporal después de cerrar el visor PDF
          try {
            await localFile!.delete();
            debugPrint('[_abrirArchivo] Archivo PDF temporal eliminado.');
          } catch (e) {
            debugPrint('[_abrirArchivo] Error al eliminar archivo PDF temporal: $e');
          }
        });
      } else if (fileExtension == 'epub') {
        //* Abrir EPUB con visor interno
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EpubViewPage(localEpubFile: localFile!),
          ),
        ).then((_) async {
          //* Eliminar el archivo temporal después de cerrar el visor EPUB
          try {
            await localFile!.delete();
            debugPrint('[_abrirArchivo] Archivo EPUB temporal eliminado.');
          } catch (e) {
            debugPrint('[_ababrirArchivo] Error al eliminar archivo EPUB temporal: $e');
          }
        });
      } else {
        //* Archivo descargado pero no es PDF/EPUB, intentar abrir externamente la URL original
        debugPrint('[_abrirArchivo] Archivo descargado pero no es PDF/EPUB ($fileExtension). Intentando abrir URL original externamente.');
        try {
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
            debugPrint('[_abrirArchivo] URL original abierta externamente: $url');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tipo de archivo no soportado por el visor interno o externo.'),
                backgroundColor: Colors.red,
              ),
            );
            debugPrint('[_abrirArchivo] No se pudo abrir la URL original externamente para tipo $fileExtension.');
          }
        } catch (e) {
          debugPrint('[_abrirArchivo] Error al abrir archivo externamente: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al intentar abrir el archivo: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        //* Asegurarse de eliminar el archivo local si se descargó pero no se usó con un visor interno
        try {
          await localFile.delete();
          debugPrint('[_abrirArchivo] Archivo temporal no utilizado eliminado.');
        } catch (e) {
          debugPrint('[_abrirArchivo] Error al eliminar archivo temporal no utilizado: $e');
        }
      }
    } else {
      //* La descarga falló completamente
      debugPrint('[_abrirArchivo] La descarga del archivo local falló. Mostrando mensaje de error.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo descargar el archivo para visualización. Intenta de nuevo.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  //* Función para ver la portada de revisión externamente
  Future<void> _verPortada(BuildContext context) async {
    try {
      final url = widget.libro['portadaUrlRevision'];
      if (url != null && await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        debugPrint('[verPortada] Portada de revisión abierta externamente: $url');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir la portada de revisión. URL no válida o disponible.'),
            backgroundColor: Colors.red,
          ),
        );
        debugPrint('[verPortada] Fallo al abrir portada de revisión. URL: $url');
      }
    } catch (e) {
      debugPrint('[verPortada] Error al abrir portada: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al abrir portada: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  //* Función para aprobar y publicar un libro
  Future<void> _aprobarLibro(BuildContext context) async {
    if (_isPremium == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar si el libro es Premium o Gratuito.'),
          backgroundColor: Colors.orange,
        ),
      );
      debugPrint('[aprobarLibro] Selección Premium/Gratuito pendiente.');
      return;
    }

    final FirestoreService firestoreService = FirestoreService();
    final DropboxService dropboxService = DropboxService();

    BuildContext? progressDialogContext;

    //* Mostrar diálogo de progreso de aprobación
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

      //* Procesamiento de la portada de revisión
      final String? portadaUrlRevision = widget.libro['portadaUrlRevision'];
      if (portadaUrlRevision != null && portadaUrlRevision.isNotEmpty) {
        final String fileName = 'portada_${widget.documentId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String dropboxPath = '/Publicaciones/Portadas/$fileName';

        try {
          final response = await http.get(Uri.parse(portadaUrlRevision));
          if (response.statusCode == 200) {
            final tempDir = await getTemporaryDirectory();
            final File tempFile = File('${tempDir.path}/$fileName');
            await tempFile.writeAsBytes(response.bodyBytes);

            portadaUrlPublicado = await dropboxService.uploadFile(tempFile, dropboxPath);
            await tempFile.delete();
            debugPrint('[aprobarLibro] Portada publicada en Dropbox: $portadaUrlPublicado');
          } else {
            debugPrint('[aprobarLibro] Error al descargar portada de revisión: ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('[aprobarLibro] Excepción al descargar/subir portada: $e');
        }
      }

      //* Procesamiento del archivo del libro de revisión
      final String? archivoUrlRevision = widget.libro['archivoUrlRevision'];
      if (archivoUrlRevision != null && archivoUrlRevision.isNotEmpty) {
        String fileExtension = '.pdf';
        fileExtension = _extractFileExtension(archivoUrlRevision);
        if (fileExtension.isNotEmpty) {
          fileExtension = '.$fileExtension';
        } else {
          fileExtension = '.tmp';
        }

        final String fileName = 'libro_${widget.documentId}_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
        final String dropboxPath = '/Publicaciones/Libros/$fileName';

        try {
          final response = await http.get(Uri.parse(archivoUrlRevision));
          if (response.statusCode == 200) {
            final tempDir = await getTemporaryDirectory();
            final File tempFile = File('${tempDir.path}/$fileName');
            await tempFile.writeAsBytes(response.bodyBytes);

            archivoUrlPublicado = await dropboxService.uploadFile(tempFile, dropboxPath);
            await tempFile.delete();
            debugPrint('[aprobarLibro] Archivo de libro publicado en Dropbox: $archivoUrlPublicado');
          } else {
            debugPrint('[aprobarLibro] Error al descargar archivo de revisión: ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('[aprobarLibro] Excepción al descargar/subir archivo: $e');
        }
      }

      //* Actualizar datos del libro para publicación
      Map<String, dynamic> libroPublicadoData = Map.from(widget.libro);
      libroPublicadoData['portadaUrl'] = portadaUrlPublicado;
      libroPublicadoData['archivoUrl'] = archivoUrlPublicado;
      libroPublicadoData['estado'] = 'publicado';
      libroPublicadoData['fechaPublicacion'] = Timestamp.now();
      libroPublicadoData['isPremium'] = _isPremium;

      //* Procesar etiquetas
      if (libroPublicadoData.containsKey('etiquetas') && libroPublicadoData['etiquetas'] is List) {
        List<String> tagIds = List<String>.from(libroPublicadoData['etiquetas']);
        List<String> tagNames = [];
        for (String id in tagIds) {
          String name = await _getTagName(id);
          tagNames.add(name);
        }
        libroPublicadoData['etiquetas'] = tagNames;
      }

      //* Limpiar datos de revisión y ajustar fechas
      libroPublicadoData.remove('portadaUrlRevision');
      libroPublicadoData.remove('archivoUrlRevision');
      if (libroPublicadoData.containsKey('fechaSubida') && !libroPublicadoData.containsKey('fechaSolicitud')) {
        libroPublicadoData['fechaSolicitud'] = libroPublicadoData['fechaSubida'];
        libroPublicadoData.remove('fechaSubida');
      }

      //* Publicar libro en Firestore y actualizar estado de solicitud
      await firestoreService.publishBook(libroPublicadoData);
      await firestoreService.updateBookRequestStatus(widget.documentId, 'aprobado');
      debugPrint('[aprobarLibro] Libro aprobado y estado actualizado en Firestore.');

      //* Cerrar diálogo de progreso
      if (progressDialogContext != null && Navigator.of(progressDialogContext!).canPop()) {
        Navigator.pop(progressDialogContext!);
      }

      //* Regresar a la pantalla anterior
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${widget.libro['titulo'] ?? 'El libro'}" ha sido aprobado y publicado.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('[aprobarLibro] Error general al aprobar libro: $e');
      //* Cerrar diálogo de progreso en caso de error
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

  //* Función para rechazar un libro
  Future<void> _rechazarLibro(BuildContext context) async {
    final FirestoreService firestoreService = FirestoreService();
    final TextEditingController motivoController = TextEditingController();

    BuildContext? progressDialogContext;

    //* Mostrar diálogo para solicitar motivo de rechazo
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

              //* Mostrar diálogo de progreso de rechazo
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
                //* Actualizar estado del libro a rechazado en Firestore
                await firestoreService.updateBookRequestStatus(
                  widget.documentId,
                  'rechazado',
                  motivoRechazo: motivoController.text.trim(),
                );
                debugPrint('[rechazarLibro] Libro rechazado y estado actualizado en Firestore.');

                //* Cerrar diálogo de progreso
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
                debugPrint('[rechazarLibro] Error al rechazar libro: $e');
                //* Cerrar diálogo de progreso en caso de error
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

  //* Construcción de la interfaz de usuario principal de AoD
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
            //* Sección de la portada
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
            //* Botón para ver el archivo del libro
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
            //* Detalles del libro (Título, Autor, Editorial, Fecha de Solicitud)
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
            //* Etiquetas del libro
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
                        debugPrint('Error al cargar nombre de etiqueta en UI: ${snapshot.error}');
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
            //* Sinopsis del libro
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
            //* Selección de tipo de libro (Premium/Gratuito)
            const Text('Tipo de Libro:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Premium💎', style: TextStyle(fontSize: 15)),
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
                    title: const Text('Gratuito📚', style: TextStyle(fontSize: 15)),
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
            //* Botones de Aprobar y Rechazar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _isPremium == null ? null : () => _aprobarLibro(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrincipal,
                    minimumSize: const Size(120, 50),
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
      //* Cajón de navegación (Drawer)
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
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => SingIn()),
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