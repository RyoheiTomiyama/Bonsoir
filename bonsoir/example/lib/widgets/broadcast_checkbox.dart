import 'package:bonsoir_example/models/broadcast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Allows to switch the app broadcast state.
class BroadcastSwitch extends ConsumerWidget {
  /// Creates a new broadcast switch instance.
  const BroadcastSwitch({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    BonsoirBroadcastModel model = ref.watch(broadcastModelProvider);
    return InkWell(
      onTap: () => _onTap(model),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Broadcast'.toUpperCase()),
          Switch(
            value: model.isBroadcasting,
            onChanged: (value) => _onTap(model),
            activeColor: Colors.white,
            activeTrackColor: Colors.white54,
          ),
        ],
      ),
    );
  }

  /// Triggered when the widget has been tapped on.
  void _onTap(BonsoirBroadcastModel model) {
    if (model.isBroadcasting) {
      model.stop();
    } else {
      model.start();
    }
  }
}
