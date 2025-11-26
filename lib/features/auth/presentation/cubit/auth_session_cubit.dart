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

      // Determine status
      final status = _determineUserStatus(user);

      emit(AuthSessionAuthenticated(user: user, status: status));
      print('✅ Session restored: ${user.fullName}');
      print('📱 Current userId (phone): ${user.phone}');
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
      print('📱 UserId (phone): ${user.phone}');
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
   Future<void> updateUser(User updatedUser) async {
    try {
      print('');
      print('🔄 === UPDATING USER IN SESSION ===');
      
      // Get current user from state
      final currentState = state;
      if (currentState is! AuthSessionAuthenticated) {
        print('⚠️ Not authenticated, cannot update');
        return;
      }

      final oldUser = currentState.user;
      final oldPhone = oldUser.phone;
      final newPhone = updatedUser.phone;

      print('📱 Old userId (phone): $oldPhone');
      print('📱 New userId (phone): $newPhone');
      print('👤 User: ${updatedUser.fullName}');
      print('📧 Email: ${updatedUser.email}');

      // Convert to map
      final userMap = (updatedUser as UserModel).toJson();

      // ✨ CRITICAL: Update session with new phone as key
      await SessionManager.updateUserData(userMap);

      // Update state
      final status = _determineUserStatus(updatedUser);
      emit(AuthSessionAuthenticated(user: updatedUser, status: status));

      if (oldPhone != newPhone) {
        print('');
        print('🔄 PHONE CHANGED!');
        print('   Old: $oldPhone');
        print('   New: $newPhone');
        print('   ⚠️ All future requests will use new phone as userId');
        print('');
      }

      print('✅ === SESSION UPDATE COMPLETE ===');
      print('📱 Current userId: ${updatedUser.phone}');
      print('');
    } catch (e) {
      print('');
      print('❌ === SESSION UPDATE FAILED ===');
      print('Error: $e');
      print('');
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

  // ✨ NEW: Get current userId (phone number)
  String? get currentUserId {
    final user = currentUser;
    return user?.phone;
  }
}
