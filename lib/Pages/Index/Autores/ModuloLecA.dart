import 'package:flutter/material.dart';
import 'package:spotibook2/Pages/Index/Autores/BuscarA.dart';
import 'package:spotibook2/Pages/Index/Autores/PerfilA.dart';
import 'package:spotibook2/Pages/Index/Autores/BibliotecaA.dart';
import 'package:spotibook2/Pages/Index/Autores/CatalogoA.dart';
import 'package:spotibook2/Pages/Index/Autores/AgregarA.dart'; // Importar AgregarA

// Si usas servicios de Dropbox o Firestore, asegúrate de tenerlos importados:
// import 'package:spotibook2/Services/Dropbox_Service.dart';
// import 'package:spotibook2/Services/Firestore_Service.dart';
// import 'dart:io'; // Para manejar File si implementas selección de archivos

class ModuloLecA extends StatefulWidget {
  // Ahora ModuloLecA acepta un mapa de datos del libro
  final Map<String, dynamic>? bookData;

  const ModuloLecA({super.key, this.bookData});

  @override
  State<ModuloLecA> createState() => _ModuloLecAState();
}

class _ModuloLecAState extends State<ModuloLecA> {
  int _selectedIndex = 0; // Índice mutable para el BottomNavigationBar

  // Variables para los detalles del libro. Se inicializarán desde widget.bookData.
  String _bookTitle = 'Título de Tu Libro';
  String _bookAuthor = 'Tu Nombre de Autor';
  String _bookEditorial = 'Tu Editorial';
  String _bookGenre = 'Tu Género';
  String _bookSynopsis = 'Sinopsis: Un resumen de tu propia obra.';
  String? _bookCoverImageUrl; // URL de la portada del libro

  @override
  void initState() {
    super.initState();
    _loadBookDetails(); // Cargar los detalles del libro al iniciar
  }

  void _loadBookDetails() {
    if (widget.bookData != null) {
      // Si se pasaron datos del libro, úsalos para actualizar el estado
      setState(() {
        _bookTitle = widget.bookData!['titulo'] ?? 'Título Desconocido';
        _bookAuthor = widget.bookData!['autor'] ?? 'Autor Desconocido';
        _bookEditorial = widget.bookData!['editorial'] ?? 'Editorial Desconocida';
        _bookGenre = widget.bookData!['genero'] ?? 'Género Desconocido';
        _bookSynopsis = widget.bookData!['sinopsis'] ?? 'Sinopsis no disponible.';
        _bookCoverImageUrl = widget.bookData!['portadaUrlDropbox']; // Asumiendo este campo en tu DB
      });
    } else {
      // Si no se pasaron datos, muestra placeholders y un mensaje
      print("No se recibieron datos del libro. Mostrando placeholders.");
      // Aquí podrías cargar un libro predeterminado del autor si lo deseas,
      // o dejar los placeholders actuales.
      setState(() {
        _bookTitle = 'Libro No Seleccionado';
        _bookAuthor = 'N/A';
        _bookEditorial = 'N/A';
        _bookGenre = 'N/A';
        _bookSynopsis = 'Por favor, selecciona un libro de tu catálogo o biblioteca.';
        _bookCoverImageUrl = null; // No hay imagen por defecto
      });
    }
  }

  // Método para cambiar de página con BottomNavigationBar
  void _onItemTapped(int index) {
    if (_selectedIndex == index) return; // Si ya está seleccionado, no hacer nada

    setState(() {
      _selectedIndex = index; // Actualizar el índice seleccionado
    });

    // Usar Navigator.pushReplacement para todas las navegaciones del BottomNavigationBar
    // para evitar que se acumulen páginas en la pila.
    switch (index) {
      case 0: // Catálogo
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CatalogoA()));
        break;
      case 1: // Buscar
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BuscarA()));
        break;
      case 2: // Biblioteca (que puede ser la sección de "Mis Libros" para el autor)
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BibliotecaA()));
        break;
      case 3: // Perfil
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PerfilA()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detalles de Mi Obra", // Título ajustado para autores
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xff2E4D4D),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView( // Permite desplazamiento si el contenido es largo
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Sección de la portada y detalles principales
            Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Alinea la parte superior
              children: <Widget>[
                _bookCoverImageUrl != null && _bookCoverImageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          _bookCoverImageUrl!,
                          width: 120,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print('Error loading image from URL: $_bookCoverImageUrl - $error');
                            return Container(
                              width: 120,
                              height: 180,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                            );
                          },
                        ),
                      )
                    : Container( // Placeholder cuando no hay URL de imagen
                        width: 120,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Icon(Icons.book, size: 60, color: Colors.grey),
                      ),
                const SizedBox(width: 20),
                // Detalles del libro
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _bookTitle,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text('Autor: $_bookAuthor', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                      Text('Editorial: $_bookEditorial', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                      Text('Género: $_bookGenre', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                      const Text('Calificación: N/A', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Sinopsis del libro
            const Text(
              'Sinopsis:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _bookSynopsis,
              style: const TextStyle(fontSize: 15, height: 1.5),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 25),

            // Botones de acción principales para el autor
            const Text(
              'Acciones:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navegar a la pantalla de edición, pasando los datos del libro
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AgregarA(bookToEdit: widget.bookData),
                        ),
                      ).then((_) {
                        // Opcional: Cuando regreses de AgregarA (si se editó), recarga los detalles
                        // Esto asegura que la pantalla ModuloLecA refleje los cambios.
                        _loadBookDetails();
                      });
                      print('Editar libro: $_bookTitle');
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar Información'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff2E4D4D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implementar lógica para subir o actualizar el archivo del libro (PDF/EPUB) a Dropbox
                      print('Subir/Actualizar Archivo: $_bookTitle');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Funcionalidad de subir/actualizar archivo pendiente.')),
                      );
                    },
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Subir Archivo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navegar a la pantalla de estadísticas específicas para este libro
                  print('Ver estadísticas de: $_bookTitle');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Funcionalidad de estadísticas pendiente.')),
                  );
                },
                icon: const Icon(Icons.bar_chart),
                label: const Text('Ver Estadísticas del Libro'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2E4D4D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Sección para gestionar el contenido del libro (capítulos, etc.)
            const Text(
              'Gestión de Contenido:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.list_alt, color: Color(0xff2E4D4D)),
              title: const Text("Lista de Capítulos"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                print("Navegar a lista de capítulos");
                // TODO: Navegar a una pantalla para gestionar capítulos
              },
            ),
            ListTile(
              leading: const Icon(Icons.description, color: Color(0xff2E4D4D)),
              title: const Text("Editar Sinopsis Completa"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                print("Editar sinopsis completa");
                // TODO: Navegar a una pantalla para editar la sinopsis larga
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color(0xff2E4D4D),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[400],
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Catálogo'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Biblioteca'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}