import 'package:flutter/material.dart';

class TermsYCond extends StatelessWidget {
  const TermsYCond({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Terminos y Condiciones",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,),),
            backgroundColor: Color(0xff2E4D4D),
            iconTheme: IconThemeData(color: Colors.white,),
            automaticallyImplyLeading: false,
          ),
    );
  }
}