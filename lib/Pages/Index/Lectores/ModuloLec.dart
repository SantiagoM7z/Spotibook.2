import 'package:flutter/material.dart';
import 'package:spotibook2/Pages/Index/Lectores/Buscar.dart';
import 'package:spotibook2/Pages/Index/Lectores/Perfil.dart';
import 'package:spotibook2/Pages/Index/Lectores/Biblioteca.dart';
import 'package:spotibook2/Pages/Index/Lectores/Catalogo.dart'; // Asegúrate de que esta importación esté correcta

class ModuloLec extends StatefulWidget {
  const ModuloLec({super.key});

  @override
  State<ModuloLec> createState() => _ModuloLecState();
}

class _ModuloLecState extends State<ModuloLec> {
  final int _selectedIndex = 0;

  // Placeholder para la URL de la imagen del libro desde Dropbox.
  // Será nulo inicialmente o hasta que se cargue un libro autorizado.
  String? _bookCoverImageUrl;

  // Placeholder para los detalles del libro.
  // En una aplicación real, esto vendría de tu base de datos (Firestore, etc.).
  String _bookTitle = 'Título del Libro';
  String _bookAuthor = 'Nombre del autor';
  String _bookEditorial = 'Nombre de la editorial';
  String _bookGenre = 'Género del libro';
  String _bookRating = '★★★★☆';
  String _bookSynopsis = 'Sinopsis: Este es un resumen del contenido del libro.';


  @override
  void initState() {
    super.initState();
    // En el futuro, aquí es donde llamarías a una función
    // para cargar los detalles del libro autorizado más reciente desde tu base de datos,
    // incluyendo su URL de imagen de Dropbox.
    // Por ahora, es solo un placeholder para tu futura implementación.
    _loadAuthorizedBookDetails();
  }

  void _loadAuthorizedBookDetails() async {
    // ESTA ES LA LÓGICA QUE TÚ DEBERÁS IMPLEMENTAR EN EL FUTURO:
    // 1. Consultar tu base de datos (ej. Firestore) para obtener los libros autorizados.
    // 2. Seleccionar el libro que quieres mostrar aquí (ej. el más reciente, un destacado, etc.).
    // 3. Obtener la URL de la portada (que debería estar en Dropbox) de ese libro.
    // 4. Actualizar el estado con setState para que la UI se refresque.

    /* EJEMPLO DE CÓMO SE VERÍA LA LÓGICA (Necesitas tu propia implementación):
    try {
      // Suponiendo que tienes un servicio o una función para obtener el libro
      Map<String, dynamic>? authorizedBook = await YourFirestoreService.getLatestAuthorizedBook();
      if (authorizedBook != null) {
        setState(() {
          _bookTitle = authorizedBook['titulo'] ?? 'Título Desconocido';
          _bookAuthor = authorizedBook['autor'] ?? 'Autor Desconocido';
          _bookEditorial = authorizedBook['editorial'] ?? 'Editorial Desconocida';
          _bookGenre = authorizedBook['genero'] ?? 'Género Desconocido';
          _bookRating = authorizedBook['calificacion'] ?? '☆☆☆☆☆';
          _bookSynopsis = authorizedBook['sinopsis'] ?? 'Sinopsis no disponible.';
          _bookCoverImageUrl = authorizedBook['portadaUrlDropbox']; // Asegúrate de que tu DB guarde esta URL
        });
      }
    } catch (e) {
      print('Error al cargar detalles del libro autorizado: $e');
      // Podrías mostrar un Snackbar o un mensaje de error al usuario.
    }
    */

    // Por ahora, para que la app no falle y se muestre un placeholder:
    // _bookCoverImageUrl = null; // O establece una URL de imagen de prueba si tienes una.
  }


  // Método para cambiar de página con BottomNavigationBar
  void _onItemTapped(int index) {
    // Nota: Usar push repetidamente puede crear una pila de pantallas.
    // Considera usar pushReplacement o una NavigationBar con Body para evitar duplicados.
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Catalogo()), // Navegar a Catalogo
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Buscar()), // Navegar a Buscar
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Biblioteca()), // Navegar a Biblioteca
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Perfil()), // Navegar a Perfil
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Módulo de Lectura",
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
                      Text('Calificación: $_bookRating'),
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
            // Botones de acción (Leer, Favoritos, Descargar)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.favorite_border),
                  onPressed: () {
                    // Acción para agregar a favoritos
                  },
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Acción para leer el libro
                  },
                  child: Text('Leer'),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.download),
                  onPressed: () {
                    // Acción para descargar el libro
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            // ListView con las categorías de estado del libro
            Expanded(
              child: ListView(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.access_time, color: Color(0xff2E4D4D)),
                    title: Text("Pendiente", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    onTap: () {
                      // Acción para marcar como pendiente
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.hourglass_empty, color: Color(0xff2E4D4D)),
                    title: Text("En Progreso", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    onTap: () {
                      // Acción para marcar como en progreso
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.check_circle, color: Color(0xff2E4D4D)),
                    title: Text("Leído", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    onTap: () {
                      // Acción para marcar como leído
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
        selectedItemColor: Color(0xff2E4D4D),
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