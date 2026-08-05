import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/pet_controller.dart';
import 'services/notification_service.dart';

class LifecycleObserver with WidgetsBindingObserver {
  final WidgetRef ref;

  LifecycleObserver(this.ref);

  void register() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        final petState = ref.read(petControllerProvider);
        NotificationService.scheduleWarnings(petState);
      case AppLifecycleState.resumed:
        NotificationService.cancelAll();
        ref.read(petControllerProvider.notifier).applyTimeDecay();
      default:
        break;
    }
  }
}
