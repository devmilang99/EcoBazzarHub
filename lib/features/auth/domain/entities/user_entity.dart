import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final bool isGoogleUser;

  const UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.isGoogleUser = false,
  });

  @override
  List<Object?> get props => [id, email, name, photoUrl, isGoogleUser];
}
