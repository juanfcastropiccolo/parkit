import '../models/user_model.dart';
import 'auth_service.dart'; // To potentially reuse existing Supabase calls
import 'package:supabase_flutter/supabase_flutter.dart'; // For Supabase client if direct calls are needed
import '../config/supabase_config.dart'; // For table names

class UserService {
  final AuthService _authService = AuthService();
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<UserModel?> getCurrentUser() async {
    // Reuses AuthService.getUserProfile which already fetches from Supabase Users table
    // And UserModel.fromJson will map to the updated UserModel
    return await _authService.getUserProfile();
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    // Reuses AuthService.updateUserProfile which already updates Supabase Users table
    // AuthService.updateUserProfile takes a UserModel, so it will use the updated model's toJson method
    try {
      // We need to ensure that the data passed to Supabase matches the table schema.
      // The existing AuthService.updateUserProfile uses UserModel.toJson().
      // UserModel now includes 'telefono'. Ensure 'Users' table in Supabase has this column.
      // For now, assume the column exists or will be added.
      await _authService.updateUserProfile(updatedUser);
    } catch (e) {
      // Log or handle specific errors if necessary
      print('UserService.updateProfile error: $e');
      rethrow;
    }
  }
}
