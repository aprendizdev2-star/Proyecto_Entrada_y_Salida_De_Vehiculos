import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'constants.dart';

class IngresoPage extends StatefulWidget {
  final String modoInicial; // Recibe el modo desde el Dashboard
  const IngresoPage({Key? key, this.modoInicial = "ingreso"}) : super(key: key);

  @override
  State<IngresoPage> createState() => _IngresoPageState();
}

class _IngresoPageState extends State<IngresoPage> {
  List<Map<String, String>> listaIngresos = [];
  List<Map<String, String>> resultadosBusqueda = [];
  
  late String modoActual; // Se inicializará con el modo recibido

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController placaController = TextEditingController();
  final TextEditingController buscarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    modoActual = widget.modoInicial; // Sincroniza con el botón presionado
    _cargarDatosPersistentes();
  }

  Future<void> _cargarDatosPersistentes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? datosCache = prefs.getString('ingresos_cache');
    if (datosCache != null) {
      final List<dynamic> decodedData = json.decode(datosCache);
      setState(() {
        listaIngresos = decodedData.map((item) => Map<String, String>.from(item)).toList();
      });
    }
  }

  Future<void> _guardarEnLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(listaIngresos);
    await prefs.setString('ingresos_cache', encodedData);
  }

  void _mostrarDialogoBuscar() {
    setState(() => resultadosBusqueda = []); 
    buscarController.clear();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Container(
              padding: const EdgeInsets.all(20),
              width: 450,
              constraints: const BoxConstraints(maxHeight: 550),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Buscar por Nombre o Placa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  TextField(
                    controller: buscarController,
                    decoration: InputDecoration(
                      hintText: "Escriba el nombre o la placa...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        if (value.isEmpty) {
                          resultadosBusqueda = [];
                        } else {
                          resultadosBusqueda = listaIngresos.where((v) {
                            return v["nombre"]!.toLowerCase().contains(value.toLowerCase()) ||
                                   v["placa"]!.toLowerCase().contains(value.toLowerCase());
                          }).toList();
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  const Divider(),
                  Expanded(
                    child: resultadosBusqueda.isEmpty
                        ? Center(child: Text(buscarController.text.isEmpty ? "Ingrese un término para buscar" : "No se encontraron resultados"))
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: resultadosBusqueda.length,
                            separatorBuilder: (context, index) => const Divider(),
                            itemBuilder: (context, index) {
                              final v = resultadosBusqueda[index];
                              bool haSalido = v["estado"] == "salida";
                              return ListTile(
                                title: Text(v["nombre"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text("Placa: ${v["placa"]}"),
                                trailing: Icon(Icons.circle, color: haSalido ? Colors.green : Colors.red, size: 12),
                                onTap: () {
                                  Navigator.pop(context);
                                  _mostrarDetalleBusqueda(v);
                                },
                              );
                            },
                          ),
                  ),
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar", style: TextStyle(color: Colors.grey)))
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _mostrarDetalleBusqueda(Map<String, String> vehiculo) {
    bool haSalido = vehiculo["estado"] == "salida";
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: const EdgeInsets.all(25),
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Información del Vehículo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildSectionHeader(vehiculo["nombre"]!, haSalido ? Colors.green : const Color(0xFFFF6B6B)),
              const SizedBox(height: 10),
              _buildInfoCard("Placa", vehiculo["placa"]!),
              _buildInfoCard(haSalido ? "Fecha de Ingreso / Salida" : "Fecha de Ingreso", haSalido ? "${vehiculo["fecha"]} / ${vehiculo["fecha_salida"]}" : vehiculo["fecha"]!),
              _buildInfoCard(haSalido ? "Hora de Ingreso / Salida" : "Hora de ingreso", haSalido ? "${vehiculo["hora"]} / ${vehiculo["hora_salida"]}" : vehiculo["hora"]!),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF332F2E), shape: const StadiumBorder(), minimumSize: const Size(120, 45)),
                child: const Text("Cerrar", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoSeleccionSalida() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 400,
          constraints: const BoxConstraints(maxHeight: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Seleccionar Vehículo para Salida', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              const Divider(thickness: 1),
              Expanded(
                child: listaIngresos.where((v) => v["estado"] != "salida").isEmpty 
                  ? const Center(child: Text("No hay vehículos pendientes"))
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: listaIngresos.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final vehiculo = listaIngresos[index];
                        if (vehiculo["estado"] == "salida") return const SizedBox.shrink();
                        return ListTile(
                          title: Text(vehiculo["nombre"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Placa: ${vehiculo["placa"]}"),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.pop(context);
                            _confirmarProcesarSalida(index);
                          },
                        );
                      },
                    ),
              ),
              const SizedBox(height: 10),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar", style: TextStyle(color: Colors.grey))),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmarProcesarSalida(int index) {
    final vehiculo = listaIngresos[index];
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: const EdgeInsets.all(25),
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Gestionar Reserva', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text('¿Desea registrar la salida de ${vehiculo["nombre"]} con placa ${vehiculo["placa"]}?', textAlign: TextAlign.center),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    String fechaSalida = DateFormat('MMM d, yyyy').format(DateTime.now());
                    String horaSalida = DateFormat('h:mm a').format(DateTime.now());
                    listaIngresos[index]["estado"] = "salida";
                    listaIngresos[index]["fecha_salida"] = fechaSalida;
                    listaIngresos[index]["hora_salida"] = horaSalida;
                  });
                  _guardarEnLocal();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: const StadiumBorder(), minimumSize: const Size(120, 45)),
                child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoIngreso() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Nuevo Ingreso", textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nombreController, decoration: const InputDecoration(labelText: "Nombre de la persona")),
              const SizedBox(height: 10),
              TextField(controller: placaController, decoration: const InputDecoration(labelText: "Placa del vehículo"), textCapitalization: TextCapitalization.characters),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar", style: TextStyle(color: Colors.red))),
            ElevatedButton(
              onPressed: () {
                if (nombreController.text.isNotEmpty && placaController.text.isNotEmpty) {
                  setState(() {
                    String fechaActual = DateFormat('MMM d, yyyy').format(DateTime.now());
                    String horaActual = DateFormat('h:mm a').format(DateTime.now());
                    listaIngresos.insert(0, {
                      "nombre": nombreController.text,
                      "placa": placaController.text,
                      "fecha": fechaActual,
                      "hora": horaActual,
                      "estado": "ingreso",
                    });
                  });
                  _guardarEnLocal();
                  nombreController.clear();
                  placaController.clear();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF332F2E)),
              child: const Text("Guardar", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: defaultBackgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        title: const Text("Entrada y Salida de vehículos", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCategoryBtn("Ingreso", modoActual == "ingreso" ? Colors.black87 : Colors.white, modoActual == "ingreso" ? Colors.white : Colors.black87, () => setState(() => modoActual = "ingreso")),
              _buildCategoryBtn("Salida", modoActual == "salida" ? Colors.black87 : Colors.white, modoActual == "salida" ? Colors.white : Colors.black87, () => setState(() => modoActual = "salida")),
              _buildCategoryBtn("Buscar", modoActual == "buscar" ? Colors.black87 : Colors.white, modoActual == "buscar" ? Colors.white : Colors.black87, () => setState(() => modoActual = "buscar")),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (modoActual == "ingreso") _mostrarDialogoIngreso();
                  else if (modoActual == "salida") _mostrarDialogoSeleccionSalida();
                  else _mostrarDialogoBuscar();
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF332F2E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: Text(modoActual == "ingreso" ? "Añadir Ingreso" : modoActual == "salida" ? "Añadir Salida" : "Buscar Vehículo", style: const TextStyle(color: Colors.white)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: listaIngresos.length,
              itemBuilder: (context, index) {
                final item = listaIngresos[index];
                bool haSalido = item["estado"] == "salida";
                return Column(
                  children: [
                    _buildSectionHeader(item["nombre"]!, haSalido ? Colors.green : const Color(0xFFFF6B6B)),
                    _buildInfoCard("Placa", item["placa"]!),
                    _buildInfoCard(haSalido ? "Fecha de Ingreso / Salida" : "Fecha de Ingreso", haSalido ? "${item["fecha"]} / ${item["fecha_salida"]}" : item["fecha"]!),
                    _buildInfoCard(haSalido ? "Hora de Ingreso / Salida" : "Hora de ingreso", haSalido ? "${item["hora"]} / ${item["hora_salida"]}" : item["hora"]!),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBtn(String text, Color bgColor, Color textColor, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(backgroundColor: bgColor, side: const BorderSide(color: Colors.black12), shape: const StadiumBorder()),
        child: Text(text, style: TextStyle(color: textColor, fontSize: 12)),
      ),
    );
  }

  Widget _buildSectionHeader(String name, Color color) {
    return Align(alignment: Alignment.centerLeft, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)), child: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))));
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(margin: const EdgeInsets.only(top: 8), width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text(value, style: const TextStyle(color: Colors.grey, fontSize: 13))]));
  }
}