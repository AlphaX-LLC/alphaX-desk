import 'dart:io';
import 'package:flutter/material.dart' hide Dialog;
import 'package:flutter/material.dart' as material;
import '../../common.dart';
import '../../models/state_model.dart';

/// Shows the mandatory AlphaX Remote Tuning Disclaimer dialog.
/// If [barrierDismissible] is false, the user cannot close the dialog by tapping outside.
Future<bool> showDisclaimerDialog(BuildContext context, {bool forceShow = false}) async {
  if (stateGlobal.isDisclaimerAccepted.value && !forceShow) {
    return true;
  }

  bool accepted = false;

  await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext ctx) {
      return PopScope(
        canPop: false, // Prevent back button dismissal
        child: material.Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: const BorderSide(color: Color(0xFFE53935), width: 1.5),
          ),
          backgroundColor: const Color(0xFF1B1C22),
          elevation: 24,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 580, maxHeight: 620),
            padding: const EdgeInsets.all(24.0),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Banner
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.shield_outlined,
                            color: Color(0xFFE53935),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                translate('AlphaX Remote Tuning'),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                translate('Mandatory Client Startup & Safety Agreement'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFA0A5B5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFF2A2D36), height: 1),
                    const SizedBox(height: 16),

                    // Disclaimer Text Content Area
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF121318),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF2A2D36)),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDisclaimerSection(
                                title: '1. REMOTE CONNECTIONS & DIAGNOSTICS',
                                content:
                                    'By clicking "Accept & Continue", you authorize licensed AlphaX Tuning technicians to initiate remote control sessions on this machine to program, flash, configure, and calibrate vehicle Engine Control Units (ECUs) and related modules.',
                              ),
                              const SizedBox(height: 14),
                              _buildDisclaimerSection(
                                title: '2. NO WARRANTY ON AFTERMARKET TUNING',
                                content:
                                    'Aftermarket ECU tuning, map flashing, and performance calibration is a custom modification process and is NOT a warranted service. All tuning procedures are performed strictly AS-IS without any warranty, express or implied.',
                              ),
                              const SizedBox(height: 14),
                              _buildDisclaimerSection(
                                title: '3. RELEASE OF LIABILITY & DAMAGES',
                                content:
                                    'AlphaX Tuning and its authorized staff shall NOT be held liable for any mechanical wear, engine or drivetrain failure, electrical damage, or secondary component issues resulting directly or indirectly from the tuning process or subsequent vehicle operation.',
                              ),
                              const SizedBox(height: 14),
                              _buildDisclaimerSection(
                                title: '4. 2-HOUR SESSION TIME LIMIT & PAID EXTENSIONS',
                                content:
                                    'Every remote session is governed by an established 2-hour maximum time limit. By proceeding, you accept that once the 2-hour session timer expires, remote tuning access will lock and additional time must be purchased separately to continue tuning services.',
                              ),
                              const SizedBox(height: 14),
                              _buildDisclaimerSection(
                                title: '5. VEHICLE & OPERATIONAL SAFETY',
                                content:
                                    'During an active tuning session, the connected vehicle MUST remain safely parked in a well-ventilated area. NEVER drive or operate the vehicle while ECU flashing is in progress unless explicitly instructed by the tuner.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Actions Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Exit Button
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFE53935),
                            side: const BorderSide(color: Color(0xFFE53935)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            exit(0);
                          },
                          icon: const Icon(Icons.power_settings_new, size: 18),
                          label: Text(translate('Exit')),
                        ),
                        // Accept Button
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53935),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            stateGlobal.isDisclaimerAccepted.value = true;
                            accepted = true;
                            Navigator.of(ctx).pop(true);
                          },
                          icon: const Icon(Icons.check_circle_outline, size: 18),
                          label: Text(
                            translate('Accept & Continue'),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    },
  );

  return accepted;
}

Widget _buildDisclaimerSection({required String title, required String content}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF00E676), // Neon green accent for section headers
          letterSpacing: 0.5,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        content,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.white70,
          height: 1.4,
        ),
      ),
    ],
  );
}
