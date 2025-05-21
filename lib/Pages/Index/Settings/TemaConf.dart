import 'package:flutter/material.dart';

class TemaConf extends StatelessWidget {
  const TemaConf({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración del tema'),
        backgroundColor: Color(0xff2E4D4D),
      ),
      body: Center(
        child: Text('Aquí va la configuración del tema'),
      ),
    );
  }
}
