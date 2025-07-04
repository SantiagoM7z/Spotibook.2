import 'package:flutter/material.dart';
import 'package:spotibook2/Pages/Index/Autores/BuscarA.dart';
import 'package:spotibook2/Pages/Index/Autores/PerfilA.dart';
import 'package:spotibook2/Pages/Index/Autores/BibliotecaA.dart';
import 'package:spotibook2/Pages/Index/Autores/CatalogoA.dart'; // Asegúrate de que esta importación esté correcta

class ModuloLecA extends StatefulWidget {
  const ModuloLecA({super.key});

  @override
  State<ModuloLecA> createState() => _ModuloLecAState();
}

class _ModuloLecAState extends State<ModuloLecA> {
  // Nota: La variable _selectedIndex es `final` en tu código original,
  // lo que significa que su valor no puede cambiar después de la inicialización.
  // Si deseas que la selección del BottomNavigationBar cambie visualmente,
  // deberías hacerla no-final y actualizarla en _onItemTapped usando setState.
  // Por ahora la mantengo como final según tu original.
  final int _selectedIndex = 0;

  // Placeholder para la URL de la imagen del libro desde Dropbox.
  // Será nulo inicialmente o hasta que se cargue un libro (propio del autor).
  String? _bookCoverImageUrl;

  // Placeholder para los detalles del libro.
  // Para el módulo de autores, estos datos deberían ser los de *sus* libros,
  // probablemente cargados desde su perfil o una selección.
  String _bookTitle = 'Título de Tu Libro'; // Ajustado para autor
  String _bookAuthor = 'Tu Nombre de Autor'; // Ajustado para autor
  String _bookEditorial = 'Tu Editorial';     // Ajustado para autor
  String _bookGenre = 'Tu Género';            // Ajustado para autor
  String _bookRating = '---';                 // Los autores no califican sus propios libros, quizás sea la media
  String _bookSynopsis = 'Sinopsis: Un resumen de tu propia obra.'; // Ajustado para autor

  @override
  void initState() {
    super.initState();
    // Para el módulo de Autores:
    // Aquí es donde en el futuro cargarías los detalles de uno de los libros del autor.
    // Podría ser el último subido, un libro destacado, o el que el autor está editando.
    _loadAuthorBookDetails();
  }

  void _loadAuthorBookDetails() async {
    // ESTA ES LA LÓGICA QUE TÚ DEBERÁS IMPLEMENTAR EN EL FUTURO PARA AUTORES:
    // 1. Consultar tu base de datos (Firestore, etc.) para obtener los libros del autor actual.
    // 2. Seleccionar el libro que quieres mostrar aquí (ej. el último que subió, un borrador, etc.).
    // 3. Obtener la URL de la portada (que debería estar en Dropbox) de ese libro.
    // 4. Actualizar el estado con setState para que la UI se refresque.

    /* EJEMPLO DE CÓMO SE VERÍA LA LÓGICA (Necesitas tu propia implementación para autores):
    try {
      // Suponiendo que tienes un servicio para obtener los libros del autor logueado
      Map<String, dynamic>? authorBook = await YourFirestoreService.getAuthorsLatestBook(currentUserId);
      if (authorBook != null) {
        setState(() {
          _bookTitle = authorBook['titulo'] ?? 'Título Desconocido';
          _bookAuthor = authorBook['autor'] ?? 'Autor Desconocido';
          _bookEditorial = authorBook['editorial'] ?? 'Editorial Desconocida';
          _bookGenre = authorBook['genero'] ?? 'Género Desconocido';
          // _bookRating = authorBook['calificacion'] ?? '---'; // Los autores no suelen calificarse a sí mismos.
          _bookSynopsis = authorBook['sinopsis'] ?? 'Sinopsis no disponible.';
          _bookCoverImageUrl = authorBook['portadaUrlDropbox']; // Asumiendo este campo en tu DB
        });
      }
    } catch (e) {
      print('Error al cargar detalles del libro del autor: $e');
      // Podrías mostrar un Snackbar o un mensaje de error al usuario.
    }
    */

    // Por ahora, para que la app no falle y se muestre un placeholder:
    // _bookCoverImageUrl = null; // O puedes establecer una URL de imagen de prueba si tienes una.
  }

