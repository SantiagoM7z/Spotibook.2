import 'package:flutter/material.dart';
import 'package:spotibook2/Pages/Index/Lectores/Buscar.dart';
import 'package:spotibook2/Pages/Index/Lectores/Perfil.dart';
import 'package:spotibook2/Pages/Index/Lectores/Biblioteca.dart';
import 'package:spotibook2/Pages/Index/Lectores/Catalogo.dart';

class ModuloLec extends StatefulWidget {
  // Ahora el ModuloLec espera un mapa con los datos completos del libro
  final Map<String, dynamic> bookData;

  const ModuloLec({super.key, required this.bookData});

  @override
  State<ModuloLec> createState() => _ModuloLecState();
}

class _ModuloLecState extends State<ModuloLec> {
  // El _selectedIndex y _onItemTapped permanecen como los tenías.
  final int _selectedIndex = 0; // Índice para 'Catálogo' en la BottomNavigationBar

  @override
  void initState() {
    super.initState();
    // Ya no necesitamos una función _loadAuthorizedBookDetails,
    // porque los datos del libro se pasan directamente al constructor.
    // Opcional: Imprime los datos para verificar que se reciben correctamente.
    print("Datos del libro recibidos en ModuloLec: ${widget.bookData}");
  }

  // Método para cambiar de página con BottomNavigationBar (PERMANECE)
  void _onItemTapped(int index) {
    if (_selectedIndex == index) return; // Si ya estamos en la página actual, no hacemos nada.

    setState(() {
      // Aunque _selectedIndex no se usa directamente para la navegación aquí,
      // se mantiene para la lógica de visualización del BottomNavigationBar.
      // La navegación real se maneja con Navigator.pushReplacement.
    });

    switch (index) {
      case 0: // Catálogo
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Catalogo()));
        break;
      case 1: // Buscar
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Buscar()));
        break;
      case 2: // Biblioteca
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Biblioteca()));
        break;
      case 3: // Perfil
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Perfil()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extraer los datos del libro directamente del widget.bookData
    // (MODIFICACIÓN: Uso de widget.bookData directamente)
    final String title = widget.bookData['titulo'] ?? 'Título Desconocido';
    final String author = widget.bookData['autor'] ?? 'Autor Desconocido';
    final String editorial = widget.bookData['editorial'] ?? 'Editorial Desconocida';
    // Asumiendo que 'etiquetas' es una lista de strings y queremos mostrar una sola.
    // Podrías unirlas con ', ' si son múltiples.
    final List<dynamic> tags = widget.bookData['etiquetas'] ?? [];
    final String genre = tags.isNotEmpty ? tags.join(', ') : 'Género Desconocido';

    // Asume que tienes un campo de calificación en Firestore, si no, usa un valor predeterminado
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
    // Usar 'portadaUrlPublica' o 'portadaUrl' dependiendo de cómo lo tengas en tu Firestore
    // Si tu Firestore usa 'portadaUrl', déjalo así. Si usas 'portadaUrlPublica' como en ejemplos previos, cámbialo.
    final String? bookCoverImageUrl = widget.bookData['portadaUrl'] as String?;
    final String? bookFileUrl = widget.bookData['archivoUrl'] as String?; // URL para el archivo PDF/ePub

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title, // Título dinámico
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xff2E4D4D),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView( // Usar SingleChildScrollView para evitar desbordamientos
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Imagen del libro y detalles
            Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Alinea al inicio de la fila
              children: <Widget>[
                // Condicional para mostrar la imagen de red o un placeholder
                bookCoverImageUrl != null && bookCoverImageUrl.isNotEmpty
                    ? ClipRRect( // Recorta la imagen con los bordes redondeados
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network( // Carga la imagen desde la URL de Dropbox (o Firebase Storage)
                          bookCoverImageUrl,
                          width: 120, // Aumentado ligeramente para mejor visualización
                          height: 180, // Aumentado ligeramente
                          fit: BoxFit.cover, // Ajusta la imagen para cubrir el espacio
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox( // Placeholder mientras carga
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
                            // En caso de error de carga de la URL, muestra un icono
                            print('Error loading image from URL: $bookCoverImageUrl - $error');
                            return Container(
                              width: 120,
                              height: 180,
                              color: Colors.grey[300],
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
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Icon(Icons.book, size: 60, color: Colors.grey),
                        ),
                      ),
                const SizedBox(width: 16),
                // Detalles del libro
                Expanded( // Usa Expanded para que el Column de texto ocupe el espacio restante
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title, // Título dinámico
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Autor: $author', style: const TextStyle(fontSize: 16)),
                      Text('Editorial: $editorial', style: const TextStyle(fontSize: 16)),
                      Text('Género: $genre', style: const TextStyle(fontSize: 16)),
                      Text('Calificación: $displayRating', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Sinopsis
            const Text(
              'Sinopsis:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              synopsis, // Sinopsis dinámica
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 30),
            // Botones de acción (Leer, Favoritos, Descargar, Ir al Foro)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_border, size: 30),
                      color: const Color(0xff2E4D4D),
                      onPressed: () {
                        // TODO: Acción para agregar a favoritos (usar FirestoreService)
                        print("Agregar a Favoritos");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Funcionalidad de Favoritos próximamente.')),
                        );
                      },
                    ),
                    const Text('Favorito', style: TextStyle(fontSize: 12)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Acción para leer el libro
                    if (bookFileUrl != null && bookFileUrl.isNotEmpty) {
                      // TODO: Implementar la lógica para abrir el archivo del libro
                      // Puedes usar 'url_launcher' para abrir la URL en un navegador,
                      // o un visor de PDF/ePub si tienes uno integrado.
                      print('Abriendo libro desde URL: $bookFileUrl');
                      // Ejemplo con url_launcher:
                      // import 'package:url_launcher/url_launcher.dart';
                      // launchUrl(Uri.parse(bookFileUrl));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Abriendo libro: $title')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No hay archivo disponible para este libro.')),
                      );
                    }
                  },
                  icon: const Icon(Icons.menu_book),
                  label: const Text('Leer Libro'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2E4D4D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.download, size: 30),
                      color: const Color(0xff2E4D4D),
                      onPressed: () {
                        // TODO: Acción para descargar el libro (manejo local)
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
            const SizedBox(height: 30),
            // Botón para Ir al Foro del Libro (Futura Implementación)
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implementar la navegación al foro general del libro.
                // Necesitarás pasar el ID o nombre del libro al foro.
                print('Navegando al foro del libro: $title');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Funcionalidad de foro para "$title" próximamente.')),
                );
              },
              icon: const Icon(Icons.forum),
              label: const Text('Ir al Foro del Libro'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // Un color diferente para distinguirlo
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 30), // Espacio adicional

            // ListView con las categorías de estado del libro (para marcar su estado)
            const Text(
              'Mi progreso:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Los ListTiles pueden usarse para actualizar el estado del libro en la biblioteca del usuario en Firestore.
            ListTile(
              leading: const Icon(Icons.access_time, color: Color(0xff2E4D4D)),
              title: const Text("Marcar como Pendiente", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onTap: () {
                // TODO: Acción para marcar como pendiente en Firestore para el usuario actual
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
                // TODO: Acción para marcar como en progreso en Firestore para el usuario actual
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
                // TODO: Acción para marcar como leído en Firestore para el usuario actual
                print("Marcar como Leído");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidad de progreso próximamente.')),
                );
              },
            ),
          ],
        ),
      ),
      // El BottomNavigationBar PERMANECE intacto, tal como lo pediste.
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