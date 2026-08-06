import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

import 'package:flutter_hbb/consts.dart';
import 'package:flutter_hbb/desktop/widgets/tuning_overlay.dart';
import 'package:flutter_hbb/utils/multi_window_manager.dart';

/// Dedicated, borderless, always-on-top window that renders the AlphaX
/// tuning overlay on the client (host) machine's own screen.
///
/// This must NOT be nested inside the main app window or the Connection
/// Manager window: both are frequently hidden/minimized while a session is
/// active, so anything painted inside them never reaches the customer's
/// screen. This window is spawned fresh by the CM process (the process that
/// actually receives the tuner's overlay updates) and lives for the
/// duration of the session.
class DesktopTuningOverlayScreen extends StatefulWidget {
  final Map<String, dynamic> params;

  const DesktopTuningOverlayScreen({Key? key, required this.params})
      : super(key: key);

  @override
  State<DesktopTuningOverlayScreen> createState() =>
      _DesktopTuningOverlayScreenState();
}

class _DesktopTuningOverlayScreenState
    extends State<DesktopTuningOverlayScreen> {
  static const double _bannerHeight = 100;

  @override
  void initState() {
    super.initState();
    rustDeskWinManager.setMethodHandler((call, fromWindowId) async {
      if (call.method == kWindowEventUpdateTuningOverlay) {
        _applyPayload(call.arguments as String);
      }
      return null;
    });

    final initial = widget.params['overlay'];
    if (initial is String) {
      _applyPayload(initial);
    }

    final controller = TuningOverlayController.instance;
    ever(controller.status, (_) => _syncWindow());
    ever(controller.opacityMode, (_) => _syncWindow());
    ever(controller.isSessionExpired, (_) => _syncWindow());
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncWindow());
  }

  void _applyPayload(String payload) {
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      TuningOverlayController.instance.updateFromJson(data);
    } catch (e) {
      debugPrint('[AlphaX Overlay] Failed to apply payload: $e');
    }
  }

  Future<void> _syncWindow() async {
    final controller = TuningOverlayController.instance;
    final isExpired = controller.isSessionExpired.isTrue;
    final isActive = controller.status.value != TuningOverlayStatus.off &&
        controller.opacityMode.value != TuningOpacityMode.hidden;

    if (!isActive && !isExpired) {
      await windowManager.hide();
      return;
    }

    Size screenSize;
    try {
      final display = await screenRetriever.getPrimaryDisplay();
      screenSize = display.size;
    } catch (e) {
      debugPrint('[AlphaX Overlay] Failed to read display size: $e');
      screenSize = const Size(1280, 720);
    }

    await windowManager.setAlwaysOnTop(true);
    if (isExpired) {
      await windowManager.setBounds(
        Rect.fromLTWH(0, 0, screenSize.width, screenSize.height),
      );
    } else {
      await windowManager.setBounds(
        Rect.fromLTWH(0, 0, screenSize.width, _bannerHeight),
      );
    }
    await windowManager.show();
  }

  @override
  Widget build(BuildContext context) {
    return const Material(
      color: Colors.transparent,
      child: Stack(
        children: [TuningOverlayWidget()],
      ),
    );
  }
}
