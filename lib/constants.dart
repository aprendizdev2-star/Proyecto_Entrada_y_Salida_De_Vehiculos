//Esto es constant.dart
import 'package:flutter/material.dart';
import 'login_page.dart'; // Importa tu login para poder volver

var defaultBackgroundColor = const Color.fromARGB(255, 255, 255, 255); 
var appBarColor = const Color.fromARGB(255, 231, 10, 10); 

var myAppBar = AppBar(
  backgroundColor: appBarColor,
  automaticallyImplyLeading: false, // ¡ESTO ELIMINA LA FLECHA BLANCA!
  title: const Text(
    "Entrada y Salida de vehículos",
    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  ),
  centerTitle: true,
  // Mantenemos el icono del menú solo si es necesario (en móvil/tablet)
  leading: Builder(
    builder: (context) => IconButton(
      icon: const Icon(Icons.menu, color: Colors.white),
      onPressed: () => Scaffold.of(context).openDrawer(),
    ),
  ),
);

var drawerTextColor = const TextStyle(
  color: Colors.black87,
  fontWeight: FontWeight.w600,
);

var tilePadding = const EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0);

var myDrawer = Drawer(
  backgroundColor: Colors.white,
  elevation: 0,
  child: Column(
    children: [
      const DrawerHeader(
        decoration: BoxDecoration(color: Color.fromARGB(255, 245, 245, 245)),
        child: Center(
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
        ),
      ),
      
      createDrawerItem(Icons.home, 'M E N U', null),
      createDrawerItem(Icons.settings, 'CO N F I G U R A C I O N', null),
      createDrawerItem(Icons.info, 'N O T I C I A S', null),
      const Spacer(),
      
      // BOTÓN SALIR CONFIGURADO
      Builder(
        builder: (context) => createDrawerItem(
          Icons.logout, 
          'S A L I R', 
          () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
              (route) => false,
            );
          }
        ),
      ),
      const SizedBox(height: 20),
    ],
  ),
);

Widget createDrawerItem(IconData icon, String text, VoidCallback? onTapAction) {
  return Padding(
    padding: tilePadding,
    child: ListTile(
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(text, style: drawerTextColor),
      onTap: onTapAction,
    ),
  );
}