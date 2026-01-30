// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthApiModel _$AuthApiModelFromJson(Map<String, dynamic> json) => AuthApiModel(
  id: json['_id'] as String?,
  fullName: json['name'] as String,
  email: json['email'] as String,
  phoneNumber: json['phoneNumber'] as String?,
  password: json['password'] as String?,
  profilePicture: json['profilePicture'] as String?,
);

Map<String, dynamic> _$AuthApiModelToJson(AuthApiModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.fullName,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'password': instance.password,
      'profilePicture': instance.profilePicture,
    };
