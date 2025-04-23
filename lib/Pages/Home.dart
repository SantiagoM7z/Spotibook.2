import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Bienvenido a Spotibook",
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