import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:fitness_tracker/core/error/failures.dart';
import 'package:fitness_tracker/core/usecases/app_usecase.dart';
import 'package:fitness_tracker/features/auth/data/repositories/auth_repository.dart';
import 'package:fitness_tracker/features/auth/domain/entities/auth_entity.dart';
import 'package:fitness_tracker/features/auth/domain/repositories/auth_repositories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpdateUserParams extends Equatable {
  final String userId;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String password;

  const UpdateUserParams({
    required this.userId,
    this.fullName,
    this.email,
    this.phoneNumber,
    required this.password,
  });

  @override
  List<Object?> get props => [userId, fullName, email, phoneNumber, password];
}

// provider for update user usecase
final updateUserUsecaseProvider = Provider<UpdateUserUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return UpdateUserUsecase(authRepository: authRepository);
});

class UpdateUserUsecase implements UsecaseWithParms<AuthEntity, UpdateUserParams> {
  final IAuthRepository _authRepository;

  UpdateUserUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call(UpdateUserParams params) async {
    // Get current user to get existing data
    final currentUserResult = await _authRepository.getCurrentUser();
    
    return currentUserResult.fold(
      (failure) => Left(failure),
      (currentUser) {
        // Create entity with updated values, keeping existing ones if not provided
        final updatedEntity = AuthEntity(
          authId: params.userId,
          fullName: params.fullName ?? currentUser.fullName,
          email: params.email ?? currentUser.email,
          phoneNumber: params.phoneNumber ?? currentUser.phoneNumber,
          password: currentUser.password, // Password is used for verification, not update
          profilePicture: currentUser.profilePicture,
        );
        
        return _authRepository.updateUser(updatedEntity, params.password);
      },
    );
  }
}
