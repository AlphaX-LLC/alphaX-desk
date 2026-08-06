import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

enum TuningOverlayStatus { off, red, yellow, green, custom }

enum TuningOpacityMode { opaque, semiTransparent, hidden }

class TuningOverlayController extends GetxController {
  static TuningOverlayController get instance {
    if (!Get.isRegistered<TuningOverlayController>()) {
      return Get.put(TuningOverlayController());
    }
    return Get.find<TuningOverlayController>();
  }

  final status = TuningOverlayStatus.off.obs;
  final customText = ''.obs;
  final opacityMode = TuningOpacityMode.opaque.obs;

  // Session Timer State (in seconds)
  final configuredTimerSeconds = (2 * 3600).obs; // Configured Limit (Default 2h)
  final secondsRemaining = (2 * 3600).obs;
  final isTimerRunning = false.obs;
  final isSessionExpired = false.obs;

  // Two-way chat message list inside overlay
  final chatMessages = <String>[].obs;

  Timer? _countdownTimer;

  void setCustomTimerMinutes(int minutes) {
    final secs = minutes * 60;
    configuredTimerSeconds.value = secs;
    resetTimer(secs);
  }

  void startTimer([int? initialSeconds]) {
    if (initialSeconds != null) {
      configuredTimerSeconds.value = initialSeconds;
      secondsRemaining.value = initialSeconds;
    }
    isTimerRunning.value = true;
    isSessionExpired.value = false;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        isTimerRunning.value = false;
        isSessionExpired.value = true;
        timer.cancel();
      }
    });
  }

  void pauseTimer() {
    isTimerRunning.value = false;
    _countdownTimer?.cancel();
  }

  void resetTimer([int? seconds]) {
    pauseTimer();
    if (seconds != null) {
      configuredTimerSeconds.value = seconds;
    }
    secondsRemaining.value = configuredTimerSeconds.value;
    isSessionExpired.value = false;
  }

  void setOverlayState({
    required TuningOverlayStatus statusVal,
    String? text,
    TuningOpacityMode? opacity,
  }) {
    status.value = statusVal;
    if (text != null) customText.value = text;
    if (opacity != null) opacityMode.value = opacity;
  }

  void addChatMessage(String sender, String message) {
    chatMessages.add('$sender: $message');
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }
}

/// Floating Banner & Fullscreen Lockout Overlay Widget for Client Machine.
class TuningOverlayWidget extends StatelessWidget {
  const TuningOverlayWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = TuningOverlayController.instance;

    return Obx(() {
      if (controller.isSessionExpired.isTrue) {
        return _buildExpiredLockoutScreen(context, controller);
      }

      if (controller.status.value == TuningOverlayStatus.off ||
          controller.opacityMode.value == TuningOpacityMode.hidden) {
        return const SizedBox.shrink();
      }

      final double opacity =
          controller.opacityMode.value == TuningOpacityMode.semiTransparent
              ? 0.3
              : 1.0;

      return Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Opacity(
          opacity: opacity,
          child: Material(
            elevation: 16,
            color: Colors.transparent,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF111216).withOpacity(0.95),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: _getStatusColor(controller.status.value),
                    width: 3,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        _getStatusColor(controller.status.value).withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Traffic Light Indicator Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: _getStatusColor(controller.status.value),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getStatusIcon(controller.status.value),
                              color: Colors.black,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getStatusTitle(controller.status.value),
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Custom Banner Message / Instructions
                      Expanded(
                        child: Text(
                          controller.customText.value.isNotEmpty
                              ? controller.customText.value
                              : _getDefaultInstruction(controller.status.value),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Timer Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF121318),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF2A2D36)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.timer_outlined,
                                color: Color(0xFF00E676), size: 16),
                            const SizedBox(width: 6),
                            Text(
                              _formatSeconds(controller.secondsRemaining.value),
                              style: const TextStyle(
                                color: Color(0xFF00E676),
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  /// Session Expired Fullscreen Lockout Modal (Phase 3 feature component)
  Widget _buildExpiredLockoutScreen(
      BuildContext context, TuningOverlayController controller) {
    return Positioned.fill(
      child: Material(
        color: const Color(0xFF121318).withOpacity(0.96),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1C22),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE53935), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE53935).withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.timer_off_outlined,
                    color: Color(0xFFE53935),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'SESSION TIME LIMIT EXPIRED',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your 2-hour tuning session time limit has been reached.\nTo continue tuning services, please purchase additional hours.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFA0A5B5),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 6,
                  ),
                  onPressed: () async {
                    final Uri url = Uri.parse(
                        'https://alphaxpr.com/collections/tuning-service');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                  label: const Text(
                    'Purchase Additional Hours',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(TuningOverlayStatus status) {
    switch (status) {
      case TuningOverlayStatus.red:
        return const Color(0xFFE53935);
      case TuningOverlayStatus.yellow:
        return const Color(0xFFFFB300);
      case TuningOverlayStatus.green:
        return const Color(0xFF00E676);
      case TuningOverlayStatus.custom:
        return const Color(0xFF0071FF);
      case TuningOverlayStatus.off:
        return Colors.transparent;
    }
  }

  IconData _getStatusIcon(TuningOverlayStatus status) {
    switch (status) {
      case TuningOverlayStatus.red:
        return Icons.do_not_disturb_on;
      case TuningOverlayStatus.yellow:
        return Icons.pause_circle_filled;
      case TuningOverlayStatus.green:
        return Icons.play_circle_fill;
      case TuningOverlayStatus.custom:
        return Icons.info;
      case TuningOverlayStatus.off:
        return Icons.circle_outlined;
    }
  }

  String _getStatusTitle(TuningOverlayStatus status) {
    switch (status) {
      case TuningOverlayStatus.red:
        return 'STOP';
      case TuningOverlayStatus.yellow:
        return 'TUNING IN PROGRESS';
      case TuningOverlayStatus.green:
        return 'TEST RUN READY';
      case TuningOverlayStatus.custom:
        return 'NOTICE';
      case TuningOverlayStatus.off:
        return '';
    }
  }

  String _getDefaultInstruction(TuningOverlayStatus status) {
    switch (status) {
      case TuningOverlayStatus.red:
        return 'Turn off engine immediately / Wait for instructions.';
      case TuningOverlayStatus.yellow:
        return 'Do not touch laptop or vehicle controls while ECU flashing is active.';
      case TuningOverlayStatus.green:
        return 'Vehicle ready for test run and data logging.';
      case TuningOverlayStatus.custom:
        return '';
      case TuningOverlayStatus.off:
        return '';
    }
  }

  String _formatSeconds(int totalSeconds) {
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
