import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:spotibook2/Services/Dropbox_config.dart';

class DropboxService {
  // Singleton
  static final DropboxService _instance = DropboxService._internal();
  factory DropboxService() => _instance;
  DropboxService._internal();

  // Token de acceso a Dropbox
  final String _accessToken = 'TU_DROPBOX_ACCESS_TOKEN_AQUI'; // Mejor si usas un archivo config seguro

  // Subir archivo (bytes) a Dropbox
  Future<String?> uploadFileBytes(List<int> fileBytes, String dropboxPath) async {
    try {
      final uploadResponse = await http.post(
        Uri.parse('https://content.dropboxapi.com/2/files/upload'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/octet-stream',
          'Dropbox-API-Arg': jsonEncode({
            'path': dropboxPath,
            'mode': 'add',
            'autorename': true,
            'mute': false
          }),
        },
        body: fileBytes,
      );

      if (uploadResponse.statusCode != 200) {
        throw Exception('Error al subir archivo: ${uploadResponse.body}');
      }

      // Obtener enlace compartido público
      return await _getSharedLink(dropboxPath);
    } catch (e) {
      print('Error Dropbox upload: $e');
      return null;
    }
  }

  // Crear enlace compartido público
  Future<String?> _getSharedLink(String dropboxPath) async {
    final url = 'https://api.dropboxapi.com/2/sharing/create_shared_link_with_settings';

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
      // Modificar url para acceso directo a la imagen
      return json['url'].replaceFirst('?dl=0', '?raw=1');
    } else {
      print('Error creando enlace compartido: ${response.body}');
      return null;
    }
  }

  // Método auxiliar para subir archivo desde ruta local (File)
  Future<String?> uploadFileFromPath(String localPath, String dropboxPath) async {
    try {
      final bytes = await File(localPath).readAsBytes();
      return await uploadFileBytes(bytes, dropboxPath);
    } catch (e) {
      print('Error leyendo archivo local: $e');
      return null;
    }
  }

  // Puedes agregar más métodos para descargar, eliminar, listar archivos, etc.
}
