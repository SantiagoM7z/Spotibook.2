import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:spotibook2/Pages/Index/Autores/BibliotecaA.dart';
import 'package:spotibook2/Pages/Index/Autores/BuscarA.dart';
import 'package:spotibook2/Pages/Index/Autores/CatalogoA.dart';
import 'package:spotibook2/Pages/Index/Autores/PerfilA.dart';
import 'package:spotibook2/Pages/Index/Settings/ConfiguracionporUsuario/ConfiguracionAut.dart';
import 'package:spotibook2/Services/Auth_Service.dart';
import 'package:spotibook2/Pages/Inicio/SingIn.dart';
import 'package:spotibook2/Services/firestore_service.dart';
import 'package:spotibook2/Services/DropboxService.dart'; // Importar correctamente DropboxService

class AgregarA extends StatefulWidget {
  final Map<String, dynamic>? bookToEdit;
  const AgregarA({super.key, this.bookToEdit});
  @override
  State<AgregarA> createState() => _AgregarAState();
}

class _AgregarAState extends State<AgregarA> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  final DropboxService _dropboxService = DropboxService();
  final int _selectedIndex = 2;
  final TextEditingController tituloController = TextEditingController();
  final TextEditingController autorController = TextEditingController();
  final TextEditingController editorialController = TextEditingController();
  final TextEditingController sinopsisController = TextEditingController();

  bool isFormValid = false;
  bool isUploading = false;
  String? imagePath;
  String? filePath;
  String? _currentCoverImageUrl;
  String? _currentFileUrl;
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
    if (widget.bookToEdit != null) {
      tituloController.text = widget.bookToEdit!['titulo'] ?? '';
      autorController.text = widget.bookToEdit!['autor'] ?? '';
      editorialController.text = widget.bookToEdit!['editorial'] ?? '';
      sinopsisController.text = widget.bookToEdit!['sinopsis'] ?? '';
      selectedTags = List<String>.from(widget.bookToEdit!['etiquetas'] ?? []);
      _currentCoverImageUrl = widget.bookToEdit!['portadaUrlRevision'];
      _currentFileUrl = widget.bookToEdit!['archivoUrlRevision'];
    }
  }

  @override
  void dispose() {
    tituloController.dispose();
    autorController.dispose();
    editorialController.dispose();
    sinopsisController.dispose();
    super.dispose();
  }

  Future<void> _loadTags() async {
    try {
      final tags = await _firestoreService.loadTags();
      setState(() {
        allTags = tags;
      });
      _validateForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al cargar etiquetas: ${e.toString()}"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      print("Error capturado en _loadTags de AgregarA: $e");
    }
  }

  void _validateForm() {
    setState(() {
      isFormValid = _formKey.currentState?.validate() == true &&
          selectedTags.isNotEmpty &&
          (imagePath != null ||
              (_currentCoverImageUrl != null && _currentCoverImageUrl!.isNotEmpty)) &&
          (filePath != null ||
              (_currentFileUrl != null && _currentFileUrl!.isNotEmpty));
      imageError = (imagePath == null &&
              (_currentCoverImageUrl == null || _currentCoverImageUrl!.isEmpty))
          ? "Debes seleccionar una portada"
          : null;
      fileError = (filePath == null &&
              (_currentFileUrl == null || _currentFileUrl!.isEmpty))
          ? "Debes subir un archivo PDF o EPUB"
          : null;
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
          _currentCoverImageUrl = null;
          _validateForm();
        });
      }
    } catch (e) {
      setState(() {
        imageError = "Error al seleccionar la imagen: ${e.toString()}";
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
          _currentFileUrl = null;
          _validateForm();
        });
      }
    } catch (e) {
      setState(() {
        fileError = "Error al seleccionar el archivo: ${e.toString()}";
      });
      print("Error al seleccionar archivo: $e");
    }
  }

  Future<void> _submitForm() async {
    if (!isFormValid) {
      _formKey.currentState?.validate();
      _validateForm();
      return;
    }
    setState(() => isUploading = true);

    try {
      final confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(widget.bookToEdit != null
              ? 'Confirmar Edición'
              : 'Solicitar Publicación'),
          content: Text(widget.bookToEdit != null
              ? '¿Estás seguro que deseas actualizar la información de este libro?'
              : '¿Estás seguro que deseas solicitar la publicación de este libro?'),
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

      String? finalImageUrl = _currentCoverImageUrl;
      String? finalFileUrl = _currentFileUrl;
      if (imagePath != null) {
        final imageFile = File(imagePath!);
        final imageName =
            'portada_revision_${DateTime.now().millisecondsSinceEpoch}${path.extension(imagePath!)}';
        finalImageUrl = await _dropboxService.uploadFile(imageFile, '/Revisiones/$imageName');
      }

      if (filePath != null) {
        final bookFile = File(filePath!);
        final bookName =
            'libro_revision_${DateTime.now().millisecondsSinceEpoch}${path.extension(filePath!)}';
        finalFileUrl = await _dropboxService.uploadFile(bookFile, '/Revisiones/$bookName');
      }

      final Map<String, dynamic> bookData = {
        'titulo': tituloController.text,
        'autor': autorController.text,
        'editorial': editorialController.text,
        'sinopsis': sinopsisController.text,
        'etiquetas': selectedTags,
        'portadaUrlRevision': finalImageUrl,
        'archivoUrlRevision': finalFileUrl,
        'lastUpdated': DateTime.now(),
      };

      if (widget.bookToEdit != null && widget.bookToEdit!['id'] != null) {
        await _firestoreService.updateBookRequest(widget.bookToEdit!['id'], bookData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Libro actualizado exitosamente!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        await _firestoreService.saveBookRequest(
          titulo: bookData['titulo'] as String,
          autor: bookData['autor'] as String,
          editorial: bookData['editorial'] as String,
          sinopsis: bookData['sinopsis'] as String,
          etiquetas: bookData['etiquetas'] as List<String>,
          portadaUrlRevision: bookData['portadaUrlRevision'] as String?,
          archivoUrlRevision: bookData['archivoUrlRevision'] as String?,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud enviada exitosamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BibliotecaA()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al procesar solicitud: ${e.toString()}'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ));
      print("Error en _submitForm de AgregarA: $e");
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
                child: allTags.isEmpty
                    ? const Center(
                        child: Text(
                          "No hay etiquetas disponibles. Asegúrate de que estén cargadas.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: allTags.length,
                        itemBuilder: (context, index) {
                          final tag = allTags[index];
                          return CheckboxListTile(
                            title: Text(
                              tag['nombre'] != null && tag['nombre'].isNotEmpty
                                  ? tag['nombre']
                                  : 'Nombre no disponible', // Modificado aquí
                            ),
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
        title: Text(
          widget.bookToEdit != null ? "Editar Libro" : "Solicitar Publicación",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Portada del libro',
                      style: TextStyle(fontWeight: FontWeight.bold)),
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
                            width: 1.5),
                        image: imagePath != null
                            ? DecorationImage(
                                image: FileImage(File(imagePath!)),
                                fit: BoxFit.cover,
                              )
                            : _currentCoverImageUrl != null &&
                                    _currentCoverImageUrl!.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(_currentCoverImageUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                      ),
                      child: (imagePath == null &&
                              (_currentCoverImageUrl == null ||
                                  _currentCoverImageUrl!.isEmpty))
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_a_photo,
                                    color: Color(0xff2E4D4D), size: 40),
                                const SizedBox(height: 8),
                                Text('Agregar portada',
                                    style: TextStyle(color: Colors.grey[600])),
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
                  const Text('Etiquetas',
                      style: TextStyle(fontSize: 16, color: Colors.black54)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _showTagSelector,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedTags.isEmpty
                              ? Colors.red
                              : Colors.grey[300]!,
                          width: 1.0,
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
                                color: selectedTags.isEmpty
                                    ? Colors.grey
                                    : Colors.black),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                  if (selectedTags.isEmpty && !isFormValid)
                    const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text(
                        "Debes seleccionar al menos una etiqueta",
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  if (selectedTags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: selectedTags.map((tagId) {
                          var tag = allTags.firstWhere(
                            (tag) => tag['id'] == tagId,
                            orElse: () =>
                                {'nombre': 'Etiqueta no encontrada', 'id': tagId},
                          );
                          return Chip(
                            label: Text(
                              tag['nombre'] != null && tag['nombre'].isNotEmpty
                                  ? tag['nombre']
                                  : 'Sin Nombre', // Modificado aquí
                            ),
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
                  const Text('Archivo del libro',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _pickFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                            color: fileError != null ? Colors.red : Colors.grey[300]!,
                            width: 1.5),
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
                              ? (_currentFileUrl != null && _currentFileUrl!.isNotEmpty
                                  ? path.basename(_currentFileUrl!.split('?')[0])
                                  : "Subir archivo (PDF/ePUB)")
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
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isUploading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white),
                          )
                        : Text(
                            widget.bookToEdit != null ? "ACTUALIZAR LIBRO" : "SOLICITAR PUBLICACIÓN",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              )
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
                style: TextStyle(
                    color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              title: const Text('Plan de Suscripción'),
              leading: const Icon(Icons.subscriptions),
              onTap: () {
                Navigator.pop(context);
                print("Plan de Suscripción");
                // TODO: Navegar a la página del plan de suscripción
              },
            ),
            ListTile(
              title: const Text('Foros'),
              leading: const Icon(Icons.forum),
              onTap: () {
                Navigator.pop(context);
                print("Foros");
                // TODO: Navegar a la página de foros
              },
            ),
            ListTile(
              title: const Text('Mis Estadísticas'),
              leading: const Icon(Icons.insights),
              onTap: () {
                Navigator.pop(context);
                print("Navegar a Mis Estadísticas de Autor");
                // TODO: Navegar a una página de estadísticas del autor
              },
            ),
            ListTile(
              title: const Text('Configuración'),
              leading: const Icon(Icons.settings),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ConfiguracionAut()));
              },
            ),
            const Divider(),
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