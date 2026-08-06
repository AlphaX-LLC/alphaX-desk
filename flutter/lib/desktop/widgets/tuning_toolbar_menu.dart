import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/model.dart';
import './tuning_overlay.dart';

/// Tuner Control Panel Menu Button added to Remote Session Toolbar
class TuningToolbarMenu extends StatefulWidget {
  final String id;
  final FFI ffi;

  const TuningToolbarMenu({
    Key? key,
    required this.id,
    required this.ffi,
  }) : super(key: key);

  @override
  State<TuningToolbarMenu> createState() => _TuningToolbarMenuState();
}

class _TuningToolbarMenuState extends State<TuningToolbarMenu> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _timerMinutesController =
      TextEditingController(text: '120');

  @override
  void dispose() {
    _textController.dispose();
    _timerMinutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = TuningOverlayController.instance;

    return Obx(() {
      final activeColor = _getStatusColor(controller.status.value);
      return PopupMenuButton<void>(
        tooltip: 'AlphaX Tuner Control Panel',
        icon: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: activeColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.traffic,
            color: activeColor,
            size: 18,
          ),
        ),
        color: const Color(0xFF1B1C22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF2A2D36)),
        ),
        offset: const Offset(0, 40),
        itemBuilder: (BuildContext ctx) {
          return [
            PopupMenuItem<void>(
              enabled: false,
              child: SizedBox(
                width: 320,
                child: Obx(() {
                  final curStatus = controller.status.value;
                  final statusColor = _getStatusColor(curStatus);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: const [
                          Icon(Icons.tune, color: Color(0xFF00E676), size: 18),
                          SizedBox(width: 8),
                          Text(
                            'AlphaX Tuner Overlay Controls',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Live Feedback Box for Tuner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF121318),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: statusColor.withOpacity(0.6),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _getStatusIcon(curStatus),
                                  color: statusColor,
                                  size: 15,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    curStatus == TuningOverlayStatus.off
                                        ? 'OVERLAY OFF'
                                        : 'CLIENT OVERLAY: ${_getStatusTitle(curStatus)}',
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  _getOpacityLabel(controller.opacityMode.value),
                                  style: const TextStyle(
                                    color: Color(0xFFA0A5B5),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                            if (controller.customText.value.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                '"${controller.customText.value}"',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFF2A2D36)),
                      const SizedBox(height: 8),

                      // Status Presets Title
                      const Text(
                        'STATUS LIGHT PRESETS',
                        style: TextStyle(
                          color: Color(0xFFA0A5B5),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    const SizedBox(height: 8),

                    // Traffic Light Buttons
                    Row(
                      children: [
                        _buildStatusButton(
                          title: 'RED',
                          color: const Color(0xFFE53935),
                          status: TuningOverlayStatus.red,
                          currentStatus: controller.status.value,
                          onPressed: () {
                            controller.setOverlayState(
                              statusVal: TuningOverlayStatus.red,
                            );
                          },
                        ),
                        const SizedBox(width: 6),
                        _buildStatusButton(
                          title: 'YELLOW',
                          color: const Color(0xFFFFB300),
                          status: TuningOverlayStatus.yellow,
                          currentStatus: controller.status.value,
                          onPressed: () {
                            controller.setOverlayState(
                              statusVal: TuningOverlayStatus.yellow,
                            );
                          },
                        ),
                        const SizedBox(width: 6),
                        _buildStatusButton(
                          title: 'GREEN',
                          color: const Color(0xFF00E676),
                          status: TuningOverlayStatus.green,
                          currentStatus: controller.status.value,
                          onPressed: () {
                            controller.setOverlayState(
                              statusVal: TuningOverlayStatus.green,
                            );
                          },
                        ),
                        const SizedBox(width: 6),
                        _buildStatusButton(
                          title: 'OFF',
                          color: Colors.grey,
                          status: TuningOverlayStatus.off,
                          currentStatus: controller.status.value,
                          onPressed: () {
                            controller.setOverlayState(
                              statusVal: TuningOverlayStatus.off,
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Custom Message Input
                    const Text(
                      'BROADCAST CUSTOM BANNER',
                      style: TextStyle(
                        color: Color(0xFFA0A5B5),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                            decoration: InputDecoration(
                              hintText: 'Enter message for client...',
                              hintStyle: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                              fillColor: const Color(0xFF121318),
                              filled: true,
                              isDense: true,
                              contentPadding: const EdgeInsets.all(10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide:
                                    const BorderSide(color: Color(0xFF2A2D36)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0071FF),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onPressed: () {
                            if (_textController.text.trim().isNotEmpty) {
                              controller.setOverlayState(
                                statusVal: TuningOverlayStatus.custom,
                                text: _textController.text.trim(),
                              );
                            }
                          },
                          child: const Text('Send',
                              style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Opacity Controls
                    const Text(
                      'OVERLAY OPACITY MODE',
                      style: TextStyle(
                        color: Color(0xFFA0A5B5),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildOpacityChip(
                          label: '100% Solid',
                          mode: TuningOpacityMode.opaque,
                          currentMode: controller.opacityMode.value,
                          onPressed: () => controller.opacityMode.value =
                              TuningOpacityMode.opaque,
                        ),
                        const SizedBox(width: 6),
                        _buildOpacityChip(
                          label: '30% Banner',
                          mode: TuningOpacityMode.semiTransparent,
                          currentMode: controller.opacityMode.value,
                          onPressed: () => controller.opacityMode.value =
                              TuningOpacityMode.semiTransparent,
                        ),
                        const SizedBox(width: 6),
                        _buildOpacityChip(
                          label: 'Hidden',
                          mode: TuningOpacityMode.hidden,
                          currentMode: controller.opacityMode.value,
                          onPressed: () => controller.opacityMode.value =
                              TuningOpacityMode.hidden,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFF2A2D36)),
                    const SizedBox(height: 8),

                    // Timer Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'SESSION TIMER (${(controller.configuredTimerSeconds.value / 60).round()}m Limit)',
                          style: const TextStyle(
                            color: Color(0xFFA0A5B5),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatSeconds(controller.secondsRemaining.value),
                          style: const TextStyle(
                            color: Color(0xFF00E676),
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Quick Preset Chips (15m, 30m, 1h, 2h, 4h)
                    Row(
                      children: [
                        _buildPresetChip(
                          label: '15m',
                          minutes: 15,
                          controller: controller,
                        ),
                        const SizedBox(width: 4),
                        _buildPresetChip(
                          label: '30m',
                          minutes: 30,
                          controller: controller,
                        ),
                        const SizedBox(width: 4),
                        _buildPresetChip(
                          label: '1h',
                          minutes: 60,
                          controller: controller,
                        ),
                        const SizedBox(width: 4),
                        _buildPresetChip(
                          label: '2h',
                          minutes: 120,
                          controller: controller,
                        ),
                        const SizedBox(width: 4),
                        _buildPresetChip(
                          label: '4h',
                          minutes: 240,
                          controller: controller,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Custom Minutes Input + Apply Row
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 30,
                            child: TextField(
                              controller: _timerMinutesController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Custom mins',
                                hintStyle: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 11,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 0,
                                ),
                                filled: true,
                                fillColor: const Color(0xFF121316),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF2A2D36),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF2A2D36),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF00E676),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E676),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            minimumSize: const Size(0, 30),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onPressed: () {
                            final mins = int.tryParse(
                              _timerMinutesController.text.trim(),
                            );
                            if (mins != null && mins > 0) {
                              controller.setCustomTimerMinutes(mins);
                            }
                          },
                          child: const Text(
                            'Set Limit',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: controller.isTimerRunning.isTrue
                                  ? const Color(0xFFFFB300)
                                  : const Color(0xFF00E676),
                              side: BorderSide(
                                color: controller.isTimerRunning.isTrue
                                    ? const Color(0xFFFFB300)
                                    : const Color(0xFF00E676),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            onPressed: () {
                              if (controller.isTimerRunning.isTrue) {
                                controller.pauseTimer();
                              } else {
                                controller.startTimer();
                              }
                            },
                            icon: Icon(
                              controller.isTimerRunning.isTrue
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              size: 16,
                            ),
                            label: Text(
                              controller.isTimerRunning.isTrue
                                  ? 'Pause'
                                  : 'Start',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: const BorderSide(color: Color(0xFF2A2D36)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          onPressed: () {
                            controller.resetTimer();
                          },
                          child: const Text('Reset',
                              style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ),
          ),
        ];
      },
    );
  });
}

  Widget _buildStatusButton({
    required String title,
    required Color color,
    required TuningOverlayStatus status,
    required TuningOverlayStatus currentStatus,
    required VoidCallback onPressed,
  }) {
    final bool isSelected = status == currentStatus;
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? Colors.white : color.withOpacity(0.4),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.black : color,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOpacityChip({
    required String label,
    required TuningOpacityMode mode,
    required TuningOpacityMode currentMode,
    required VoidCallback onPressed,
  }) {
    final bool isSelected = mode == currentMode;
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF00E676)
                : const Color(0xFF121318),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF00E676)
                  : const Color(0xFF2A2D36),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white70,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPresetChip({
    required String label,
    required int minutes,
    required TuningOverlayController controller,
  }) {
    final bool isSelected =
        (controller.configuredTimerSeconds.value / 60).round() == minutes;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _timerMinutesController.text = minutes.toString();
          controller.setCustomTimerMinutes(minutes);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF00E676)
                : const Color(0xFF121318),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF00E676)
                  : const Color(0xFF2A2D36),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white70,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatSeconds(int totalSeconds) {
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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
        return Colors.grey;
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
        return 'RED - STOP';
      case TuningOverlayStatus.yellow:
        return 'YELLOW - IN PROGRESS';
      case TuningOverlayStatus.green:
        return 'GREEN - TEST RUN READY';
      case TuningOverlayStatus.custom:
        return 'CUSTOM NOTICE';
      case TuningOverlayStatus.off:
        return 'OFF';
    }
  }

  String _getOpacityLabel(TuningOpacityMode mode) {
    switch (mode) {
      case TuningOpacityMode.opaque:
        return '100% Solid';
      case TuningOpacityMode.semiTransparent:
        return '30% Banner';
      case TuningOpacityMode.hidden:
        return 'Hidden';
    }
  }
}
