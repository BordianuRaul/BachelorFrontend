# AGENTS.md — HabitFinder mobile client

Flutter client for **HabitFinder**, the bachelor's thesis app *"Detecting Habit Triggers: A Mobile App for
Identifying Behavioral Triggers"* (UBB Cluj, June 2025). It is now the base for the master's dissertation
(**HabitFinder 2.0**). The backend is the sibling repo `../Bachelor` (Spring Boot + MySQL). Its AGENTS.md has
the full API table (added in Bachelor PR #1, so it's on `main` once that PR is merged).

This file describes the code **as it is** (last commit `9010859`). Update it in the same change when you
alter the structure or the API contract.

## What the app does

1. Log in or register (JWT stored in `flutter_secure_storage`, auto-login on the splash screen).
2. Grant permissions: **Usage Access** (Android special permission), location, and background location.
   Auto-login skips this screen (`splash_screen.dart`).
3. Home has three cards:
   - **Journal** → Select habit → **habit menu**. `SelectHabitScreen` pushes `const HabitMenuScreen()` with
     **no habit argument**, so the selected habit is thrown away and nothing below it knows which habit it's
     about. With zero habits, Select habit shows a spinner forever.
   - **Add habit**: name only.
   - **Find possible habits**: reads per-hour app usage from Android `UsageStatsManager`, uploads it, then
     shows the backend's heuristic messages.
4. The habit menu has three cards:
   - **Journal entry**: the form for "before / time / location". **Saving is a stub, so nothing is sent to
     the backend.**
   - **Engrain level (SRHI)**: 12-question Likert form (1–7). The backend returns a text interpretation.
   - **Explore possible triggers**: **a copy of the habits screen** that calls the same endpoint. No trigger
     logic exists on either side yet.

## Stack

| Thing | Value |
|---|---|
| SDK | Dart `^3.5.4`, Flutter (Material) |
| State | `provider` (`ChangeNotifier`), registered globally in `main.dart` |
| Navigation | Named routes via `Routes.generateRoute` (`lib/src/routes/routes.dart`), but several places push `MaterialPageRoute` directly, so `/selectHabit` and `/habitMenu` are never reached by name |
| HTTP | `http` package, no client wrapper or interceptor |
| Native | `MethodChannel('app_usage_channel')` → `android/app/src/main/java/com/example/frontend/MainActivity.java` |
| Other deps | `usage_stats` (permission check only), `installed_apps` (package → display name), `permission_handler`, `android_intent_plus`, `flutter_staggered_grid_view`, `collection` |
| Declared but unused | `location`, `flutter_foreground_task`, `device_info_plus`, `flutter_svg`, `cupertino_icons`, `url_launcher` (one broken call) |
| Platform | **Android only in practice** (minSdk 23). `ios/` is the template and the usage pipeline has no iOS path. |

## Layout

```
BachelorFrontend/
  frontend/                       <- Flutter project root (run commands from here)
    lib/src/
      main.dart                   MultiProvider + MaterialApp (initialRoute '/splash')
      routes/routes.dart          '/', '/splash', '/grantAccess', '/home', '/selectHabit', '/journalEntry',
                                  '/addHabit', '/habitMenu', '/SRHIForm', '/exploreHabits', '/exploreTriggers'
      screens/                    one file per route
      providers/                  ChangeNotifiers, mostly holding TextEditingControllers
      services/                   singletons that make HTTP calls (auth, habit, srhi, app_usage, journal[empty],
                                  permission, native_app_usage_bridge[unused])
      models/                     User, Habit, Journal, ApplicationDailyUsage (hand-written JSON; Journal has none,
                                  ApplicationDailyUsage only toJson)
      widgets/                    home cards, dialogs, blurred backgrounds, CustomTextField
    android/app/src/main/java/com/example/frontend/MainActivity.java   <- usage-stats aggregation
    test/widget_test.dart         empty main()
```

Note that the code lives under `lib/src/`, so the import root is `package:frontend/src/...` and the entry point
is `lib/src/main.dart`, not `lib/main.dart`.

## Commands

```bash
cd frontend
flutter pub get
flutter run -t lib/src/main.dart        # entry point is not the default lib/main.dart
flutter analyze                          # flutter_lints 4
flutter test                             # currently runs nothing
```

**Backend URL** is hardcoded as `_baseUrl` in each service (`auth_service`, `app_usage_service`,
`habit_service`, `srhi_service`, `journal_service`): `http://192.168.1.219:8080/api/...` for a physical
device. The emulator version (`10.0.2.2`) is commented out next to it. If you need to change it, centralise it
(e.g. `--dart-define=API_BASE_URL=...`) rather than editing five files. The traffic is cleartext HTTP.
That works because `http` uses `dart:io` sockets, which Android's cleartext policy doesn't govern. There's no
`usesCleartextTraffic` or `network_security_config`. The real trap: `android.permission.INTERNET` is declared
only in the `src/debug` and `src/profile` manifests, so **a release APK has no network access at all**. Add it
to `src/main/AndroidManifest.xml` before any release build.

## The usage pipeline (the part the thesis is about)

`ExplorePossibleHabitsScreen` / `ExplorePossibleTriggersScreen` run `AppUsageService().transferAppUsageInfo()` in
`initState`, so **every time either screen opens** it does a full re-sync (steps 1–5 and the `PUT` in step 6).
The screen itself then makes the `GET` in step 6:
1. `GET /api/appUsage/lastUpdate` returns the date D (the newest stored date, or today−7).
2. For each day from D to today (inclusive), call `getHourlyAppUsage(start, end)` over the MethodChannel.
3. **Native side** (`MainActivity.getDailyHourlyAppUsage`): walk `UsageEvents`, pair
   `ACTIVITY_RESUMED/MOVE_TO_FOREGROUND` with `ACTIVITY_PAUSED/MOVE_TO_BACKGROUND` per package, and return
   `{package: {"yyyy-MM-dd": [24 ints of seconds]}}`.
4. Resolve package → display name with `InstalledApps.getInstalledApps(true, true)`. This is called **once per
   day in the loop** and is slow. Apps that aren't installed any more are dropped. In installed_apps 1.6.0
   the signature is `getInstalledApps([excludeSystemApps = true, withIcon = false, ...])`, so `(true, true)`
   also **silently drops preinstalled system apps** (often Chrome, YouTube, Gmail) and loads every icon, which
   is what makes it slow.
5. Category comes from `_getCategoryFromAppName`, which only knows `instagram→Social` and `chrome→Browser`.
   Everything else is `Uncategorized`.
6. `PUT /api/appUsage/bulk` with `ApplicationDailyUsage[]`, then `GET /api/appUsage/findPossibleHabits`.

Measurement caveats to keep in mind (all relevant to the dissertation's data-quality story):
- A whole session is credited to the **hour it started**. A 40-minute session from 21:50 to 22:30 lands
  entirely in hour 21, and a session longer than an hour can push a bucket past 3600 s.
- The client queries **one local day at a time** (00:00 to 23:59:59.999). A session still open at the end is
  dropped, and one already open at the start is missed. So a session that **crosses midnight is lost
  entirely**: it's open at the end of day D and has no start in day D+1.
- Day D and today are re-sent on every sync, and the backend appends them without dedup, so hourly totals
  inflate. The fix belongs on the backend (upsert or bitemporal), but keep it in mind on the client side.
- The date is sent as `toIso8601String()` of a local midnight (`2025-06-01T00:00:00.000`, with no offset),
  and the backend truncates it to a `LocalDate`, so the timezone is lost.
- Location permission is requested (including background) but **no location is ever collected**.

## State and service gotchas

- Services are singletons that read `AuthService.token` **into a `final` field when the singleton is first
  created** (`AppUsageService`, `HabitService`, `SRHIService`). After logout and login as someone else they
  keep the old token, or `null`. Read `AuthService.token` at call time instead. It's **latent today**: there's no
  logout in the UI, and `logout()` only runs when auto-login's `validateToken` fails, before any service
  singleton exists. It becomes a real bug the moment logout is added.
- `AuthService.user` / `AuthService.token` are static globals. Providers mostly just forward to them.
- `User` model stores the `password` field because the backend sends the BCrypt hash. Don't extend that.
  Drop the field once the backend stops sending it.
- `ExplorePossibleHabitsProvider` and `ExplorePossibleTriggersProvider` are empty. The latter isn't even
  registered in `main.dart`. The screens call `AppUsageService()` directly.
- `JournalService` (client) has a base URL and nothing else. `JournalEntryProvider.saveEntry()` is empty.
  The backend endpoint `POST /api/journal/addPageToJournal` already exists, so wiring it up is client-only,
  but not one call: it needs `habitName`, and the journal screen doesn't have it (SelectHabit drops the
  habit). The habit has to be threaded through SelectHabit → HabitMenu → JournalEntry first.
- Status codes are checked exactly: login 200, register 201, addHabit 201, bulk 200 or 202, others 200.
  If the backend changes a code, the client throws, except `validateToken`, which logs out and returns false.
- Navigation uses `pushReplacementNamed` and `pushNamed`, with `BuildContext` used after `await` in
  `AuthProvider` (lint `use_build_context_synchronously`). Check `context.mounted` in new code.
- `PermissionService.openLocationSettings` passes an Android settings action to `launchUrl`, which doesn't
  work. Use `AndroidIntent`, as `requestUsageAccess` does.

## Specs (OpenSpec)

Tasks in SDD mode (criteria in the workspace `../AGENTS.md`: anything a user sees, contracts, design choices,
not just size) are spec-driven. Each one is an OpenSpec change in `openspec/changes/`, archived to
`openspec/changes/archive/` with its delta merged into `openspec/specs/` before the PR opens. **`openspec/specs/`
is the current contract** for the behaviour it covers: read it before you change that behaviour. API contract
changes are specified in the backend repo's `openspec/`; until an endpoint is specified there, the table in
`../Bachelor/AGENTS.md` is the reference. Project constraints are in `openspec/config.yaml`. The
workflow is in the workspace `../AGENTS.md`.

## Conventions when changing code

- New feature = route in `routes.dart` + screen in `screens/` + provider in `providers/` (register it in
  `main.dart` or scope it at the screen; don't copy `HabitMenuScreen`, whose provider is registered both
  globally and at the screen) + HTTP in a `services/` singleton.
- Keep HTTP out of widgets. The explore screens currently break this rule. Don't copy them.
- Hand-written JSON on models. If you add `json_serializable`, convert all the models at
  once, not just one.
- Don't duplicate a screen to make a "new" feature: the triggers screen is the cautionary example.
- `NativeAppUsageBridge` (unused) calls the channel with no arguments and expects a different payload. Don't
  revive it; use `AppUsageService`.
- `android/app/.cxx/` build output and `.idea/workspace.xml` are committed. Don't commit changes to them.
- When you change anything in the MethodChannel payload shape, change `MainActivity.java` and
  `AppUsageService._getApplicationsDailyUsageForDay` together.

## Contract with the backend

The full table is in `../Bachelor/AGENTS.md`. The client uses: `users/login`, `users/register`,
`users/validateToken`, `users/getHabits`, `users/addHabit`, `SRHI/result`, `appUsage/lastUpdate`,
`appUsage/bulk`, `appUsage/findPossibleHabits`. It does **not** use `users/all` or `journal/addPageToJournal`.
