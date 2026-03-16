import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StateHelper {
  /// Update any provider globally
  static void update<T extends ChangeNotifier>(
    BuildContext context,
    void Function(T provider) updater,
  ) {
    final provider = Provider.of<T>(context, listen: false);
    updater(provider);
  }
}
