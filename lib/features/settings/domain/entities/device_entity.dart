import 'package:equatable/equatable.dart';

class DeviceEntity extends Equatable {
  final String id;
  final String name;
  final String type; 

  const DeviceEntity({
    required this.id,
    required this.name,
    required this.type,
  });

  @override
  List<Object> get props => [id, name, type];
}

