import 'package:flutter/material.dart';
import '../services/carquery_service.dart';
import '../services/auto_service.dart';
import 'welcome_screen.dart';

class VehicleSetupScreen extends StatefulWidget {
  const VehicleSetupScreen({Key? key}) : super(key: key);

  @override
  State<VehicleSetupScreen> createState() => _VehicleSetupScreenState();
}

class _VehicleSetupScreenState extends State<VehicleSetupScreen> {
  final CarQueryService _carQuery = CarQueryService();
  final AutoService _autoService = AutoService();

  List<int> _years = [];
  List<CarQueryMake> _makes = [];
  List<CarQueryModel> _models = [];
  List<CarQueryTrim> _trims = [];

  int? _selectedYear;
  String? _selectedMakeId;
  String? _selectedModel;
  String? _selectedTrimModelId;

  double? _lengthM;
  double? _widthM;
  double? _heightM;

  @override
  void initState() {
    super.initState();
    _fetchYears();
  }

  Future<void> _fetchYears() async {
    final years = await _carQuery.getYears();
    years.sort((a, b) => b.compareTo(a));
    setState(() => _years = years);
  }

  Future<void> _onYearChanged(int? year) async {
    if (year == null) return;
    setState(() {
      _selectedYear = year;
      _selectedMakeId = null;
      _selectedModel = null;
      _selectedTrimModelId = null;
      _makes = [];
      _models = [];
      _trims = [];
      _lengthM = _widthM = _heightM = null;
    });
    final makes = await _carQuery.getMakes(year);
    setState(() => _makes = makes);
  }

  Future<void> _onMakeChanged(String? makeId) async {
    if (makeId == null || _selectedYear == null) return;
    setState(() {
      _selectedMakeId = makeId;
      _selectedModel = null;
      _selectedTrimModelId = null;
      _models = [];
      _trims = [];
      _lengthM = _widthM = _heightM = null;
    });
    final models = await _carQuery.getModels(makeId, _selectedYear!);
    setState(() => _models = models);
  }

  Future<void> _onModelChanged(String? modelName) async {
    if (modelName == null || _selectedYear == null || _selectedMakeId == null) return;
    setState(() {
      _selectedModel = modelName;
      _selectedTrimModelId = null;
      _trims = [];
      _lengthM = _widthM = _heightM = null;
    });
    final trims = await _carQuery.getTrims(
      _selectedMakeId!,
      modelName,
      _selectedYear!,
    );
    setState(() => _trims = trims);
  }

  Future<void> _onTrimChanged(String? modelId) async {
    if (modelId == null) return;
    setState(() => _selectedTrimModelId = modelId);
    final dims = await _carQuery.getModelDimensions(modelId);
    if (dims != null) {
      setState(() {
        _lengthM = dims['length_mm'] / 1000;
        _widthM = dims['width_mm'] / 1000;
        _heightM = dims['height_mm'] / 1000;
      });
    }
  }

  Future<void> _saveVehicle() async {
    if (_selectedMakeId == null || _selectedModel == null ||
        _selectedYear == null || _lengthM == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }
    final largoCm = (_lengthM! * 100).round();
    final anchoCm = (_widthM! * 100).round();
    final altoCm = (_heightM! * 100).round();
    final auto = await _autoService.crearAuto(
      marca: _selectedMakeId!,
      modelo: _selectedModel!,
      anio: _selectedYear!,
      largoCm: largoCm,
      anchoCm: anchoCm,
      altoCm: altoCm,
    );
    await _autoService.asignarAutoAUsuario(auto.id);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final yearItems = _years
        .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
        .toList();
    final makeItems = _makes
        .map((m) => DropdownMenuItem(value: m.makeId, child: Text(m.makeName)))
        .toList();
    final modelItems = _models
        .map((m) => DropdownMenuItem(
              value: m.modelName,
              child: Text(m.modelName),
            ))
        .toList();
    final trimItems = _trims
        .map((t) => DropdownMenuItem(value: t.modelId, child: Text(t.trimName)))
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Configurar auto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Año'),
              items: yearItems,
              value: _selectedYear,
              onChanged: (v) => _onYearChanged(v),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Marca'),
              items: makeItems,
              value: _selectedMakeId,
              onChanged: (v) => _onMakeChanged(v),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Modelo'),
              items: modelItems,
              value: _selectedModel,
              onChanged: _onModelChanged,
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Trim'),
              items: trimItems,
              value: _selectedTrimModelId,
              onChanged: (v) => _onTrimChanged(v),
            ),
            const SizedBox(height: 20),
            if (_lengthM != null) ...[
              Text('Largo: ${_lengthM!.toStringAsFixed(2)} m'),
              Text('Ancho: ${_widthM!.toStringAsFixed(2)} m'),
              Text('Alto:  ${_heightM!.toStringAsFixed(2)} m'),
            ],
            const Spacer(),
            ElevatedButton(
              onPressed: _saveVehicle,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}