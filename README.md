<div align="center">

<img src="https://img.shields.io/badge/watchOS-26.0+-5B2D8E?style=for-the-badge" />
<img src="https://img.shields.io/badge/Swift-5.9-F05138?style=for-the-badge&logo=swift&logoColor=white" />
<img src="https://img.shields.io/badge/Supabase-Backend-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" />

<br />
<br />

# LakersHomecourt Watch App

**Stay connected to every Lakers game — right from your wrist.**

Real-time scores, live stats, and push notifications for key game moments, all on your Apple Watch.

<br />

</div>

---

## About the Project

LakersHomecourt is a standalone Apple Watch app built for Lakers fans. It connects to the same Supabase backend as the LakersHomecourt web platform and delivers live game data directly to your wrist — no phone required.

### Built With

- SwiftUI
- WatchKit
- Supabase (PostgreSQL + Realtime + Edge Functions)
- Apple Push Notification service (APNs)
- Deno (Edge Functions runtime)

---

## Features

**Live Game Views**

Three swipeable screens during an active game:

- **Scoreboard** — Real-time score with game clock, quarter indicator, and team logos
- **Field Goal** — Lakers field goal percentage visualized as an animated ring
- **Team Comparison** — Side-by-side stats: rebounds, assists, steals

**Countdown View**

When there is no active game, a countdown timer shows the time remaining until the next Lakers game with the opponent logo and matchup info.

**Push Notifications**

| Notification | Trigger |
|-------------|---------|
| Game started | Q1 begins |
| Q[n] started | Each quarter starts |
| Lakers win / Lakers lose | Game ends with final score |
| Lakers score | Lakers score points |
| Lakers on a run | 5+ consecutive unanswered points |

**Notification Settings**

A dedicated settings screen lets users toggle each notification type individually. Preferences persist across sessions.

---

## Architecture

```
LakersHomecourt Watch App/
├── LakersHomecourtApp.swift            # Entry point + AppDelegate (APNs)
├── ContentView.swift                   # Root view with TabView navigation
├── View/
│   ├── ScoreboardView.swift
│   ├── FieldGoalView.swift
│   ├── TeamComparisonView.swift
│   ├── CountdownView.swift
│   └── NotificationSettingsView.swift
├── ViewModel/
│   └── GameViewModel.swift
├── Models/
│   └── ModelData.swift
├── Service/
│   └── GameService.swift
├── Supabase/
│   └── APIConfig.swift
└── Components/
```

**Pattern:** MVVM with SwiftUI + Supabase Realtime for live updates.

---

## Push Notifications Architecture

```
Apple Watch
    registerForRemoteNotifications()
APNs
    device token saved to Supabase
Database Webhook fires on UPDATE
    send-apns-notification  (game events)
    send-score-notification (score events)
APNs delivers notification to Apple Watch
```

**Edge Functions**

| Function | Trigger | Events |
|----------|---------|--------|
| `send-apns-notification` | UPDATE on `game` | Game start, quarter change, game end |
| `send-score-notification` | UPDATE on `team_player_stats` | Lakers score, Lakers on a run |

---

## Getting Started

### Prerequisites

- Xcode 16+
- Apple Developer Account
- Supabase project

### Installation

**1. Clone the repository**
```bash
git clone https://github.com/GalileaRestrepo/Lakers-Homecourt-WatchOS.git
cd Lakers-Homecourt-WatchOS
```

**2. Configure APNs**

Register an App ID in [Apple Developer Portal](https://developer.apple.com) with Push Notifications capability, create an APNs key with Sandbox & Production environment, download the `.p8` file and place it in `secrets/` (gitignored).

**3. Add Supabase Secrets**

In your Supabase project under Edge Functions > Secrets:

| Secret | Value |
|--------|-------|
| `APNS_KEY_ID` | Your APNs Key ID |
| `APNS_TEAM_ID` | Your Apple Team ID |
| `APNS_BUNDLE_ID` | Your app bundle identifier |
| `APNS_PRIVATE_KEY` | Contents of your `.p8` file |
| `SUPABASE_SERVICE_ROLE_KEY` | Your Supabase service role key |

**4. Grant schema permissions**
```sql
GRANT USAGE ON SCHEMA simulacion_juego TO service_role;
GRANT ALL ON ALL TABLES IN SCHEMA simulacion_juego TO service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA simulacion_juego TO service_role;
```

**5. Deploy Edge Functions**
```bash
supabase functions deploy send-apns-notification --project-ref YOUR_PROJECT_REF
supabase functions deploy send-score-notification --project-ref YOUR_PROJECT_REF
```

**6. Run in Xcode**

Open `LakersHomecourt.xcodeproj`, select the `LakersHomecourt Watch App` target, verify Push Notifications capability is enabled in Signing & Capabilities, connect your iPhone and Apple Watch, and hit Run.

---

## Security

- The `.p8` APNs key lives in `secrets/` which is gitignored
- Only the Supabase `anon` key is bundled in the app (safe for client use)
- The `service_role` key is only used server-side in Edge Functions
- RLS is enabled on `device_tokens_watchos` with `anon` policies

---

## Known Issues

**iOS 26 beta compatibility:** End-to-end push notification testing is blocked on iOS 26 beta due to an Apple bug that generates invalid APNs tokens (`BadDeviceToken`). All backend logic has been verified through Supabase logs. Full testing requires iOS 18 stable or iOS 26 stable (expected September 2026).

---

## Contributors

<table>
  <tr>
    <td align="center">
      <a href="https://github.com/skymalign">
        <img src="https://github.com/skymalign.png" width="80px" style="border-radius: 50%" alt="Cielo Maria Vega Godoy"/>
        <br />
        <sub><b>Cielo Maria Vega Godoy</b></sub>
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/GalileaRestrepo">
        <img src="https://github.com/GalileaRestrepo.png" width="80px" style="border-radius: 50%" alt="Gali"/>
        <br />
        <sub><b>Galilea Restrepo</b></sub>
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/mcgg16">
        <img src="https://github.com/mcgg16.png" width="80px" style="border-radius: 50%" alt="Monica Catalina Guzman"/>
        <br />
        <sub><b>Monica Catalina Guzman</b></sub>
      </a>
    </td>
  </tr>
</table>

---

<div align="center">
  Built by <strong>SharkInov</strong> — Team LakersHomecourt
</div>
