import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailService {
  final String apiKey = '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';

  Future<void> enviarCorreo({
    required String destinatario,
    required String username,
    required String codigoVerificacion,
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
              "codigo_verificacion": codigoVerificacion
            }
          }
        ],
        "from": {
          "email": "a20300690@ceti.mx",
        },
        "template_id": "d-56dd645334cc4b8b8b4714a29f846275",
      }),
    );

    if (response.statusCode == 202) {
      print('Correo enviado.');
    } else {
      print('Error al enviar el correo: ${response.body}');
    }
  }
}
