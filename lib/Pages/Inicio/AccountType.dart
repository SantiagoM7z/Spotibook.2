import 'package:flutter/material.dart';
import 'package:spotibook2/Pages/Inicio/SingUp.dart';

class AccountType extends StatelessWidget {
  const AccountType({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Fin de la Cuenta",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,),
          ),
            backgroundColor: Color(0xff2E4D4D),
            iconTheme: IconThemeData(color: Colors.white,),
            automaticallyImplyLeading: false,
          ),
          body: Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
              Text("¿Cómo planeas usar tu cuenta?", textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily:"Lora",
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20), //todo separación de botones
              // *Botones para determinar el Tipo de Cuenta
              ElevatedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>SingUp(UserType: "Lector")));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff2E4D4D),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15)
              ),
              child: Text("Como Lector", style: TextStyle(fontSize: 20, color: Colors.white),),
              ),
              SizedBox(height: 10), //todo separación de botones
              ElevatedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>SingUp(UserType: "Autor")));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff2E4D4D),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15)
                ),
                child: Text("Como Autor", style: TextStyle(fontSize: 20, color: Colors.white),),
                ),
                SizedBox(height: 10), //todo separación de botones
                ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>SingUp(UserType: "Editorial")));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff2E4D4D),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15)
                  ),
                  child: Text("Como Editorial", style: TextStyle(fontSize: 20, color: Colors.white),),
                ),
          ]
          )
          )
    );
  }
}