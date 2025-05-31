import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/auto_model.dart';
import '../services/auto_service.dart';
import '../providers/auth_provider.dart';

class CarFormScreen extends StatefulWidget {
  final AutoModel? auto; // Null if adding a new car

  const CarFormScreen({Key? key, this.auto}) : super(key: key);

  @override
  State<CarFormScreen> createState() => _CarFormScreenState();
}

class _CarFormScreenState extends State<CarFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final AutoService _autoService = AutoService();

  late TextEditingController _makeController;
  late TextEditingController _modelController;
  late TextEditingController _plateController;
  late TextEditingController _lengthController;
  late TextEditingController _widthController;

  bool _isLoading = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = Provider.of<AuthProvider>(context, listen: false).currentUser?.id;

    _makeController = TextEditingController(text: widget.auto?.make ?? '');
    _modelController = TextEditingController(text: widget.auto?.model ?? '');
    _plateController = TextEditingController(text: widget.auto?.patente ?? '');
    _lengthController = TextEditingController(text: widget.auto?.lengthCm.toString() ?? '');
    _widthController = TextEditingController(text: widget.auto?.widthCm.toString() ?? '');
  }

  Future<void> _saveCar() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Usuario no identificado.')),
        );
        return;
      }

      setState(() => _isLoading = true);

      final autoData = AutoModel(
        id: widget.auto?.id ?? '', // ID will be ignored by Supabase on insert, used for update
        userId: _userId!,
        make: _makeController.text,
        model: _modelController.text,
        patente: _plateController.text,
        lengthCm: int.tryParse(_lengthController.text) ?? 0,
        widthCm: int.tryParse(_widthController.text) ?? 0,
        // anio and altoCm are optional in AutoModel, not explicitly in form per issue spec
      );

      try {
        if (widget.auto == null) { // Adding new car
          await _autoService.addCar(autoData);
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Auto agregado exitosamente.')),
          );
        } else { // Editing existing car
          // Need to use the existing ID for update
          final updatedAutoWithId = autoData.copyWith(id: widget.auto!.id);
          await _autoService.updateCar(updatedAutoWithId);
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Auto actualizado exitosamente.')),
          );
        }
        if (mounted) Navigator.of(context).pop(true); // Pop with result true to indicate success/refresh
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar auto: ${e.toString()}')),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _plateController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.auto == null ? 'Agregar auto' : 'Editar auto'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      controller: _makeController,
                      decoration: const InputDecoration(labelText: 'Marca'),
                      validator: (value) => value!.isEmpty ? 'La marca no puede estar vacía' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _modelController,
                      decoration: const InputDecoration(labelText: 'Modelo'),
                      validator: (value) => value!.isEmpty ? 'El modelo no puede estar vacío' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _plateController,
                      decoration: const InputDecoration(labelText: 'Patente'),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'La patente no puede estar vacía';
                        if (!RegExp(r'^[A-Z0-9]{1,10}$').hasMatch(value.toUpperCase())) return 'Formato de patente inválido (ej: ABC123DE)';
                        return null;
                      },
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lengthController,
                      decoration: const InputDecoration(labelText: 'Largo (cm)'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'El largo no puede estar vacío';
                        final val = int.tryParse(value);
                        if (val == null || val <= 0) return 'Debe ser un número positivo';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _widthController,
                      decoration: const InputDecoration(labelText: 'Ancho (cm)'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'El ancho no puede estar vacío';
                        final val = int.tryParse(value);
                        if (val == null || val <= 0) return 'Debe ser un número positivo';
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveCar,
                      child: _isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Guardar'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
