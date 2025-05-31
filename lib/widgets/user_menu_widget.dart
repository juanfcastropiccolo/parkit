import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart'; // To call signOut

// Enum for menu options to avoid string typos
enum UserMenuOption { profile, myCars, terms, logout }

class UserMenu extends StatelessWidget {
  const UserMenu({Key? key}) : super(key: key);

  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.signOut();
      // Navigate to login screen and remove all previous routes
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    } catch (e) {
      // Show error SnackBar if necessary
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: ${e.toString()}')),
      );
    }
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) { // Use a different context for the dialog
        return AlertDialog(
          title: const Text('Confirmar cierre de sesión'),
          content: const Text('¿Seguro que deseas cerrar sesión?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss dialog
              },
            ),
            TextButton(
              child: const Text('Cerrar sesión'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss dialog first
                _handleLogout(context); // Use original context for provider/navigation
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Potentially display user avatar if available from AuthProvider
    // final user = Provider.of<AuthProvider>(context).currentUser;
    // Widget iconWidget = user?.avatarUrl != null
    //   ? CircleAvatar(backgroundImage: NetworkImage(user.avatarUrl!))
    //   : const Icon(Icons.account_circle);

    return PopupMenuButton<UserMenuOption>(
      icon: const Icon(Icons.account_circle), // Using a generic icon for now
      tooltip: 'Menú de usuario',
      onSelected: (UserMenuOption result) {
        switch (result) {
          case UserMenuOption.profile:
            Navigator.pushNamed(context, '/profile');
            break;
          case UserMenuOption.myCars:
            Navigator.pushNamed(context, '/my_cars');
            break;
          case UserMenuOption.terms:
            Navigator.pushNamed(context, '/terms');
            break;
          case UserMenuOption.logout:
            _showLogoutConfirmationDialog(context);
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<UserMenuOption>>[
        const PopupMenuItem<UserMenuOption>(
          value: UserMenuOption.profile,
          child: ListTile(
            leading: Icon(Icons.person),
            title: Text('Perfil'),
          ),
        ),
        const PopupMenuItem<UserMenuOption>(
          value: UserMenuOption.myCars,
          child: ListTile(
            leading: Icon(Icons.directions_car),
            title: Text('Mis autos'),
          ),
        ),
        const PopupMenuItem<UserMenuOption>(
          value: UserMenuOption.terms,
          child: ListTile(
            leading: Icon(Icons.description),
            title: Text('Términos y condiciones'),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<UserMenuOption>(
          value: UserMenuOption.logout,
          child: ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Cerrar sesión'),
          ),
        ),
      ],
    );
  }
}
