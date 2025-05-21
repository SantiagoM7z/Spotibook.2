import 'package:flutter/material.dart';

class Noti extends StatelessWidget {
  const Noti({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notificaciones'),
        backgroundColor: Color(0xff2E4D4D),
      ),
      body: Center(
        child: Text('Aquí va la configuración de Notificaciones'),
      ),
    );
  }
}
