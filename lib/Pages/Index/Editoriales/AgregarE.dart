import 'package:flutter/material.dart';
import 'package:spotibook2/Pages/Index/Lectores/Biblioteca.dart';
import 'package:spotibook2/Services/Auth_Service.dart'; 
import 'package:spotibook2/Pages/Inicio/SingIn.dart';

class AgregarE extends StatefulWidget {
  const AgregarE({super.key});

  @override
  State<AgregarE> createState() => _AgregarEState();
}

class _AgregarEState extends State<AgregarE> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController tituloController = TextEditingController();
  TextEditingController sinopsisController = TextEditingController();

  bool isFormValid = false;
  String generoSeleccionado = 'Seleccionar Género';
  List<String> generos = ['Romántico', 'Fantasía', 'Ciencia Ficción', 'Misterio', 'Terror', 'Aventura'];

  @override
  void _validateForm() {
    setState(() {
      isFormValid = _formKey.currentState!.validate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Subir Contenido",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xff2E4D4D),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        onChanged: _validateForm,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Imagen (aquí se podría agregar un selector para subir una imagen)
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: AssetImage("assets/images/placeholder.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: IconButton(
                  icon: Icon(Icons.add_a_photo, color: Colors.white, size: 40),
                  onPressed: () {
                    // Acción para seleccionar una imagen
                    print("Subir imagen");
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Titulo
              TextFormField(
                controller: tituloController,
                decoration: InputDecoration(
                  labelText: "Título",
                  border: OutlineInputBorder(),
                  hintText: "Introduce el título de tu libro",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "El título es obligatorio";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Género
              DropdownButtonFormField<String>(
                value: generoSeleccionado,
                items: generos.map((String genero) {
                  return DropdownMenuItem<String>(
                    value: genero,
                    child: Text(genero),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    generoSeleccionado = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Género",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value == 'Seleccionar Género') {
                    return "Debes seleccionar un género";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Sinopsis
              TextFormField(
                controller: sinopsisController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: "Sinopsis",
                  border: OutlineInputBorder(),
                  hintText: "Introduce la sinopsis de tu libro",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "La sinopsis es obligatoria";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Botón Enviar
              Center(
                child: ElevatedButton(
                  onPressed: isFormValid
                      ? () {
                          // Enviar el contenido del formulario
                          print("Contenido enviado");
                          // Aquí puedes añadir la lógica para guardar el contenido
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Biblioteca()),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff2E4D4D),
                    shape: StadiumBorder(),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: Text("Enviar", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xff2E4D4D)),
              child: Text(
                'Menú',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              title: Text('Cerrar sesión'),
              onTap: () async {
                await AuthService().signOut(); 
                Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => SingIn()),
                (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
