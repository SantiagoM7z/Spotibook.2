import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';  // Importa firebase_core
import 'firebase_options.dart';  // Importa firebase_options.dart generado por FlutterFire CLI

import 'package:spotibook2/Pages/AccountType.dart';
import 'package:spotibook2/Pages/HelpCenter.dart';
import 'package:spotibook2/Pages/SingIn.dart';
import 'package:spotibook2/Pages/TermsYCond.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Asegúrate de que Flutter esté inicializado
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

  runApp(Spotibook());
}

class Spotibook extends StatelessWidget {
  const Spotibook({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(builder:(context)=>Scaffold(
        body: Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
              Text("BIENVENIDO", textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily:"Lora",
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold),),
              

              Text("SpotiBook", textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily:"Lora",
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold),),

              ElevatedButton(onPressed: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context)=>SingIn()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff2E4D4D),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15)
                ),
              child: Text("Iniciar Sesión", style: TextStyle(
                fontSize: 20,
                color: Colors.white
              ),),),

              TextButton(onPressed: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context)=>AccountType()));
              },
              style: TextButton.styleFrom(
                foregroundColor: Color(0xff2E4D4D),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: Text("Registrarse"),),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                TextButton(onPressed: () {
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context)=>TermsYCond()));
                },
                style: TextButton.styleFrom(
                  foregroundColor: Color(0xff2E4D4D),
                  textStyle: TextStyle(fontSize: 10,
                  ),),
              child: Text("Terminos y Condiciones"),),

              TextButton(onPressed: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context)=>HelpCenter()));
              },
              style: TextButton.styleFrom(
                foregroundColor: Color(0xff2E4D4D),
                textStyle: TextStyle(fontSize: 10,
                ),),
              child: Text("Centro de Ayuda"),),
                ],)
          ],),),
        )
      )
    );
  }
}
