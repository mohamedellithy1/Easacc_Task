import 'package:equatable/equatable.dart';
import '../../domain/entities/device_entity.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
  @override
  List<Object> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final String? url;
  final List<DeviceEntity> devices;

  const SettingsLoaded({this.url, this.devices = const []});

  SettingsLoaded copyWith({String? url, List<DeviceEntity>? devices}) {
    return SettingsLoaded(
      url: url ?? this.url,
      devices: devices ?? this.devices,
    );
  }

  @override
  List<Object> get props => [url ?? '', devices];
}

class SettingsError extends SettingsState {
  final String message;
  const SettingsError(this.message);

  @override
  List<Object> get props => [message];
}

class UrlSaved extends SettingsState {}