import 'package:flutter/material.dart';
import 'package:spotibook2/Pages/Index/Autores/BuscarA.dart';
import 'package:spotibook2/Pages/Index/Autores/PerfilA.dart';
import 'package:spotibook2/Pages/Index/Autores/BibliotecaA.dart';
import 'package:spotibook2/Pages/Index/Autores/CatalogoA.dart';
import 'package:spotibook2/Pages/Index/Autores/AgregarA.dart'; // Necesario para la edición
import 'package:firebase_auth/firebase_auth.dart'; // ¡Necesario para obtener el UID del usuario!

class ModuloLecA extends StatefulWidget {
  final Map<String, dynamic> bookData;

  const ModuloLecA({super.key, required this.bookData});

  @override
  State<ModuloLecA> createState() => _ModuloLecAState();
}

class _ModuloLecAState extends State<ModuloLecA> {
  int _selectedIndex = 0;
  User? _currentUser; // Para almacenar el usuario actual
  String? uidAutor; // Para almacenar el ID del autor del libro que se está viendo
  bool _isAuthorOfThisBook = false; // Flag para controlar la visibilidad de los botones de autor

  @override
  void initState() {
    super.initState();
    // Obtener el ID del autor del libro de los datos pasados
    uidAutor = widget.bookData['autorId'] as String?; // Asume que tienes un campo 'autorId' en tus metadatos
    _loadCurrentUserAndCheckAuthorship();
    print("Datos del libro recibidos en ModuloLecA: ${widget.bookData}");
  }

  // Carga el usuario actual y verifica si es el autor del libro
  void _loadCurrentUserAndCheckAuthorship() {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null && uidAutor != null) {
      setState(() {
        _isAuthorOfThisBook = (_currentUser!.uid == uidAutor);
      });
    }
  }

  // Método para cambiar de página con BottomNavigationBar (Lógica de navegación de AUTOR)
  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // Catálogo (para autores)
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CatalogoA()));
        break;
      case 1: // Buscar (para autores)
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BuscarA()));
        break;
      case 2: // Agregar (¡Opción específica de autor en el BottomNavigationBar!)
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AgregarA()));
        break;
      case 3: // Biblioteca (para autores)
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BibliotecaA()));
        break;
      case 4: // Perfil (para autores)
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PerfilA()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extraer los datos del libro directamente de widget.bookData
    final String title = widget.bookData['titulo'] ?? 'Título Desconocido';
    final String author = widget.bookData['autor'] ?? 'Autor Desconocido';
    final String editorial = widget.bookData['editorial'] ?? 'Editorial Desconocida';
    final List<dynamic> tags = widget.bookData['etiquetas'] ?? [];
    final String genre = tags.isNotEmpty ? tags.join(', ') : 'Género Desconocido';
    final double rating = (widget.bookData['calificacionPromedio'] as num?)?.toDouble() ?? 0.0;
    String displayRating = '';
    for(int i=0; i<5; i++){
      if(i < rating.round()){
        displayRating += '★';
      } else {
        displayRating += '☆';
      }
    }
    final String synopsis = widget.bookData['sinopsis'] ?? 'Sinopsis no disponible.';
    final String? bookCoverImageUrl = widget.bookData['portadaUrlPublica'] as String?;
    final String? bookFileUrl = widget.bookData['contenidoUrl'] as String?; // Usado por "Leer Libro"

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detalles del Libro", // Título para la vista de cualquier libro
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xff2E4D4D),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Sección de la portada y detalles principales
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                bookCoverImageUrl != null && bookCoverImageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          bookCoverImageUrl,
                          width: 120,
                          height: 180,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              width: 120,
                              height: 180,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print('Error loading image from URL: $bookCoverImageUrl - $error');
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
                    : Container(
                        width: 120,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Icon(Icons.book, size: 60, color: Colors.grey),
                        ),
                      ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text('Autor: $author', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                      Text('Editorial: $editorial', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                      Text('Género: $genre', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                      Text('Calificación: $displayRating', style: const TextStyle(fontSize: 16, color: Colors.grey)),
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
              synopsis,
              style: const TextStyle(fontSize: 15, height: 1.5),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 25),

            // Botones de acción principales (Leer Libro, Favoritos, Descargar, Ir al Foro)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Column( // Botón de Favorito
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_border, size: 30),
                      color: const Color(0xff2E4D4D),
                      onPressed: () {
                        print("Agregar a Favoritos");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Funcionalidad de Favoritos próximamente.')),
                        );
                      },
                    ),
                    const Text('Favorito', style: TextStyle(fontSize: 12)),
                  ],
                ),
                ElevatedButton.icon( // Botón Leer Libro (Idéntico a ModuloLec.dart)
                  onPressed: () {
                    if (bookFileUrl != null && bookFileUrl.isNotEmpty) {
                      print('Abriendo libro desde URL: $bookFileUrl');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Abriendo libro: $title')),
                      );
                    } else {
                      print('Error: No se encontró URL de contenido para este libro.');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Contenido del libro no disponible.')),
                      );
                    }
                  },
                  icon: const Icon(Icons.menu_book), // Icono de libro
                  label: const Text('Leer Libro'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2E4D4D), // Color principal de tu app
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Column( // Botón de Descargar
                  children: [
                    IconButton(
                      icon: const Icon(Icons.download, size: 30),
                      color: const Color(0xff2E4D4D),
                      onPressed: () {
                        print("Descargar Libro");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Funcionalidad de Descarga próximamente.')),
                        );
                      },
                    ),
                    const Text('Descargar', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Botón para Ir al Foro del Libro
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implementar la navegación al foro general del libro.
                print('Navegando al foro del libro: $title');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Funcionalidad de foro para "$title" próximamente.')),
                );
              },
              icon: const Icon(Icons.forum),
              label: const Text('Ir al Foro del Libro'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Sección "Mi progreso" (funcionalidad de lector)
            const Text(
              'Mi progreso:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.access_time, color: Color(0xff2E4D4D)),
              title: const Text("Marcar como Pendiente", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onTap: () {
                print("Marcar como Pendiente");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidad de progreso próximamente.')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.hourglass_empty, color: Color(0xff2E4D4D)),
              title: const Text("Marcar como En Progreso", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onTap: () {
                print("Marcar como En Progreso");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidad de progreso próximamente.')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Color(0xff2E4D4D)),
              title: const Text("Marcar como Leído", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onTap: () {
                print("Marcar como Leído");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidad de progreso próximamente.')),
                );
              },
            ),
            const SizedBox(height: 30), // Espacio adicional antes de los botones condicionales

            // --- SECCIÓN DE ACCIONES DE AUTOR (CONDICIONAL) ---
            // Solo se muestra si el usuario logueado es el autor del libro
            if (_isAuthorOfThisBook) ...[
              const Text(
                'Acciones de Autor:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AgregarA(bookToEdit: widget.bookData),
                          ),
                        ).then((_) {
                          print('Regresando de edición. Los datos del libro podrían haberse actualizado.');
                        });
                        print('Editar libro: $title');
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
                        print('Subir/Actualizar Archivo: $title');
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
                    print('Ver estadísticas de: $title');
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
            ],
          ],
        ),
      ),
      // El BottomNavigationBar PERMANECE intacto con las opciones de autor.
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
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Agregar'), // Opción específica de autor
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Biblioteca'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}