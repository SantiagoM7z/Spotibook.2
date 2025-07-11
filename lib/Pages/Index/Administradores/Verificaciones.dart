import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spotibook2/Pages/Index/Administradores/Usuarios.dart';
import 'package:spotibook2/Pages/Index/Administradores/Editoriales.dart';
import 'package:spotibook2/Pages/Index/Administradores/Foros.dart';
import 'package:spotibook2/Pages/Index/Administradores/CentroA.dart';
import 'package:spotibook2/Pages/Index/Administradores/AoD.dart';
import 'package:intl/intl.dart';
import 'package:spotibook2/Services/Auth_Service.dart';
import 'package:spotibook2/Pages/Inicio/SingIn.dart';

class Verificaciones extends StatefulWidget {
  const Verificaciones({super.key});

  @override
  State<Verificaciones> createState() => _VerificacionesState();
}

class _VerificacionesState extends State<Verificaciones> {
  int _selectedIndex = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  void _onItemTapped(int index) {
    // Solo navega si el índice es diferente al actual.
    // El índice 0 es "Verificaciones", así que si ya estamos aquí, no hacemos pushReplacement.
    if (index == 0) {
      // Opcional: podrías agregar una lógica para refrescar la lista si el usuario toca el mismo ítem.
      // Por ahora, no hace nada si ya está en "Verificaciones".
    } else if (index == 1) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Usuarios()));
    } else if (index == 2) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Editoriales()));
    } else if (index == 3) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Foros()));
    } else if (index == 4) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CentroA()));
    }
    // No necesitamos setState aquí porque pushReplacement reconstruye el widget destino.
  }

  void _abrirDetalleLibro(String documentId, Map<String, dynamic> libroData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AoD(documentId: documentId, libro: libroData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Verificaciones Pendientes",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xff2E4D4D),
        iconTheme: const IconThemeData(color: Colors.white),
        // Puedes mantener leading: null si no quieres el botón de atrás predeterminado.
        // Si el admin siempre entra a esta pantalla desde un flujo donde no hay "atrás", está bien.
        leading: null, // Mantener como estaba si es la pantalla principal del admin
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('solicitudes_publicacion')
            .where('estado', isEqualTo: 'pendiente')
            .orderBy('fechaSolicitud', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data?.docs.isEmpty ?? true) {
            return const Center(
              child: Text(
                'No hay verificaciones pendientes',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final fechaSolicitud = (data['fechaSolicitud'] as Timestamp).toDate();

              return Material(
                color: Colors.white,
                child: InkWell(
                  onTap: () => _abrirDetalleLibro(doc.id, data),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Row(
                      children: [
                        // * Previsualización de la portada
                        if (data['portadaUrlRevision'] != null && (data['portadaUrlRevision'] as String).isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4.0),
                              child: Image.network(
                                data['portadaUrlRevision'],
                                width: 60,
                                height: 90,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 60,
                                    height: 90,
                                    color: Colors.grey[200],
                                    child: Icon(Icons.book, color: Colors.grey[400]),
                                  );
                                },
                              ),
                            ),
                          )
                        else
                          // Placeholder si no hay imagen de portada o URL
                          Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: Container(
                              width: 60,
                              height: 90,
                              color: Colors.grey[200],
                              child: Icon(Icons.book, color: Colors.grey[400]),
                            ),
                          ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['titulo'] ?? 'Título Desconocido', // Manejo de nulos
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              // * Mostrar Autor y Editorial con manejo de nulos
                              Text(
                                'Autor: ${data['autor'] ?? 'Desconocido'}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (data['editorial'] != null) // Mostrar editorial solo si existe
                                Text(
                                  'Editorial: ${data['editorial'] ?? 'Desconocida'}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              Text(
                                'Solicitado: ${_dateFormat.format(fechaSolicitud)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) { // Ajuste en el onTap para _onItemTapped
          if (index != _selectedIndex) { // Solo navega si el ítem es diferente
            _onItemTapped(index);
          }
        },
        selectedItemColor: const Color(0xff2E4D4D),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user),
            label: 'Verificaciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Usuarios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Editoriales',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: 'Foros',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_center),
            label: 'Centro de ayuda',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader( // Hice el DrawerHeader constante ya que no tiene variables.
              decoration: BoxDecoration(color: Color(0xff2E4D4D)),
              child: Text(
                'Menú',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              title: const Text('Cerrar sesión'), // También hice este Text constante.
              onTap: () async {
                await AuthService().signOut();
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SingIn()),
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