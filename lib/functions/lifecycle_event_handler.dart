import 'package:flutter/widgets.dart';

class LifecycleEventHandler extends WidgetsBindingObserver {
  final Future<void> Function()? detachedCallBack;

  LifecycleEventHandler({this.detachedCallBack});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      // เมื่อออกจากแอปจริงๆ (ไม่ใช่แค่เปลี่ยนหน้า)
      detachedCallBack?.call();
    }
  }
}
