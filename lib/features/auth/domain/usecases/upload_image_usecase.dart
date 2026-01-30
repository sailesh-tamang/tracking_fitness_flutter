import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:fitness_tracker/core/error/failures.dart';
import 'package:fitness_tracker/core/usecases/app_usecase.dart';
import 'package:fitness_tracker/features/auth/data/repositories/auth_repository.dart';
import 'package:fitness_tracker/features/auth/domain/repositories/auth_repositories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final uploadPhotoUsecaseProvider = Provider<UploadPhotoUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return UploadPhotoUsecase(authRepository: authRepository);
});

class UploadPhotoUsecase implements UsecaseWithParms<String, File> {
  final IAuthRepository _authRepository;

  UploadPhotoUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, String>> call(File photo) {
    return _authRepository.uploadImage(photo);
  }
}