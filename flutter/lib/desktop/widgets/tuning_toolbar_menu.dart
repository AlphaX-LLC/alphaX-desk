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

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = TuningOverlayController.instance;

    return PopupMenuButton<void>(
      tooltip: 'AlphaX Tuner Control Panel',
      icon: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFE53935).withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.traffic,
          color: Color(0xFFE53935),
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
                        const Text(
                          'SESSION TIMER (2h Limit)',
                          style: TextStyle(
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
                            controller.resetTimer(7200); // 2 hours
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

  String _formatSeconds(int totalSeconds) {
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
