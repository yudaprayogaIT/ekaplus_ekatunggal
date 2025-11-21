// lib/features/auth/presentation/cubit/auth_session_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ekaplus_ekatunggal/core/utils/session_manager.dart';
import 'package:ekaplus_ekatunggal/features/auth/data/models/user_model.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';
import 'auth_session_state.dart';

class AuthSessionCubit extends Cubit<AuthSessionState> {
  AuthSessionCubit() : super(AuthSessionInitial());

  // Check if user has saved session on app start
  Future<void> checkSession() async {
    emit(AuthSessionLoading());

    try {
      final isLoggedIn = await SessionManager.isLoggedIn();

      if (!isLoggedIn) {
        emit(const AuthSessionGuest());
        return;
      }

      final userData = await SessionManager.getCurrentUser();
      if (userData == null) {
        emit(const AuthSessionGuest());
        return;
      }

      // Convert Map to User entity
      final user = UserModel.fromJson(userData);
      
      // Determine status (you can add logic to check if member)
      final status = _determineUserStatus(user);

      emit(AuthSessionAuthenticated(user: user, status: status));
      print('✅ Session restored: ${user.fullName}');
    } catch (e) {
      print('❌ Error checking session: $e');
      emit(const AuthSessionGuest());
    }
  }

  // Login - save session and update state
  Future<void> login(User user) async {
    try {
      // Save to SharedPreferences
      final userMap = (user as UserModel).toJson();
      await SessionManager.saveLoginSession(userMap);

      // Update state
      final status = _determineUserStatus(user);
      emit(AuthSessionAuthenticated(user: user, status: status));
      
      print('✅ User logged in: ${user.fullName}');
    } catch (e) {
      print('❌ Error saving login session: $e');
    }
  }

  // Logout - clear session
  Future<void> logout() async {
    try {
      await SessionManager.clearSession();
      emit(const AuthSessionGuest());
      print('✅ User logged out');
    } catch (e) {
      print('❌ Error logging out: $e');
    }
  }

  // Update user data (e.g., after profile edit)
  Future<void> updateUser(User user) async {
    try {
      final userMap = (user as UserModel).toJson();
      await SessionManager.updateUserData(userMap);

      final status = _determineUserStatus(user);
      emit(AuthSessionAuthenticated(user: user, status: status));
      
      print('✅ User data updated: ${user.fullName}');
    } catch (e) {
      print('❌ Error updating user: $e');
    }
  }

  // Helper: Determine user status based on user data
  UserStatus _determineUserStatus(User user) {
    // TODO: Add your logic to determine if user is member
    // For example: check if user has company, membership level, etc.
    
    // For now, default to loggedIn
    // You can add: if (user.company != null) return UserStatus.member;
    return UserStatus.loggedIn;
  }

  // Helper getters for easy access
  bool get isGuest => state is AuthSessionGuest;
  bool get isAuthenticated => state is AuthSessionAuthenticated;
  
  User? get currentUser {
    final currentState = state;
    if (currentState is AuthSessionAuthenticated) {
      return currentState.user;
    }
    return null;
  }

  UserStatus? get userStatus {
    final currentState = state;
    if (currentState is AuthSessionAuthenticated) {
      return currentState.status;
    }
    return null;
  }
}