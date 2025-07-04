import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:spotibook2/Services/Dropbox_config.dart';

class DropboxService {
  // Singleton para asegurar una única instancia de DropboxService
  static final DropboxService _instance = DropboxService._internal();
  factory DropboxService() => _instance;
  DropboxService._internal();

  // Método unificado para subir un archivo (desde una ruta local de tipo File)
  // a Dropbox y obtener su URL compartida.
  Future<String?> uploadFile(File file, String dropboxPath) async {
    try {
      // Lee todos los bytes del archivo local.
      final fileBytes = await file.readAsBytes();

      // === INICIO DE LA CORRECCIÓN DE LA RUTA PARA EVITAR EL FORMATEXCEPTION ===
      String cleanedDropboxPath = dropboxPath.trim(); // 1. Elimina espacios al inicio o final de la ruta.

      // 2. Quitamos el espacio si aparece después de una barra ('/ ').
      // Esto es para corregir específicamente el "Revisión/ portada_" que causa el error.
      // Esta línea es crucial para tu problema actual.
      cleanedDropboxPath = cleanedDropboxPath.replaceAll('/ ', '/');

      // 3. Opcional: También limpia si hay un espacio antes de la barra.
      cleanedDropboxPath = cleanedDropboxPath.replaceAll(' /', '/');

      // 4. Asegurarse de que no haya múltiples barras consecutivas, salvo la raíz (ej: // -> /)
      // Esto es una buena práctica general para rutas.
      cleanedDropboxPath = cleanedDropboxPath.replaceAll(RegExp(r'/+'), '/');

      // Asegurarse de que siempre empiece con una sola barra y no termine con una barra (si es un archivo)
      if (!cleanedDropboxPath.startsWith('/')) {
        cleanedDropboxPath = '/$cleanedDropboxPath';
      }
      // Considera si la ruta termina en / y si es un archivo o carpeta.
      // Para archivos, usualmente no debe terminar en /.
      // Si dropboxPath es la ruta completa del archivo, esto está bien.
      // === FIN DE LA CORRECCIÓN DE LA RUTA ===

      // === DEBUG: Imprimir la ruta original y la ruta limpia para verificación ===
      print('=== DEBUG: Original dropboxPath: "$dropboxPath" ===');
      print('=== DEBUG: Cleaned dropboxPath: "$cleanedDropboxPath" ===');
      // === FIN DEBUG ===

      // Crea el string JSON para el header 'Dropbox-API-Arg'
      final String dropboxApiArgHeader = jsonEncode({
        'path': cleanedDropboxPath, // <--- ¡USAMOS LA RUTA LIMPIA AQUÍ!
        'mode': 'add', // Modo de subida: 'add' para añadir un nuevo archivo, o 'overwrite' si ya existe.
        'autorename': true, // Si es true, Dropbox renombra el archivo si ya existe.
        'mute': false, // Si es true, no notifica al usuario sobre la subida.
      });

      // === DEBUG: Imprimir el encabezado final para verificación ===
      print('=== DEBUG: Dropbox-API-Arg Header Content (Final) ===');
      print(dropboxApiArgHeader);
      print('=== FIN DEBUG ===');

      // Define las cabeceras para la solicitud de subida
      final Map<String, String> headers = {
        'Authorization': 'Bearer ${DropboxConfig.token}',
        'Content-Type': 'application/octet-stream',
        'Dropbox-API-Arg': dropboxApiArgHeader,
      };

      // Realiza la solicitud POST a la API de Dropbox para subir el archivo.
      final uploadResponse = await http.post(
        Uri.parse('https://content.dropboxapi.com/2/files/upload'),
        headers: headers,
        body: fileBytes,
      );

      // Verifica el código de estado de la respuesta.
      if (uploadResponse.statusCode != 200) {
        print('Error al subir archivo a Dropbox (statusCode: ${uploadResponse.statusCode}): ${uploadResponse.body}');
        // Si el error persiste, el cuerpo de la respuesta de Dropbox puede dar más pistas.
        throw Exception('Error al subir archivo a Dropbox: ${uploadResponse.body}');
      }

      // Si la subida fue exitosa, procede a obtener o crear el enlace compartido.
      return await _getSharedLink(cleanedDropboxPath); // <--- ¡USAMOS LA RUTA LIMPIA AQUÍ TAMBIÉN!
    } catch (e) {
      print('Error en DropboxService.uploadFile: $e');
      return null;
    }
  }

  // Método para crear o obtener un enlace compartido público para un archivo en Dropbox.
  Future<String?> _getSharedLink(String dropboxPath) async {
    final url = 'https://api.dropboxapi.com/2/sharing/create_shared_link_with_settings';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${DropboxConfig.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'path': dropboxPath, // <--- Esta path ya debería venir limpia del uploadFile
          'settings': {'requested_visibility': 'public'}
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['url'].replaceFirst('?dl=0', '?raw=1');
      } else if (response.statusCode == 409) {
        // Error 409 significa que ya existe un enlace compartido para este path.
        print('Enlace compartido ya existe, intentando obtener el existente para: $dropboxPath');
        return await _getExistingSharedLink(dropboxPath);
      } else {
        print('Error inesperado creando enlace compartido (statusCode: ${response.statusCode}): ${response.body}');
        throw Exception('No se pudo crear/obtener enlace compartido: ${response.body}');
      }
    } catch (e) {
      print('Error en _getSharedLink: $e');
      rethrow;
    }
  }

  // Método auxiliar para obtener un enlace compartido que ya existe para un archivo.
  Future<String?> _getExistingSharedLink(String dropboxPath) async {
    final url = 'https://api.dropboxapi.com/2/sharing/list_shared_links';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${DropboxConfig.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'path': dropboxPath, // <--- Esta path ya debería venir limpia del uploadFile
          'direct_only': true, // Solo enlaces directos (no carpetas compartidas, etc.)
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final links = jsonResponse['links'] as List;

        if (links.isNotEmpty) {
          // Busca el enlace que coincida exactamente con la ruta (ignorando mayúsculas/minúsculas).
          final matchingLink = links.firstWhere(
            (link) => link['path_lower'] == dropboxPath.toLowerCase(),
            orElse: () => null, // Retorna null si no encuentra ninguna coincidencia.
          );

          if (matchingLink != null) {
            return matchingLink['url'].replaceFirst('?dl=0', '?raw=1');
          } else {
            print('No se encontró enlace existente que coincida exactamente con la ruta para: $dropboxPath');
            return null;
          }
        } else {
          print('No se encontraron enlaces compartidos existentes para: $dropboxPath');
          return null;
        }
      } else {
        print('Error listando enlaces compartidos (statusCode: ${response.statusCode}): ${response.body}');
        throw Exception('Error al listar enlaces compartidos: ${response.body}');
      }
    } catch (e) {
      print('Error en _getExistingSharedLink: $e');
      rethrow;
    }
  }
}