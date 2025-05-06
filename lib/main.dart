import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:spotibook2/Pages/Inicio/AccountType.dart';
import 'package:spotibook2/Pages/Suport/HelpCenter.dart';
import 'package:spotibook2/Pages/Inicio/SingIn.dart';
import 'package:spotibook2/Pages/Suport/TermsYCond.dart';

import 'package:spotibook2/Services/Auth_Service.dart'; 
import 'package:firebase_auth/firebase_auth.dart';

import 'package:spotibook2/Pages/Index/Administradores/Administradores.dart';
import 'package:spotibook2/Pages/Index/Editoriales/BibliotecaE.dart';
import 'package:spotibook2/Pages/Index/Lectores/Catalogo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: FutureBuilder(
        future: _checkIfUserIsLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data != null) {
            final user = snapshot.data;
            return _redirectToHomePage(user!);
          } else {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("BIENVENIDO", textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily:"Lora",
                        color: Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Text("SpotiBook", textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily:"Lora",
                        color: Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>SingIn()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff2E4D4D),
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15)
                      ),
                      child: Text("Iniciar Sesión", style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                    TextButton(onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>AccountType()));
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Color(0xff2E4D4D),
                      textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: Text("Registrarse"),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        TextButton(onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>TermsYCond()));
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Color(0xff2E4D4D),
                          textStyle: TextStyle(fontSize: 10),
                        ),
                        child: Text("Terminos y Condiciones"),
                        ),
                        TextButton(onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>HelpCenter()));
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Color(0xff2E4D4D),
                          textStyle: TextStyle(fontSize: 10),
                        ),
                        child: Text("Centro de Ayuda"),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Future<User?> _checkIfUserIsLoggedIn() async {
    final user = await AuthService().getCurrentUser();
    if (user != null) {
      final userType = await AuthService().getUserTypeFromUsers(user.uid);
      return userType != null ? user : null;
    }
    return null;
  }

  Widget _redirectToHomePage(User user) {
    return FutureBuilder<String?>(
      future: AuthService().getUserTypeFromUsers(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.data == "Admin") {
          return Administradores();
        } else if (snapshot.data == "Lector" || snapshot.data == "Autor") {
          return Catalogo();
        } else {
          return BibliotecaE();
        }
      },
    );
  }
}
