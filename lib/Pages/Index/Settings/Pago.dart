import 'package:flutter/material.dart';

class Pago extends StatelessWidget {
  const Pago({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pago'),
        backgroundColor: Color(0xff2E4D4D),
      ),
      body: Center(
        child: Text('Aquí va la configuración de Pago'),
      ),
    );
  }
}
