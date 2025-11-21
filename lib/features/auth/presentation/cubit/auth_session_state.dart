// lib/features/auth/presentation/cubit/auth_session_state.dart
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';
import 'package:equatable/equatable.dart';

enum UserStatus { guest, loggedIn, member }

abstract class AuthSessionState extends Equatable {
  const AuthSessionState();

  @override
  List<Object?> get props => [];
}

// Initial state - checking if user has saved session
class AuthSessionInitial extends AuthSessionState {}

// Loading state - checking session
class AuthSessionLoading extends AuthSessionState {}

// Guest state - not logged in
class AuthSessionGuest extends AuthSessionState {
  const AuthSessionGuest();
}

// Authenticated state - user logged in
class AuthSessionAuthenticated extends AuthSessionState {
  final User user;
  final UserStatus status;

  const AuthSessionAuthenticated({
    required this.user,
    this.status = UserStatus.loggedIn,
  });

  // Helper getters
  bool get isGuest => status == UserStatus.guest;
  bool get isLoggedIn => status == UserStatus.loggedIn;
  bool get isMember => status == UserStatus.member;

  @override
  List<Object?> get props => [user, status];

  // Copy with for easy updates
  AuthSessionAuthenticated copyWith({
    User? user,
    UserStatus? status,
  }) {
    return AuthSessionAuthenticated(
      user: user ?? this.user,
      status: status ?? this.status,
    );
  }
}