import 'package:flutter/material.dart';
import '../constants.dart';
import '../util/my_tile.dart';
import '../horarios_page.dart';
import '../ingreso_page.dart';
import '../contratiempos_page.dart'; // Importación de la nueva página

class DesktopScaffold extends StatefulWidget {
  const DesktopScaffold({Key? key}) : super(key: key);
  @override
  State<DesktopScaffold> createState() => _DesktopScaffoldState();
}

class _DesktopScaffoldState extends State<DesktopScaffold> {
  // Widget para los botones del menú de escritorio
  Widget botonColorido(String texto, Color colorBorde, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
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
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: defaultBackgroundColor,
      appBar: myAppBar,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          myDrawer,
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Text("Menú de Operaciones", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Flexible(
                    child: GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 4, 
                      childAspectRatio: 2.8,
                      physics: const ClampingScrollPhysics(),
                      children: [
                        // Navegación con modos específicos para IngresoPage
                        botonColorido("Ingreso", Colors.green, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const IngresoPage(modoInicial: "ingreso")))),
                        botonColorido("Salida", Colors.red, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const IngresoPage(modoInicial: "salida")))),
                        botonColorido("Verificación", Colors.orange, () {}),
                        botonColorido("Buscar", Colors.cyan, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const IngresoPage(modoInicial: "buscar")))),
                        
                        // Botón Comentarios (sin acción por ahora)
                        botonColorido("Comentarios", Colors.yellow[700]!, () {}),
                        
                        botonColorido("Parqueadero", Colors.purple, () {}),
                        botonColorido("Facturación", Colors.brown, () {}),
                        botonColorido("Cédula", Colors.blue, () {}),
                        botonColorido("Horarios", Colors.pink, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HorariosPage()))),
                        
                        // BOTÓN CONTRATIEMPOS CONFIGURADO
                        botonColorido("Contratiempos", Colors.lightGreen, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ContratiemposPage()))),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(child: ListView.builder(itemCount: 5, itemBuilder: (context, index) => const MyTile())),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text("Accesos Rápidos", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildQuickAccessButton("INGRESO", Colors.green, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const IngresoPage(modoInicial: "ingreso")))),
                  const SizedBox(height: 20),
                  _buildQuickAccessButton("SALIDA", Colors.red, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const IngresoPage(modoInicial: "salida")))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButton(String label, Color color, VoidCallback onTap) {
    return Expanded(child: InkWell(onTap: onTap, child: Container(width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), border: Border.all(color: color, width: 2)), child: Center(child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18))))));
  }
}