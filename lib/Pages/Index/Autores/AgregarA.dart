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
import 'package:spotibook2/Pages/Index/Settings/Configuracion.dart';
import 'package:spotibook2/Services/Auth_Service.dart';
import 'package:spotibook2/Pages/Inicio/SingIn.dart';
import 'package:spotibook2/Services/firestore_service.dart';
import 'package:spotibook2/Services/DropboxConfig.dart';

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
  final int _selectedIndex = 2; // Asegúrate de que este índice sea el correcto para la navegación.

  // Controladores
  final TextEditingController tituloController = TextEditingController();
  final TextEditingController autorController = TextEditingController();
  final TextEditingController editorialController = TextEditingController();
  final TextEditingController sinopsisController = TextEditingController();

  // Estados
  bool isFormValid = false;
  bool isUploading = false;
  String? imagePath; // Ruta del archivo de imagen recién seleccionada
  String? filePath; // Ruta del archivo de libro recién seleccionado
  String? _currentCoverImageUrl; // URL de la portada existente (si estamos editando)
  String? _currentFileUrl; // URL del archivo de libro existente (si estamos editando)

  List<String> selectedTags = []; // Almacena solo los IDs de las etiquetas seleccionadas
  List<Map<String, dynamic>> allTags = []; // Almacena mapas con 'id' y 'nombre'
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
    // Inicializar campos si bookToEdit es provisto (modo edición)
    if (widget.bookToEdit != null) {
      tituloController.text = widget.bookToEdit!['titulo'] ?? '';
      autorController.text = widget.bookToEdit!['autor'] ?? '';
      editorialController.text = widget.bookToEdit!['editorial'] ?? '';
      sinopsisController.text = widget.bookToEdit!['sinopsis'] ?? '';
      // Asegúrate de que las etiquetas se manejen como List<String>
      selectedTags = List<String>.from(widget.bookToEdit!['etiquetas'] ?? []);
      // *** CAMBIO CLAVE: Leer de los campos de URL de revisión ***
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
      _validateForm(); // Validar formulario después de cargar las etiquetas
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
    // Es crucial llamar a setState aquí para que la UI se actualice
    // y el botón de enviar se habilite/deshabilite correctamente.
    setState(() {
      isFormValid = _formKey.currentState?.validate() == true &&
          selectedTags.isNotEmpty &&
          // Comprobar si se seleccionó una nueva imagen O si ya existe una URL de portada
          (imagePath != null || (_currentCoverImageUrl != null && _currentCoverImageUrl!.isNotEmpty)) &&
          // Comprobar si se seleccionó un nuevo archivo O si ya existe una URL de archivo
          (filePath != null || (_currentFileUrl != null && _currentFileUrl!.isNotEmpty));

      // Actualizar mensajes de error visuales
      imageError = (imagePath == null && (_currentCoverImageUrl == null || _currentCoverImageUrl!.isEmpty))
          ? "Debes seleccionar una portada"
          : null;
      fileError = (filePath == null && (_currentFileUrl == null || _currentFileUrl!.isEmpty))
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
          _currentCoverImageUrl = null; // Borra la URL existente si seleccionamos una nueva imagen
          _validateForm(); // Revalidar el formulario
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
          _currentFileUrl = null; // Borra la URL existente si seleccionamos un nuevo archivo
          _validateForm(); // Revalidar el formulario
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
      // Forzar la validación para mostrar los errores si el botón está deshabilitado.
      _formKey.currentState?.validate();
      _validateForm();
      return;
    }

    setState(() => isUploading = true);

    try {
      final confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(widget.bookToEdit != null ? 'Confirmar Edición' : 'Solicitar Publicación'),
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

      // Subir nueva imagen si se seleccionó una
      if (imagePath != null) {
        final imageFile = File(imagePath!);
        final imageName =
            'portada_revision_${DateTime.now().millisecondsSinceEpoch}${path.extension(imagePath!)}';
        // Subir a la carpeta de Revisiones
        finalImageUrl = await _dropboxService.uploadFile(imageFile, '/Revisiones/$imageName');
      }

      // Subir nuevo archivo si se seleccionó uno
      if (filePath != null) {
        final bookFile = File(filePath!);
        final bookName =
            'libro_revision_${DateTime.now().millisecondsSinceEpoch}${path.extension(filePath!)}';
        // Subir a la carpeta de Revisiones
        finalFileUrl = await _dropboxService.uploadFile(bookFile, '/Revisiones/$bookName');
      }

      // Prepara los datos del libro con los tipos correctos
      final Map<String, dynamic> bookData = {
        'titulo': tituloController.text,
        'autor': autorController.text,
        'editorial': editorialController.text,
        'sinopsis': sinopsisController.text,
        'etiquetas': selectedTags, // selectedTags ya es List<String>
        // *** CAMBIO CLAVE: Usar los nombres de campo para URLs de revisión ***
        'portadaUrlRevision': finalImageUrl,
        'archivoUrlRevision': finalFileUrl,
        'lastUpdated': DateTime.now(), // Actualizar la marca de tiempo
      };

      if (widget.bookToEdit != null && widget.bookToEdit!['id'] != null) {
        // Actualizar solicitud de libro existente
        await _firestoreService.updateBookRequest(widget.bookToEdit!['id'], bookData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Libro actualizado exitosamente!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        // Guardar como una nueva solicitud de publicación
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

      // Navegar de vuelta a BibliotecaA después del envío/actualización exitosa
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
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allTags.length,
                  itemBuilder: (context, index) {
                    final tag = allTags[index];
                    return CheckboxListTile(
                      title: Text(tag['nombre'] ?? 'Nombre no disponible'),
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
                    _validateForm(); // Revalidar el formulario
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
        onChanged: _validateForm, // Validar formulario ante cualquier cambio
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: <Widget>[
              // Selector de imagen
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
                        // Mostrar la imagen recién seleccionada o la existente
                        image: imagePath != null
                            ? DecorationImage(
                                image: FileImage(File(imagePath!)),
                                fit: BoxFit.cover,
                              )
                            : _currentCoverImageUrl != null && _currentCoverImageUrl!.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(_currentCoverImageUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                      ),
                      child: (imagePath == null && (_currentCoverImageUrl == null || _currentCoverImageUrl!.isEmpty))
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
                              ? Colors.red // Borde rojo si no hay etiquetas seleccionadas
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
                  if (selectedTags.isEmpty && !isFormValid) // Mostrar error solo si está vacío y no es válido el formulario
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
                          // Busca el nombre de la etiqueta usando el ID
                          var tag = allTags.firstWhere(
                            (tag) => tag['id'] == tagId,
                            orElse: () =>
                                {'nombre': 'Etiqueta no encontrada', 'id': tagId},
                          );
                          return Chip(
                            label: Text(tag['nombre'] ?? 'Sin Nombre'),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () {
                              setState(() {
                                selectedTags.remove(tagId);
                              });
                              _validateForm(); // Revalidar el formulario
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
                          // Mostrar el nombre del archivo recién seleccionado o de la URL existente
                          filePath == null
                              ? (_currentFileUrl != null && _currentFileUrl!.isNotEmpty
                                  ? path.basename(_currentFileUrl!.split('?')[0]) // Extraer nombre de archivo de la URL
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
                      foregroundColor: Colors.white, // Color del texto del botón
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
                Navigator.pop(context); // Cierra el drawer
                print("Navegar a Mis Estadísticas de Autor");
                // TODO: Navegar a una página de estadísticas del autor
              },
            ),
            ListTile(
              title: const Text('Configuración'),
              leading: const Icon(Icons.settings),
              onTap: () {
                Navigator.pop(context); // Cierra el drawer
                Navigator.push(context, MaterialPageRoute(builder: (context) => const Configuracion()));
              },
            ),
            const Divider(), // Divisor visual
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

// DropboxService se mantiene igual, ya que sus métodos están bien definidos
// para la subida y generación de enlaces de Dropbox.
// Sin embargo, por consistencia, deberías tener esta clase en un archivo separado
// como Services/Dropbox_Service.dart si no la tienes ya.
class DropboxService {
  // Esta clase debería estar idealmente en su propio archivo, como Services/Dropbox_Service.dart
  // y ser importada en AgregarA.dart
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
        // El enlace ya existe, intentar obtenerlo
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