import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:spotibook2/Pages/Index/Editoriales/BibliotecaE.dart';
import 'package:spotibook2/Services/Auth_Service.dart';
import 'package:spotibook2/Pages/Inicio/SingIn.dart';
import 'package:spotibook2/Services/firestore_service.dart';
import 'package:spotibook2/Services/Dropbox_config.dart';

class AgregarA extends StatefulWidget {
  const AgregarA({super.key});

  @override
  State<AgregarA> createState() => _AgregarAState();
}

class _AgregarAState extends State<AgregarA> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  final DropboxService _dropboxService = DropboxService();

  // Controladores
  TextEditingController tituloController = TextEditingController();
  TextEditingController autorController = TextEditingController();
  TextEditingController editorialController = TextEditingController();
  TextEditingController sinopsisController = TextEditingController();

  // Estados
  bool isFormValid = false;
  bool isUploading = false;
  String? imagePath;
  String? filePath;
  List<String> selectedTags = [];
  List<Map<String, dynamic>> allTags = [];

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    final tags = await _firestoreService.loadTags();
    setState(() {
      allTags = tags;
    });
  }

  void _validateForm() {
    setState(() {
      isFormValid = _formKey.currentState?.validate() == true && 
          selectedTags.isNotEmpty && 
          imagePath != null && 
          filePath != null;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
        _validateForm();
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'epub'],
    );

    if (result != null) {
      setState(() {
        filePath = result.files.single.path;
        _validateForm();
      });
    }
  }

  Future<void> _submitForm() async {
    if (!isFormValid) return;

    setState(() => isUploading = true);

    try {
      // Confirmación
      final confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Solicitar Publicación'),
          content: const Text('¿Estás seguro que deseas solicitar la publicación de este libro?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2E4D4D),
              ),
              child: const Text('Confirmar'),
            ),
          ],
        ),
      );

      if (confirm != true) {
        setState(() => isUploading = false);
        return;
      }

      // Subir archivos
      final imageFile = File(imagePath!);
      final imageName = 'portada_${DateTime.now().millisecondsSinceEpoch}${path.extension(imagePath!)}';
      final imageUrl = await _dropboxService.uploadFile(imageFile, '/Revisión/$imageName');

      final bookFile = File(filePath!);
      final bookName = 'libro_${DateTime.now().millisecondsSinceEpoch}${path.extension(filePath!)}';
      final fileUrl = await _dropboxService.uploadFile(bookFile, '/Revisión/$bookName');

      // Guardar en Firestore
      await _firestoreService.saveBook(
        titulo: tituloController.text,
        autor: autorController.text,
        editorial: editorialController.text,
        sinopsis: sinopsisController.text,
        etiquetas: selectedTags,
        portadaUrl: imageUrl,
        archivoUrl: fileUrl,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Archivos subidos exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BibliotecaE()),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isUploading = false);
    }
  }

  Future<void> _showTagSelector() async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Seleccionar Etiquetas'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allTags.length,
                  itemBuilder: (context, index) {
                    final tag = allTags[index];
                    return CheckboxListTile(
                      title: Text(tag['nombre']),
                      value: selectedTags.contains(tag['id']),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedTags.add(tag['id']);
                          } else {
                            selectedTags.remove(tag['id']);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _validateForm();
                  },
                  child: const Text('Aceptar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Solicitar Publicación",
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
          child: ListView(
            children: <Widget>[
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                    image: imagePath != null 
                      ? DecorationImage(
                          image: FileImage(File(imagePath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                  ),
                  child: imagePath == null
                    ? const Icon(Icons.add_a_photo, color: Colors.white, size: 40)
                    : null,
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: tituloController,
                decoration: const InputDecoration(
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
              
              TextFormField(
                controller: autorController,
                decoration: const InputDecoration(
                  labelText: "Autor",
                  border: OutlineInputBorder(),
                  hintText: "Introduce el autor del libro",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "El autor es obligatorio";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: editorialController,
                decoration: const InputDecoration(
                  labelText: "Editorial",
                  border: OutlineInputBorder(),
                  hintText: "Introduce la editorial del libro",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "La editorial es obligatoria";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              InkWell(
                onTap: _showTagSelector,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: "Etiquetas",
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedTags.isEmpty 
                          ? "Seleccionar etiquetas" 
                          : "Seleccionadas: ${selectedTags.length}",
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              if (selectedTags.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 4.0),
                  child: Text(
                    "Debes seleccionar al menos una etiqueta",
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: sinopsisController,
                maxLines: 5,
                decoration: const InputDecoration(
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
              
              ElevatedButton(
                onPressed: _pickFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.upload_file),
                    const SizedBox(width: 8),
                    Text(
                      filePath == null 
                        ? "Subir archivo (PDF/ePUB)" 
                        : path.basename(filePath!),
                    ),
                  ],
                ),
              ),
              if (filePath == null)
                const Padding(
                  padding: EdgeInsets.only(top: 4.0),
                  child: Text(
                    "Debes subir un archivo",
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 24),
              
              Center(
                child: ElevatedButton(
                  onPressed: isUploading ? null : (isFormValid ? _submitForm : null),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2E4D4D),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Solicitar Publicación", style: TextStyle(fontSize: 16)),
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
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xff2E4D4D)),
              child: Text(
                'Menú',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              title: const Text('Cerrar sesión'),
              onTap: () async {
                await AuthService().signOut(); 
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => SingIn()),
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

class DropboxService {
  Future<String> uploadFile(File file, String dropboxPath) async {
    try {
      // Subir archivo
      final uploadResponse = await http.post(
        Uri.parse('https://content.dropboxapi.com/2/files/upload'),
        headers: {
          'Authorization': 'Bearer ${DropboxConfig.token}',
          'Content-Type': 'application/octet-stream',
          'Dropbox-API-Arg': jsonEncode({
            'path': dropboxPath,
            'mode': 'add',
            'autorename': true,
            'mute': false
          })
        },
        body: await file.readAsBytes(),
      );

      if (uploadResponse.statusCode != 200) {
        throw Exception('Error al subir: ${uploadResponse.body}');
      }

      // Obtener enlace público
      return await _getSharedLink(dropboxPath);
    } catch (e) {
      throw Exception('Error Dropbox: $e');
    }
  }

  Future<String> _getSharedLink(String dropboxPath) async {
    final response = await http.post(
      Uri.parse('https://api.dropboxapi.com/2/sharing/create_shared_link_with_settings'),
      headers: {
        'Authorization': 'Bearer ${DropboxConfig.token}',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'path': dropboxPath,
        'settings': {'requested_visibility': 'public'}
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['url'].replaceFirst('?dl=0', '?raw=1');
    } else {
      throw Exception('Error al generar enlace: ${response.body}');
    }
  }
}