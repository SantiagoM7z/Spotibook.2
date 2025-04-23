import 'package:flutter/material.dart';

class SingIn extends StatefulWidget {
  const SingIn({super.key});

  @override
  State<SingIn> createState() => _SingInState();
}

class _SingInState extends State<SingIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Inicia Sesión",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,),),
            backgroundColor: Color(0xff2E4D4D),
            iconTheme: IconThemeData(color: Colors.white,),),
        body: cuerpo(),
    );
  }
}

Widget cuerpo(){
  return Container(
    decoration: BoxDecoration(
      image: DecorationImage(image: AssetImage("assets/images/.png"),
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high)),
      child: Center(
        child: Text("Si"),
      ),
  );
}