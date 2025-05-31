import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/auto_model.dart';
import '../services/auto_service.dart';
import '../providers/auth_provider.dart';
import 'car_form_screen.dart'; // To navigate to CarFormScreen

class MyCarsScreen extends StatefulWidget {
  const MyCarsScreen({Key? key}) : super(key: key);

  @override
  State<MyCarsScreen> createState() => _MyCarsScreenState();
}

class _MyCarsScreenState extends State<MyCarsScreen> {
  final AutoService _autoService = AutoService();
  List<AutoModel>? _cars;
  bool _isLoading = true;
  String? _error;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = Provider.of<AuthProvider>(context, listen: false).currentUser?.id;
    _loadCars();
  }

  Future<void> _loadCars() async {
    if (_userId == null) {
      setState(() {
        _error = "Usuario no autenticado.";
        _isLoading = false;
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final cars = await _autoService.getMyCars(_userId!);
      setState(() {
        _cars = cars;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar autos: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateAndRefresh(Widget screen) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
    if (result == true) { // Check if form screen popped with success
      _loadCars();
    }
  }

  void _deleteCar(String carId) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text('¿Seguro que deseas eliminar este auto?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await _autoService.deleteCar(carId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Auto eliminado exitosamente.')),
        );
        _loadCars(); // Refresh list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar auto: ${e.toString()}')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis autos'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Padding(padding: const EdgeInsets.all(16), child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error), textAlign: TextAlign.center)))
              : _cars == null || _cars!.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('No tienes autos registrados.'),
                          const SizedBox(height: 8),
                          ElevatedButton(onPressed: () => _navigateAndRefresh(const CarFormScreen()), child: const Text("Agregar mi primer auto"))
                        ],
                      )
                    )
                  : RefreshIndicator(
                      onRefresh: _loadCars,
                      child: ListView.builder(
                        itemCount: _cars!.length,
                        itemBuilder: (context, index) {
                          final auto = _cars![index];
                          return ListTile(
                            title: Text('${auto.make} ${auto.model}'),
                            subtitle: Text(auto.patente),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  tooltip: 'Editar auto',
                                  onPressed: () => _navigateAndRefresh(CarFormScreen(auto: auto)),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  tooltip: 'Eliminar auto',
                                  color: Theme.of(context).colorScheme.error,
                                  onPressed: () => _deleteCar(auto.id),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateAndRefresh(const CarFormScreen()),
        tooltip: 'Agregar auto',
        child: const Icon(Icons.add),
      ),
    );
  }
}
