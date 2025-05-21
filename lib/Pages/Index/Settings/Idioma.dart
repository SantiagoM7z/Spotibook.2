import 'package:flutter/material.dart';

class Idioma extends StatelessWidget {
  const Idioma({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Idioma'),
        backgroundColor: Color(0xff2E4D4D),
      ),
      body: Center(
        child: Text('Aquí va la configuración de Idioma'),
      ),
    );
  }
}
