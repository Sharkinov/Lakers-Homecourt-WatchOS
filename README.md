# LakersHomecourt Watch App

> Stay connected to every Lakers game — right from your wrist.

![watchOS](https://img.shields.io/badge/watchOS-26.0+-purple?style=flat-square)
![Swift](https://img.shields.io/badge/Swift-5.9-orange?style=flat-square)
![Supabase](https://img.shields.io/badge/Supabase-Backend-green?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square)

---

## Overview

**LakersHomecourt** is a standalone Apple Watch app for Lakers fans. It displays live game stats, real-time scoreboards, and push notifications for key game moments — all from your wrist.

Built as part of the **LakersHomecourt** fan platform ecosystem, the Watch app connects to the same Supabase backend as the web app.

---

## Features

### Live Game Views
| View | Description |
|------|-------------|
| **Scoreboard** | Real-time score with game clock, quarter, and team logos |
| **Field Goal** | Lakers field goal percentage as an animated ring |
| **Team Comparison** | Side-by-side stats: rebounds, assists, steals |

### Countdown View
When there is no active game, a countdown timer shows the time remaining until the next Lakers game, including the opponent logo and matchup info.

### Push Notifications
Real-time APNs notifications for key game moments:

| Notification | Trigger |
|-------------|---------|
| **Game started** | Q1 begins |
| **Q[n] started** | Each quarter starts |
| **Lakers win / lose** | Game ends with final score |
| **Lakers score** | Lakers score points |
| **Lakers on a run** | 5+ consecutive unanswered points |

### Notification Settings
A dedicated settings screen lets users toggle each notification type individually. Preferences persist across sessions using `@AppStorage`.

---

## Architecture

```
LakersHomecourt Watch App/
├── LakersHomecourtApp.swift            # App entry point + AppDelegate (APNs)
├── ContentView.swift                   # Root view with TabView navigation
├── View/
│   ├── ScoreboardView.swift            # Live score display
│   ├── FieldGoalView.swift             # FG% ring chart
│   ├── TeamComparisonView.swift        # Stats comparison bars
│   ├── CountdownView.swift             # Next game countdown
│   └── NotificationSettingsView.swift  # APNs preferences
├── ViewModel/
│   └── GameViewModel.swift             # Data fetching + Realtime subscriptions
├── Models/
│   └── ModelData.swift                 # Data models
├── Service/
│   └── GameService.swift               # API service layer
├── Supabase/
│   └── APIConfig.swift                 # Supabase configuration
└── Components/
    ├── LoadingView.swift
    ├── ErrorView.swift
    ├── StatBarRow.swift
    └── ...
```

**Pattern:** MVVM with SwiftUI + Supabase Realtime for live updates.

---

## Push Notifications Architecture

```
Apple Watch
    registerForRemoteNotifications()
APNs (Apple Push Notification service)
    device token
Supabase (device_tokens_watchos table)
    webhook trigger
Database Webhook (game_apns_trigger / score_apns_trigger)
    UPDATE on game / team_player_stats
Edge Function (send-apns-notification / send-score-notification)
    APNs API call with JWT
APNs → Apple Watch
```

### Edge Functions
| Function | Trigger | Notifications |
|----------|---------|---------------|
| `send-apns-notification` | UPDATE on `game` table | Game start, quarter change, game end |
| `send-score-notification` | UPDATE on `team_player_stats` | Lakers score, Lakers on a run |

### Supabase Schema
```sql
simulacion_juego.device_tokens_watchos (
  device_token_id  int4  PRIMARY KEY,
  device_token     text  UNIQUE NOT NULL,
  created_at       timestamptz,
  updated_at       timestamptz
)
```

---

## Setup

### Prerequisites
- Xcode 16+
- Apple Developer Account
- Supabase project

### 1. Clone the repository
```bash
git clone https://github.com/your-org/Lakers-Homecourt-WatchOS.git
cd Lakers-Homecourt-WatchOS
```

### 2. Configure APNs

1. Register an App ID in [Apple Developer Portal](https://developer.apple.com) with **Push Notifications** capability
2. Create an APNs key with **Sandbox & Production** environment
3. Download the `.p8` file and place it in `secrets/` (gitignored)

### 3. Configure Supabase Secrets

In your Supabase project under Edge Functions > Secrets, add:

| Secret | Value |
|--------|-------|
| `APNS_KEY_ID` | Your APNs Key ID |
| `APNS_TEAM_ID` | Your Apple Team ID |
| `APNS_BUNDLE_ID` | Your app bundle identifier |
| `APNS_PRIVATE_KEY` | Contents of your `.p8` file |
| `SUPABASE_SERVICE_ROLE_KEY` | Your Supabase service role key |

### 4. Grant schema permissions
```sql
GRANT USAGE ON SCHEMA simulacion_juego TO service_role;
GRANT ALL ON ALL TABLES IN SCHEMA simulacion_juego TO service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA simulacion_juego TO service_role;
```

### 5. Deploy Edge Functions
```bash
supabase functions deploy send-apns-notification --project-ref YOUR_PROJECT_REF
supabase functions deploy send-score-notification --project-ref YOUR_PROJECT_REF
```

### 6. Configure Xcode
1. Open `LakersHomecourt.xcodeproj`
2. Select target `LakersHomecourt Watch App`
3. In **Signing & Capabilities**, set your Team and verify Bundle ID
4. Verify **Push Notifications** capability is enabled

### 7. Run
Connect your iPhone and Apple Watch, select the Watch as run destination in Xcode, and hit Run.

---

## Security

- The `.p8` APNs key is stored in `secrets/` which is gitignored
- Only the Supabase `anon` key is in the app (safe for client-side use)
- The `service_role` key is only used server-side in Edge Functions
- RLS is enabled on `device_tokens_watchos` with policies for the `anon` role

---

## User Stories

| ID | Story |
|----|-------|
| HU-072 | As a fan using Apple Watch, receive push notifications to stay updated on key game moments |
| HU-073 | As a fan using Apple Watch, configure which push notifications to receive |

---

## Known Issues

**iOS 26 beta:** End-to-end testing is blocked on iOS 26 beta due to an Apple bug that generates invalid APNs tokens (`BadDeviceToken`). All backend logic has been verified through Supabase logs. Full testing requires a device running iOS 18 stable or iOS 26 stable (expected September 2026).

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI | SwiftUI |
| Language | Swift 5.9 |
| Platform | watchOS 26.0+ |
| Backend | Supabase (PostgreSQL) |
| Realtime | Supabase Realtime |
| Push Notifications | APNs + Supabase Edge Functions (Deno) |
| Auth | None (standalone watch app) |

---

## Team

Developed by **SharkInov** — Team LakersHomecourt
