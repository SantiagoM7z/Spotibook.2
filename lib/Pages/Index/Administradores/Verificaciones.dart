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
    if (index == 1) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Usuarios()));
    } else if (index == 2) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Editoriales()));
    } else if (index == 3) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Foros()));
    } else if (index == 4) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CentroA()));
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _abrirDetalleLibro(String documentId, Map<String, dynamic> libroData) {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => AoD(documentId: documentId, libro: libroData,),),);
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
        leading: null,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('libros')
          .where('estado', isEqualTo: 'pendiente')
          .orderBy('fechaSubida', descending: true)
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
              final fechaSubida = (data['fechaSubida'] as Timestamp).toDate();
              
              return Material(
                color: Colors.white,
                child: InkWell(
                  onTap: () => _abrirDetalleLibro(doc.id, data),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['titulo'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Solicitado: ${_dateFormat.format(fechaSubida)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (data.containsKey('autor'))
                                Text(
                                  'Autor: ${data['autor']}',
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
        onTap: _onItemTapped,
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
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xff2E4D4D)),
              child: Text(
                'Menú',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              title: Text('Cerrar sesión'),
              onTap: () async {
                await AuthService().signOut(); 
                Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => SingIn()),
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