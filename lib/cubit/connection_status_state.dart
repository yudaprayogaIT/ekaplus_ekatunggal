part of 'connection_status_cubit.dart';

enum ConnectionStatus { online, offline, low }

class ConnectionStateCubit {
  final ConnectionStatus status;

  const ConnectionStateCubit({required this.status});
}
