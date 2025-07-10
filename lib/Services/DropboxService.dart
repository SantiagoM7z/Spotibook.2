import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:spotibook2/Services/DropboxConfig.dart';

class DropboxService {
  static final DropboxService _instance = DropboxService._internal();
  factory DropboxService() => _instance;
  DropboxService._internal();

  /// Sube un archivo a Dropbox y devuelve el enlace compartido directo.
  Future<String?> uploadFile(File file, String dropboxPath) async {
    try {
      final fileBytes = await file.readAsBytes();

      String cleanedDropboxPath = dropboxPath.trim(); 
      cleanedDropboxPath = cleanedDropboxPath.replaceAll('/ ', '/');
      cleanedDropboxPath = cleanedDropboxPath.replaceAll(' /', '/');
      cleanedDropboxPath = cleanedDropboxPath.replaceAll(RegExp(r'/+'), '/');

      if (!cleanedDropboxPath.startsWith('/')) {
        cleanedDropboxPath = '/$cleanedDropboxPath';
      }

      print('=== DEBUG: Original dropboxPath: "$dropboxPath" ===');
      print('=== DEBUG: Cleaned dropboxPath: "$cleanedDropboxPath" ===');

      final String dropboxApiArgHeader = jsonEncode({
        'path': cleanedDropboxPath,
        'mode': 'add', // Cambiado de 'overwrite' a 'add' para evitar sobrescribir si el nombre es exactamente igual y quieres múltiples versiones. Si quieres sobrescribir, usa 'overwrite'.
        'autorename': true, // Si el archivo ya existe, Dropbox añadirá un sufijo numérico
        'mute': false,
      });

      print('=== DEBUG: Dropbox-API-Arg Header Content (Final) ===');
      print(dropboxApiArgHeader);
      print('=== FIN DEBUG ===');

      final Map<String, String> headers = {
        'Authorization': 'Bearer ${DropboxConfig.token}',
        'Content-Type': 'application/octet-stream',
        'Dropbox-API-Arg': dropboxApiArgHeader,
      };

      final uploadResponse = await http.post(
        Uri.parse('https://content.dropboxapi.com/2/files/upload'),
        headers: headers,
        body: fileBytes,
      );

      if (uploadResponse.statusCode == 200) {
        print('Archivo subido con éxito a Dropbox: ${uploadResponse.body}');
        // Una vez subido, obtenemos el enlace compartido.
        return await _getSharedLink(cleanedDropboxPath);
      } else {
        print('Error al subir archivo a Dropbox (statusCode: ${uploadResponse.statusCode}): ${uploadResponse.body}');
        throw Exception('Error al subir archivo a Dropbox: ${uploadResponse.body}');
      }
    } catch (e) {
      print('Error en DropboxService.uploadFile: $e');
      return null;
    }
  }

  /// Crea un enlace compartido para un archivo específico de Dropbox.
  /// Si el enlace ya existe, intenta recuperarlo.
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
          'path': dropboxPath,
          'settings': {'requested_visibility': 'public'}
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['url'].replaceFirst('?dl=0', '?raw=1');
      } else if (response.statusCode == 409) {
        // Error 409 indica que un enlace ya existe, intentamos obtenerlo
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

  /// Obtiene un enlace compartido existente para un archivo específico de Dropbox.
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
          'path': dropboxPath,
          'direct_only': true, // Busca solo enlaces directos al archivo
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final links = jsonResponse['links'] as List;

        if (links.isNotEmpty) {
          // Busca el enlace que coincide exactamente con la ruta proporcionada
          final matchingLink = links.firstWhere(
            (link) => link['path_lower'] == dropboxPath.toLowerCase(),
            orElse: () => null, // Devuelve null si no encuentra una coincidencia exacta
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

  /// Nuevo método: Obtiene el enlace directo a un archivo de Dropbox si ya se conoce la ruta.
  /// Esto es útil para cargar recursos si ya tienes las rutas de Dropbox guardadas en Firestore.
  Future<String?> getSharedLinkDirect(String dropboxPath) async {
    // Asegura que la ruta empiece con '/'
    String cleanedDropboxPath = dropboxPath.trim();
    if (!cleanedDropboxPath.startsWith('/')) {
      cleanedDropboxPath = '/$cleanedDropboxPath';
    }

    // El método _getSharedLink ya maneja la creación o recuperación.
    // Lo hacemos público para que pueda ser llamado desde fuera de la clase si se necesita una URL de un archivo ya subido.
    try {
      return await _getSharedLink(cleanedDropboxPath);
    } catch (e) {
      print('Error en getSharedLinkDirect para $cleanedDropboxPath: $e');
      return null;
    }
  }
}