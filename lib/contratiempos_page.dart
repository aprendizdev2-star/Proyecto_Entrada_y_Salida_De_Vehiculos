import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'constants.dart';

class ContratiemposPage extends StatefulWidget {
  const ContratiemposPage({Key? key}) : super(key: key);

  @override
  State<ContratiemposPage> createState() => _ContratiemposPageState();
}

class _ContratiemposPageState extends State<ContratiemposPage> {
  List<Map<String, String>> listaMensajes = [];
  final TextEditingController _mensajeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('contratiempos_cache');
    if (data != null) {
      setState(() {
        listaMensajes = List<Map<String, String>>.from(
            json.decode(data).map((item) => Map<String, String>.from(item)));
      });
    }
  }

  Future<void> _guardarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('contratiempos_cache', json.encode(listaMensajes));
  }

  void _confirmarEliminacion(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Eliminar Contratiempo"),
        content: const Text("¿Estás seguro de que deseas eliminar este mensaje?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                listaMensajes.removeAt(index);
              });
              _guardarDatos();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Eliminar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _agregarComentario() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Nuevo Contratiempo"),
        content: TextField(
          controller: _mensajeController,
          maxLines: 3,
          decoration: const InputDecoration(hintText: "Describa su situación aquí..."),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              if (_mensajeController.text.isNotEmpty) {
                setState(() {
                  listaMensajes.insert(0, {"texto": _mensajeController.text});
                });
                _guardarDatos();
                _mensajeController.clear();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF332F2E)),
            child: const Text("Publicar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: defaultBackgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: const Text("Contratiempos", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: const Color(0xFF332F2E), borderRadius: BorderRadius.circular(10)),
              child: const Text(
                "Escriba si tuvo algún contratiempo y actualice su horario de llegada con uno nuevo en la opcion Horarios",  
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton.icon(
              onPressed: _agregarComentario,
              icon: const Icon(Icons.add_circle, color: Colors.white),
              label: const Text("Agregar Contratiempo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: listaMensajes.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(radius: 15, child: Icon(Icons.person, size: 20)),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          listaMensajes[index]["texto"]!,
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmarEliminacion(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}