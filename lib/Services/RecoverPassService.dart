import 'package:http/http.dart' as http;
import 'dart:convert';

class RecoverPassService {
  final String apiKey = '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';

  Future<void> enviarCorreoRecuperacion({
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
              "codigo_recuperacion": codigoVerificacion, 
            }
          }
        ],
        "from": {
          "email": "a20300690@ceti.mx", // Correo electrónico del remitente. Debe estar verificado en SendGrid.
        },

        "template_id": "d-5418de21df3a484091dd6b0160e8b031", // Mantén tu ID de plantilla
      }),
    );

    if (response.statusCode == 202) {
      print('Correo de recuperación de contraseña enviado exitosamente.');
    } else {
      print('Error al enviar el correo de recuperación: ${response.statusCode} - ${response.body}');
    }
  }
}