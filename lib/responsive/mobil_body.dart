import 'package:flutter/material.dart';
import '../constants.dart';
import '../util/my_tile.dart';
import '../ingreso_page.dart';
import '../contratiempos_page.dart'; // Importación de la nueva página

class MobileScaffold extends StatefulWidget {
  const MobileScaffold({Key? key}) : super(key: key);
  @override
  State<MobileScaffold> createState() => _MobileScaffoldState();
}

class _MobileScaffoldState extends State<MobileScaffold> {
  // Función para los botones ovalados del móvil
  Widget botonColorido(String texto, Color colorBorde, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colorBorde, width: 2),
          shape: const StadiumBorder(),
          backgroundColor: Colors.white,
        ),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: defaultBackgroundColor,
      appBar: myAppBar,
      drawer: myDrawer,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text("Menú de Operaciones", style: TextStyle(fontWeight: FontWeight.bold)),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2, 
              childAspectRatio: 3.0,
              padding: const EdgeInsets.all(10),
              children: [
                // Navegación configurada para móvil enviando el modo inicial
                botonColorido("Ingreso", Colors.red, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const IngresoPage(modoInicial: "ingreso")))),
                botonColorido("Salida", Colors.green, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const IngresoPage(modoInicial: "salida")))),
                botonColorido("Verificación", Colors.orange, () {}),
                botonColorido("Buscar", Colors.cyan, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const IngresoPage(modoInicial: "buscar")))),
                
                // Botón Comentarios sin acción
                botonColorido("Comentarios", Colors.yellow[700]!, () {}),
                
                botonColorido("Parqueadero", Colors.purple, () {}),
                botonColorido("Facturación", Colors.brown, () {}),
                botonColorido("Cédula", Colors.blue, () {}),
                botonColorido("Horarios", Colors.pink, () {}),
                
                // BOTÓN CONTRATIEMPOS CONFIGURADO
                botonColorido("Contratiempos", Colors.lightGreen, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ContratiemposPage()))),
              ],
            ),
            const Divider(),
            ListView.builder(
              shrinkWrap: true, 
              physics: const NeverScrollableScrollPhysics(), 
              itemCount: 5, 
              itemBuilder: (context, index) => const MyTile()
            ),
          ],
        ),
      ),
    );
  }
}