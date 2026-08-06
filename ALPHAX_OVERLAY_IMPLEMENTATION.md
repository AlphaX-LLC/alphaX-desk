# AlphaX Overlay & Speed Optimization Implementation

This document provides a comprehensive summary of the architecture, design decisions, component implementations, and network synchronization mechanisms built for the **AlphaX Remote Tuning Desktop Platform**.

---

## 1. Overview & Key Objectives

1. **Default Performance Profile**:
   - Application defaults set to **Scale Adaptive** view mode and **Low Image Quality** to maximize reaction speed and minimize latency during live ECU tuning sessions.
2. **Always-On-Top 50% Screen-Width Client Banner**:
   - Overlays are rendered on the **Client Host PC** (customer machine) as an **Always-On-Top** banner styled at **50% of current screen width** (`width: screenWidth * 0.5`), centered horizontally across the top edge of the display.
   - Leverages `windowManager.setAlwaysOnTop(true)` when active so it floats on top of any open ECU software (EcuTek, HP Tuners, Cobb, etc.) on Windows/Desktop.
   - The banner is removed from the tuner's canvas paint list so it renders as part of the customer's desktop capture stream.
3. **Tuner Control Panel & Live Feedback**:
   - Tuner toolbar menu features a dynamic **Traffic Light status button** and a **Live Client Overlay Status** feedback card inside `TuningToolbarMenu`.
4. **Peer Network Synchronization**:
   - Live overlay state updates (Status, Custom Text, Opacity Mode, Timer Remaining) serialize to `ALPHAX_OVERLAY:` payloads and sync peer-to-peer over Rust IPC session channels.

---

## 2. Modified Files Summary

| File Path | Description of Changes |
| :--- | :--- |
| `libs/hbb_common/src/config.rs` | Updated default options: `OPTION_VIEW_STYLE` = `"adaptive"` (Scale adaptive) and `OPTION_IMAGE_QUALITY` = `"low"` (Optimize speed). |
| `flutter/lib/desktop/widgets/tuning_overlay.dart` | Updated `TuningOverlayWidget` layout to screenwide (`Positioned(top: 0, left: 0, right: 0)`). Added `toJsonPayload()` & `updateFromJson()` methods to `TuningOverlayController`. |
| `flutter/lib/main.dart` | Mounted `TuningOverlayWidget()` globally inside `GetMaterialApp`'s top-level `builder` so it is active across all client windows (`DesktopTabPage`, `DesktopServerPage` / `--cm`, tray mode). |
| `flutter/lib/desktop/widgets/tuning_toolbar_menu.dart` | Built interactive **Tuner Control Panel** with status buttons (RED, YELLOW, GREEN, OFF), custom message input, opacity chips, timer quick presets, active overlay feedback card, and `_syncToClient()` network broadcast caller. |
| `flutter/lib/desktop/pages/remote_page.dart` | Removed local tuner overlay rendering (`paints.add(const TuningOverlayWidget())`) so tuner views the overlay via the remote display stream. |
| `flutter/lib/models/chat_model.dart` | Added payload interception in `receive()` for `ALPHAX_OVERLAY:` messages to update client `TuningOverlayController` without popping up chat UI. |
| `src/flutter_ffi.rs` | Added `log::info!("[AlphaX Sync] session_send_chat: {}", text);` in `session_send_chat` for disk log output. |
| `src/server/connection.rs` | Added `log::info!("[AlphaX Sync] Received ChatMessage: {}", c.text);` in `ChatMessage` match arm for disk log output. |

---

## 3. Architecture & Data Flow

```
┌────────────────────────────────────────────────────────────────────────┐
│                          TUNER MACHINE (OPERATOR)                      │
│                                                                        │
│   TuningToolbarMenu (Traffic Light Dropdown)                           │
│   ├── User clicks [RED], [YELLOW], [GREEN], or types Custom Message    │
│   ├── TuningOverlayController.instance updates local state             │
│   └── _syncToClient() invokes bind.sessionSendChat(...)               │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
                         Peer Data Network Payload
                "ALPHAX_OVERLAY:{\"status\":\"red\",...}"
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                        CLIENT MACHINE (VEHICLE PC)                     │
│                                                                        │
│   Rust Network Engine & ChatModel.receive()                            │
│   ├── Intercepts payload starting with "ALPHAX_OVERLAY:"               │
│   ├── Calls TuningOverlayController.instance.updateFromJson(data)      │
│   └── Obx() reacts & rebuilds top-level TuningOverlayWidget            │
│                                                                        │
│   GetMaterialApp Builder (Global Stack)                                │
│   └── Screenwide Banner renders top:0, left:0, right:0                 │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Overlay States & Visual Behaviors

### A. Traffic Light Presets
- 🔴 **RED (STOP)**:
  - *Title*: `STOP`
  - *Text*: `"Turn off engine immediately / Wait for instructions."`
  - *Accent*: Bright Red background with 3px solid red bottom border.
- 🟡 **YELLOW (IN PROGRESS)**:
  - *Title*: `TUNING IN PROGRESS`
  - *Text*: `"Do not touch laptop or vehicle controls."`
  - *Accent*: Amber Yellow background with 3px solid yellow bottom border.
- 🟢 **GREEN (TEST RUN READY)**:
  - *Title*: `TEST RUN READY`
  - *Text*: `"Vehicle ready for test run and data logging."`
  - *Accent*: Vibrant Emerald Green background with 3px solid green bottom border.
- 💬 **CUSTOM MESSAGE**:
  - *Title*: `NOTICE`
  - *Text*: Custom tuner-entered broadcast string.

### B. Opacity Modes
- **100% Solid** (`opaque`): Full opacity background banner.
- **30% Banner** (`semiTransparent`): 30% translucent banner allowing underlying ECU software visibility.
- **Hidden** (`hidden`): Temporarily hides overlay banner (`SizedBox.shrink()`).

### C. Session Expiration Lockout Modal
- When countdown timer reaches `00:00:00` or `isSessionExpired` evaluates to `true`, the widget expands into a `Positioned.fill` full-screen dark red lockout overlay stating:
  > **SESSION TIME LIMIT EXPIRED**
  > *Please contact your tuner to request a session extension.*

---

## 5. Verification & Compilation Status

- **Rust Backend**:
  - Verified via `cargo check` -> Exit code `0` (Clean compile).
- **Flutter Frontend**:
  - Verified via `flutter analyze` -> Exit code `0` (0 errors across all modified files).

---

## 6. How to Debug on Client PC (Windows / Linux)

### Stream Logs in PowerShell (Windows)
```powershell
Get-Content "$env:APPDATA\alphaX-desk\log\*.log" -Wait -Tail 50
```

### Stream Logs in Bash (Linux)
```bash
tail -f ~/.local/share/logs/alphaX-desk/*.log
```

### Programmatic State Triggering (DevTools / Console)
```dart
// Test Red Banner
TuningOverlayController.instance.setOverlayState(statusVal: TuningOverlayStatus.red);

// Test Session Expiration Lockout
TuningOverlayController.instance.isSessionExpired.value = true;
```
