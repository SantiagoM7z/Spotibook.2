import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:spotibook2/Pages/Index/Autores/BibliotecaA.dart';
import 'package:spotibook2/Pages/Index/Autores/BuscarA.dart';
import 'package:spotibook2/Pages/Index/Autores/CatalogoA.dart';
import 'package:spotibook2/Pages/Index/Autores/PerfilA.dart';
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
  final int _selectedIndex = 2;

  // Controladores
  final TextEditingController tituloController = TextEditingController();
  final TextEditingController autorController = TextEditingController();
  final TextEditingController editorialController = TextEditingController();
  final TextEditingController sinopsisController = TextEditingController();

  // Estados
  bool isFormValid = false;
  bool isUploading = false;
  String? imagePath;
  String? filePath;
  List<String> selectedTags = [];
  List<Map<String, dynamic>> allTags = [];
  String? fileError;
  String? imageError;

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const CatalogoA()));
    } else if (index == 1) {
      Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const BuscarA()));
    } else if (index == 3) {
      Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const BibliotecaA()));
    } else if (index == 4) {
      Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const PerfilA()));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    try {
      final tags = await _firestoreService.loadTags();
      setState(() {
        allTags = tags;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al cargar etiquetas: ${e.toString()}"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      print("Error capturado en _loadTags de AgregarA: $e"); // Para la consola
    }
  }

  void _validateForm() {
    setState(() {
      isFormValid = _formKey.currentState?.validate() == true &&
          selectedTags.isNotEmpty &&
          imagePath != null &&
          filePath != null;

      fileError = filePath == null ? "Debes subir un archivo PDF o EPUB" : null;
      imageError = imagePath == null ? "Debes seleccionar una portada" : null;
    });
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          imagePath = pickedFile.path;
          imageError = null;
          _validateForm();
        });
      }
    } catch (e) {
      setState(() {
        imageError = "Error al seleccionar la imagen";
      });
      print("Error al seleccionar imagen: $e");
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'epub'],
      );

      if (result != null) {
        final extension = path.extension(result.files.single.path!).toLowerCase();
        if (extension != '.pdf' && extension != '.epub') {
          setState(() {
            fileError = "Solo se permiten archivos PDF o EPUB";
          });
          return;
        }

        setState(() {
          filePath = result.files.single.path;
          fileError = null;
          _validateForm();
        });
      }
    } catch (e) {
      setState(() {
        fileError = "Error al seleccionar el archivo";
      });
      print("Error al seleccionar archivo: $e");
    }
  }

  Future<void> _submitForm() async {
    if (!isFormValid) return;

    setState(() => isUploading = true);

    try {
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

      // * Subir portada
      final imageFile = File(imagePath!);
      final imageName = 'portada_${DateTime.now().millisecondsSinceEpoch}${path.extension(imagePath!)}';
      final imageUrl = await _dropboxService.uploadFile(imageFile, '/Revisión/$imageName');

      // * Subir archivo del libro
      final bookFile = File(filePath!);
      final bookName = 'libro_${DateTime.now().millisecondsSinceEpoch}${path.extension(filePath!)}';
      final fileUrl = await _dropboxService.uploadFile(bookFile, '/Revisión/$bookName');

      // * Guardar en Firestore
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
          content: Text('Solicitud enviada exitosamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BibliotecaA()),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar solicitud: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
      ));
    } finally {
      setState(() => isUploading = false);
    }
  }

  Future<void> _showTagSelector() async {
    List<String> tempSelected = List.from(selectedTags);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Seleccionar Etiquetas'),
              content: SizedBox(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height * 0.6,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allTags.length,
                  itemBuilder: (context, index) {
                    final tag = allTags[index];
                    return CheckboxListTile(
                      title: Text(tag['nombre'] ?? 'Nombre no disponible'), // * Por si el nombre es null
                      value: tempSelected.contains(tag['id']),
                      onChanged: (bool? value) {
                        setStateDialog(() {
                          if (value == true) {
                            tempSelected.add(tag['id']);
                          } else {
                            tempSelected.remove(tag['id']);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedTags = tempSelected;
                    });
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
              // Selector de imagen
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Portada del libro', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: imageError != null ? Colors.red : Colors.grey[300]!,
                          width: 1.5
                        ),
                        image: imagePath != null
                          ? DecorationImage(
                                image: FileImage(File(imagePath!)),
                                fit: BoxFit.cover,
                              )
                          : null,
                      ),
                      child: imagePath == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_a_photo, color: Color(0xff2E4D4D), size: 40),
                              const SizedBox(height: 8),
                              Text('Agregar portada', style: TextStyle(color: Colors.grey[600])),
                            ],
                          )
                        : null,
                    ),
                  ),
                  if (imageError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        imageError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Título
              TextFormField(
                controller: tituloController,
                decoration: const InputDecoration(
                  labelText: "Título",
                  border: OutlineInputBorder(),
                  hintText: "Introduce el título de tu libro",
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "El título es obligatorio";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // * Autor
              TextFormField(
                controller: autorController,
                decoration: const InputDecoration(
                  labelText: "Autor",
                  border: OutlineInputBorder(),
                  hintText: "Introduce el autor del libro",
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "El autor es obligatorio";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // * Editorial
              TextFormField(
                controller: editorialController,
                decoration: const InputDecoration(
                  labelText: "Editorial",
                  border: OutlineInputBorder(),
                  hintText: "Introduce la editorial del libro",
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "La editorial es obligatoria";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // * Etiquetas
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Etiquetas', style: TextStyle(fontSize: 16, color: Colors.black54)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _showTagSelector,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedTags.isEmpty ? Colors.red : Colors.grey[300]!,
                          width: 1.0
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedTags.isEmpty
                              ? "Seleccionar etiquetas"
                              : "Etiquetas seleccionadas: ${selectedTags.length}",
                            style: TextStyle(
                              color: selectedTags.isEmpty ? Colors.grey : Colors.black
                            ),
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
                      ),),
                  if (selectedTags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: selectedTags.map((tagId) {
                          var tag = allTags.firstWhere(
                            (tag) => tag['id'] == tagId,
                            orElse: () => {'nombre': 'Etiqueta no encontrada', 'id': tagId}
                          );
                          return Chip(
                            label: Text(tag['nombre'] ?? 'Sin Nombre'), 
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () {
                              setState(() {
                                selectedTags.remove(tagId);
                              });
                              _validateForm();
                            },
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // * Sinopsis
              TextFormField(
                controller: sinopsisController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: "Sinopsis",
                  border: OutlineInputBorder(),
                  hintText: "Introduce la sinopsis de tu libro",
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "La sinopsis es obligatoria";
                  } else if (value.length < 50) {
                    return "La sinopsis debe tener al menos 50 caracteres";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // * Selector de archivo
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Archivo del libro', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _pickFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: fileError != null ? Colors.red : Colors.grey[300]!,
                          width: 1.5
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.upload_file, color: Color(0xff2E4D4D)),
                        const SizedBox(width: 8),
                        Text(
                          filePath == null
                            ? "Subir archivo (PDF/ePUB)"
                            : path.basename(filePath!),
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  if (fileError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        fileError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // * Botón de envío
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isUploading ? null : (isFormValid ? _submitForm : null),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFormValid ? const Color(0xff2E4D4D) : Colors.grey,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isUploading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : const Text(
                          "SOLICITAR PUBLICACIÓN",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            )],
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
              leading: const Icon(Icons.exit_to_app),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xff2E4D4D),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Catalogo'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Agregar'),
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Biblioteca'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class DropboxService {
  Future<String> uploadFile(File file, String dropboxPath) async {
    try {
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
        throw Exception('Error al subir archivo a Dropbox: ${uploadResponse.body}');
      }

      return await _getSharedLink(dropboxPath);
    } catch (e) {
      throw Exception('Error en Dropbox al subir/obtener URL: ${e.toString()}');
    }
  }

  Future<String> _getSharedLink(String dropboxPath) async {
    try {
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

      if (response.statusCode == 409) {
        // Link already exists, try to get it
        return await _getExistingSharedLink(dropboxPath);
      } else if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['url'].replaceFirst('?dl=0', '?raw=1');
      } else {
        throw Exception('Error al generar enlace de Dropbox: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al obtener enlace compartido de Dropbox: ${e.toString()}');
    }
  }

  Future<String> _getExistingSharedLink(String dropboxPath) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.dropboxapi.com/2/sharing/list_shared_links'),
        headers: {
          'Authorization': 'Bearer ${DropboxConfig.token}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'path': dropboxPath,
          'direct_only': true
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final results = jsonResponse['links'] as List? ?? [];

        if (results.isNotEmpty) {
          final firstResult = results.first;
          if (firstResult is Map<String, dynamic> && firstResult.containsKey('url')) {
            return firstResult['url'].replaceFirst('?dl=0', '?raw=1');
          } else {
            throw Exception('El enlace existente no tiene URL válida');
          }
        } else {
          throw Exception('No se encontraron enlaces existentes para $dropboxPath');
        }
      } else {
        throw Exception('Error al listar enlaces existentes de Dropbox: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al obtener enlace existente de Dropbox: ${e.toString()}');
    }
  }
}