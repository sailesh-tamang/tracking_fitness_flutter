import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:fitness_tracker/core/error/failures.dart';
import 'package:fitness_tracker/features/auth/domain/entities/auth_entity.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, bool>> register(AuthEntity entity);
  Future<Either<Failure, AuthEntity>> login(String email, String password);
  Future<Either<Failure, AuthEntity>> getCurrentUser();
  Future<Either<Failure, bool>> logout();
  // image upload
  Future<Either<Failure,String>> uploadImage(File image);
  // update user profile
  Future<Either<Failure, AuthEntity>> updateUser(AuthEntity entity, String password);
}