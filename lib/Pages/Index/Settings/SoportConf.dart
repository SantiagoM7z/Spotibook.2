import 'package:flutter/material.dart';

class SoportConf extends StatelessWidget {
  const SoportConf({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Soporte Técnico'),
        backgroundColor: Color(0xff2E4D4D),
      ),
      body: Center(
        child: Text('Aquí va la configuración de Soporte Técnico'),
      ),
    );
  }
}
