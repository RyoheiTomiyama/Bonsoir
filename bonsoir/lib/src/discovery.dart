import 'package:bonsoir/src/action_handler.dart';
import 'package:bonsoir_platform_interface/bonsoir_platform_interface.dart';
import 'package:flutter/foundation.dart';

/// Allows to run a network discovery.
class BonsoirDiscovery extends BonsoirActionHandler<BonsoirDiscoveryEvent> {
  /// The type of service to find.
  final String type;

  /// The current service resolver.
  final ServiceResolver serviceResolver;

  /// Creates a new Bonsoir discovery instance with the given action.
  BonsoirDiscovery._internal({
    required this.type,
    required this.serviceResolver,
    required super.action,
  });

  /// Creates a new Bonsoir discovery instance.
  factory BonsoirDiscovery({
    bool printLogs = kDebugMode,
    required String type,
    ServiceResolver? serviceResolver,
  }) {
    BonsoirAction<BonsoirDiscoveryEvent> action = BonsoirPlatformInterface.instance.createDiscoveryAction(type, printLogs: printLogs);
    serviceResolver ??= action is ServiceResolver ? (action as ServiceResolver) : _NoServiceResolver();
    return BonsoirDiscovery._internal(
      type: type,
      serviceResolver: serviceResolver,
      action: action,
    );
  }

  /// This returns a JSON representation of this discovery.
  Map<String, dynamic> toJson() => super.toJson()..['type'] = type;
}

/// Created and used as a service resolver if none is provided.
class _NoServiceResolver with ServiceResolver {
  @override
  Future<void> resolveService(BonsoirService service) {
    throw UnimplementedError('No service resolver provided. Please ensure either you or your current platform interface provide one !');
  }
}
