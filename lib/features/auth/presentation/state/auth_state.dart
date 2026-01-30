import 'package:equatable/equatable.dart';
import 'package:fitness_tracker/features/auth/domain/entities/auth_entity.dart';

enum AuthStatus {
  initial,
  loading,
  loaded,
  authenticated,
  unauthenticated,
  registered,
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthEntity? user;
  final String? errorMessage;
  final String? uploadedPhotoUrl;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.uploadedPhotoUrl,
  });

  AuthState copyWith({
    AuthStatus? status,
    AuthEntity? user,
    String? errorMessage,
    String? uploadedPhotoUrl,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      uploadedPhotoUrl: uploadedPhotoUrl ?? this.uploadedPhotoUrl,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage, uploadedPhotoUrl];
}