  // Método para cambiar de página con BottomNavigationBar
  void _onItemTapped(int index) {
    // Nota: Usar push repetidamente puede crear una pila de pantallas.
    // Considera usar pushReplacement para navegación BottomNavigationBar o un IndexedStack con Body.
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CatalogoA()), // Navegar a CatalogoA
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BuscarA()), // Navegar a BuscarA
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BibliotecaA()), // Navegar a BibliotecaA
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PerfilA()), // Navegar a PerfilA
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Módulo de Autor", // Cambiado para reflejar el rol de autor
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xff2E4D4D),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Imagen del libro y detalles
            Row(
              children: <Widget>[
                // Condicional para mostrar la imagen de red o un placeholder
                _bookCoverImageUrl != null && _bookCoverImageUrl!.isNotEmpty
                    ? Image.network( // Carga la imagen desde la URL de Dropbox
                        _bookCoverImageUrl!,
                        width: 100,
                        height: 150,
                        fit: BoxFit.cover, // Ajusta la imagen para cubrir el espacio
                        errorBuilder: (context, error, stackTrace) {
                          // En caso de error de carga de la URL, muestra un icono
                          print('Error loading image from URL: $_bookCoverImageUrl - $error');
                          return Container(
                            width: 100,
                            height: 150,
                            color: Colors.grey[300],
                            child: Icon(Icons.broken_image, size: 50, color: Colors.grey[600]),
                          );
                        },
                      )
                    : Container( // Placeholder cuando no hay URL de imagen
                        width: 100,
                        height: 150,
                        color: Colors.grey[300],
                        child: Icon(Icons.book, size: 50, color: Colors.grey[600]),
                      ),
                SizedBox(width: 16),
                // Detalles del libro
                Expanded( // Usa Expanded para que el Column de texto ocupe el espacio restante
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _bookTitle, // Título dinámico
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text('Autor: $_bookAuthor'),
                      Text('Editorial: $_bookEditorial'),
                      Text('Género: $_bookGenre'),
                      Text('Calificación: $_bookRating'), // Podría ser la calificación promedio
                      SizedBox(height: 10),
                      // Sinopsis
                      Text(
                        _bookSynopsis, // Sinopsis dinámica
                        style: TextStyle(fontSize: 14),
                        maxLines: 3, // Limita a 3 líneas para evitar desbordamiento
                        overflow: TextOverflow.ellipsis, // Añade "..." si el texto es muy largo
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Botones de acción (Editar Libro, Ver Estadísticas, etc. - ajustados para autor)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.edit), // Icono para editar el libro
                  onPressed: () {
                    // Acción para editar el libro
                  },
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Acción para subir o actualizar el libro (ej. a Dropbox)
                    // Aquí es donde llamarías a DropboxService.uploadFile
                    // Asegúrate de pasar el archivo y la ruta correcta.
                    // Ejemplo (necesitas obtener el File del libro real):
                    /*
                    // Suponiendo que tienes un File _selectedFile
                    // y la ruta deseada en Dropbox _dropboxUploadPath
                    try {
                      final dropboxService = DropboxService();
                      String? publicUrl = await dropboxService.uploadFile(_selectedFile, _dropboxUploadPath);
                      if (publicUrl != null) {
                        print('Libro subido y URL pública: $publicUrl');
                        // Aquí actualizas tu base de datos con publicUrl
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Libro subido exitosamente!')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al subir el libro a Dropbox.')),
                        );
                      }
                    } catch (e) {
                      print('Error general al subir desde ModuloLec (Autores): $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error inesperado al subir el libro.')),
                      );
                    }
                    */
                  },
                  child: Text('Subir/Actualizar Libro'),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.bar_chart), // Icono para ver estadísticas
                  onPressed: () {
                    // Acción para ver estadísticas del libro
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            // ListView con secciones relevantes para autores
            Expanded(
              child: ListView(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.book, color: Color(0xff2E4D4D)),
                    title: Text("Mis Borradores", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    onTap: () {
                      // Acción para ver borradores
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.check_circle_outline, color: Color(0xff2E4D4D)),
                    title: Text("En Revisión", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    onTap: () {
                      // Acción para ver libros en revisión
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.publish, color: Color(0xff2E4D4D)),
                    title: Text("Publicados", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    onTap: () {
                      // Acción para ver libros publicados
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor:Color(0xff2E4D4D),
        unselectedItemColor: Colors.grey,
        backgroundColor: Color(0xff2E4D4D),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Catalogo'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Biblioteca'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}