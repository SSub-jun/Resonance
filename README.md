# Resonance

> Dark glass layers with subtle purple resonance.

Nearby users resonate when they are listening to the same song or same artist.

## Concept

- **Resonance** = momentary match when two nearby devices are playing the same song (strong signal) or the same artist (subtle signal).
- **Calm · Minimal · Night-focused** — not social-media-like, not gamified.
- Always-on by default. You stop it, not start it.

## Stack

- Swift 5.9+, SwiftUI, iOS 16+
- CoreBluetooth · MediaPlayer · CoreLocation · CoreHaptics · MapKit
- Backend (planned): NestJS + Supabase Postgres

## Status

Phase 1 scaffolding — UI shell only. Services (BLE, MediaPlayer, Location, API) are stubbed with sample data.

### Sample data
Tokyo hip neighborhoods: Shimokitazawa, Shibuya, Harajuku, Nakameguro, Daikanyama, Koenji.

### Scaffolded
- Design tokens (`#0A0A0D` background, `#7C5CFF` accent purple — event-only)
- Dark-only theme enforced at SwiftUI + UIKit layers
- Glass components (subtle `0.05` fill, `0.08` border)
- `ResonanceRipple` — continuous concentric rings around Now Playing when active
- `ResonancePinView` — song = `music.note`, artist = `person.fill`
- Map view with floating detail card on pin tap
- Map / List toggle in the navigation bar
- `ResonanceHaptics` — CoreHaptics parameter curves, fading intensity
- Push notification tap → deep link to selected pin (scaffolded via `DeepLinkRouter` + `NotificationHandler`)

### Not yet wired
- Real `NowPlayingManager` (MediaPlayer)
- Real BLE advertising/scanning
- Real location permissions & capture
- Real backend (NestJS + Supabase)

## Directory

```
Resonance/
├── App/ResonanceApp.swift
├── Theme/DesignTokens.swift
├── Models/
├── Components/
├── ViewModels/
├── Views/
├── Services/
└── Haptics/
```

## Design policy (strict)

- Dark mode only. Light mode explicitly unsupported.
- Purple is a **signal**, never a theme — appears only on resonance events.
- UI text always English. Song / artist names stay in original language.
- CTA is "Stop" / "Resume" — never "Start". Resonance is always on.
- Minimal components, generous spacing, text hierarchy over decoration.
