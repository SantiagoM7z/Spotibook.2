import 'package:http/http.dart' as http;
import 'dart:convert';

class RecoverPassService {
  final String apiKey = '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';

  Future<void> enviarCorreoRecuperacion({
    required String destinatario,
    required String username,
    required String resetUrl,
  }) async {
    final url = Uri.parse('https://api.sendgrid.com/v3/mail/send');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "personalizations": [
          {
            "to": [
              {"email": destinatario}
            ],
            "dynamic_template_data": {
              "username": username, 
              "reset_url": resetUrl, 
            }
          }
        ],
        "from": {
          "email": "a20300690@ceti.mx",
        },
        "template_id": "d-af3bacb4316543f99a5ee2857d3e8d88",
      }),
    );

    if (response.statusCode == 202) {
      print('Correo de recuperación de contraseña enviado.');
    } else {
      print('Error al enviar el correo: ${response.body}');
    }
  }

  String generarResetUrl(String token) {
    return 'SpotiBook//reset-password?token=$token';
  }
}
