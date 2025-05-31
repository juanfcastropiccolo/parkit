import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser?.id != null) {
      try {
        // Use UserService to get potentially more complete/fresh data if needed,
        // or rely on AuthProvider's currentUser if it's guaranteed to be up-to-date.
        // For this implementation, let's use AuthProvider's cached user and allow editing.
        _currentUser = authProvider.currentUser;
        if (_currentUser != null) {
          _nameController.text = _currentUser!.nombre ?? '';
          _emailController.text = _currentUser!.email; // Email is typically from auth provider
          _phoneController.text = _currentUser!.telefono ?? '';
        } else {
           // Fallback if authProvider.currentUser is unexpectedly null but id was not.
           // This might happen if user data isn't fully loaded yet in AuthProvider.
           // A more robust solution might involve ensuring AuthProvider has fully loaded user data.
          var fetchedUser = await _userService.getCurrentUser();
          if (fetchedUser != null) {
            _currentUser = fetchedUser;
            _nameController.text = _currentUser!.nombre ?? '';
            _emailController.text = _currentUser!.email;
            _phoneController.text = _currentUser!.telefono ?? '';
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No se pudieron cargar los datos del usuario.')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cargar datos: ${e.toString()}')),
          );
        }
      }
    } else {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario no autenticado.')),
        );
        Navigator.of(context).pop(); // Pop if no user
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (_currentUser == null || authProvider.currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Usuario no encontrado.')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      // Create an updated UserModel instance
      // Ensure ID and email are correctly sourced, email usually not editable or handled by auth provider.
      UserModel updatedUser = _currentUser!.copyWith(
        nombre: _nameController.text,
        // email: _emailController.text, // Email is generally not updated here directly
        telefono: _phoneController.text,
      );

      try {
        await _userService.updateProfile(updatedUser);
        // Update AuthProvider's user data
        await authProvider.refreshUser(); // This should reload the user data in AuthProvider

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil actualizado exitosamente.')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar perfil: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentUser == null
              ? const Center(child: Text('No se pudieron cargar los datos del usuario.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Nombre'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'El nombre no puede estar vacío';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          readOnly: true, // Email is generally not editable
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(labelText: 'Teléfono (opcional)'),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            // Basic validation: allow empty or a simple pattern
                            // if (value != null && value.isNotEmpty && !RegExp(r'^\+?[0-9\s-]{7,15}$').hasMatch(value)) {
                            //   return 'Ingrese un número de teléfono válido';
                            // }
                            return null; // Optional field, so no empty check unless specified
                          },
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Guardar'),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
