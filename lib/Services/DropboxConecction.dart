import 'package:dropbox_client/dropbox_client.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DropboxService {
  // Singleton
  static final DropboxService _instance = DropboxService._internal();
  factory DropboxService() => _instance;
  DropboxService._internal();

  bool _initialized = false;

  // Inicializa Dropbox con tu APP_KEY
  Future<void> init() async {
    if (!_initialized) {
      await Dropbox.init('bi44noe3zqjcn98','','');
      _initialized = true;
    }
  }

  // Subir archivo local a Dropbox
  Future<String?> uploadFile(String localPath, String dropboxPath) async {
    await init();
    try {
      final res = await Dropbox.upload(localPath, dropboxPath);
      return res; // Devuelve ruta o resultado
    } catch (e) {
      print('Error subiendo archivo a Dropbox: $e');
      return null;
    }
  }

  // Crear enlace compartido para un archivo
  Future<String?> createSharedLink(String dropboxPath, String accessToken) async {
    final url = 'https://api.dropboxapi.com/2/sharing/create_shared_link_with_settings';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'path': dropboxPath,
        'settings': {'requested_visibility': 'public'},
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['url'];
    } else {
      print('Error creando enlace compartido: ${response.body}');
      return null;
    }
  }

  // Otros métodos útiles pueden agregarse aquí (descargar, eliminar, listar archivos, etc.)
}
