
import 'package:dartz/dartz.dart';
import 'package:fitness_tracker/core/error/failures.dart';
import 'package:fitness_tracker/core/usecases/app_usecase.dart';
import 'package:fitness_tracker/features/auth/data/repositories/auth_repository.dart';
import 'package:fitness_tracker/features/auth/domain/repositories/auth_repositories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef LogoutUsecase = UsecaseWithoutParms<bool>;

final logoutUsecaseProvider = Provider<LogoutUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return LogoutUsecaseImpl(authRepository: authRepository);
});

class LogoutUsecaseImpl implements UsecaseWithoutParms<bool> {
  final IAuthRepository _authRepository;
  LogoutUsecaseImpl({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call() {
    return _authRepository.logout();
  }
}