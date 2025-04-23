import 'package:flutter/material.dart';

class HelpCenter extends StatelessWidget {
  const HelpCenter({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Centro de Ayuda",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,),),
            backgroundColor: Color(0xff2E4D4D),
            iconTheme: IconThemeData(color: Colors.white,),),
    );
  }
}