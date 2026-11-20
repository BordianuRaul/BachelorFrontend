# AGENTS.md — HabitFinder mobile client

Flutter client for **HabitFinder**, the bachelor's thesis app *"Detecting Habit Triggers: A Mobile App for
Identifying Behavioral Triggers"* (UBB Cluj, June 2025). It is now the base for the master's dissertation
(**HabitFinder 2.0**). The backend is the sibling repo `../Bachelor` (Spring Boot + MySQL, see its AGENTS.md,
which has the full API table).

This file describes the code **as it is** (last commit `9010859`). Update it in the same change when you
alter the structure or the API contract.

## What the app does

1. Log in or register (JWT stored in `flutter_secure_storage`, auto-login on the splash screen).
2. Grant permissions: **Usage Access** (Android special permission), location, and background location.
3. Home menu cards:
   - **Add habit**: name only.
   - **Select habit → habit menu → journal entry**: the form for "before / time / location". **Saving is a
     stub, so nothing is sent to the backend.**
   - **Engrain level (SRHI)**: 12-question Likert form (1–7). The backend returns a text interpretation.
   - **Explore possible habits**: reads per-hour app usage from Android `UsageStatsManager`, uploads it,
     then shows the backend's heuristic messages.
   - **Explore possible triggers**: **a copy of the habits screen** that calls the same endpoint. No trigger
     logic exists on either side yet.

## Stack

| Thing | Value |
|---|---|
| SDK | Dart `^3.5.4`, Flutter (Material) |
| State | `provider` (`ChangeNotifier`), registered globally in `main.dart` |
| Navigation | Named routes via `Routes.generateRoute` (`lib/src/routes/routes.dart`) |
| HTTP | `http` package, no client wrapper or interceptor |
| Native | `MethodChannel('app_usage_channel')` → `android/app/src/main/java/com/example/frontend/MainActivity.java` |
| Other deps | `usage_stats` (permission check only), `installed_apps` (package → display name), `permission_handler`, `android_intent_plus`, `flutter_svg`, `flutter_staggered_grid_view`, `collection` |
| Declared but unused | `location`, `flutter_foreground_task`, `device_info_plus`, `url_launcher` (one broken call) |
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
      models/                     User, Habit, Journal, ApplicationDailyUsage (hand-written fromJson/toJson)
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
(e.g. `--dart-define=API_BASE_URL=...`) rather than editing five files. The traffic is cleartext HTTP, which
works only because the debug build allows it.

## The usage pipeline (the part the thesis is about)

`ExplorePossibleHabitsScreen` / `ExplorePossibleTriggersScreen` → `AppUsageService().transferAppUsageInfo()`:
1. `GET /api/appUsage/lastUpdate` returns the date D (the newest stored date, or today−7).
2. For each day from D to today (inclusive), call `getHourlyAppUsage(start, end)` over the MethodChannel.
3. **Native side** (`MainActivity.getDailyHourlyAppUsage`): walk `UsageEvents`, pair
   `ACTIVITY_RESUMED/MOVE_TO_FOREGROUND` with `ACTIVITY_PAUSED/MOVE_TO_BACKGROUND` per package, and return
   `{package: {"yyyy-MM-dd": [24 ints of seconds]}}`.
4. Resolve package → display name with `InstalledApps.getInstalledApps(true, true)`. This is called **once per
   day in the loop** and is slow. Apps that aren't installed any more are dropped.
5. Category comes from `_getCategoryFromAppName`, which only knows `instagram→Social` and `chrome→Browser`.
   Everything else is `Uncategorized`.
6. `PUT /api/appUsage/bulk` with `ApplicationDailyUsage[]`, then `GET /api/appUsage/findPossibleHabits`.

Measurement caveats to keep in mind (all relevant to the dissertation's data-quality story):
- A whole session is credited to the **hour it started** and the **day it started**. A 40-minute session
  from 21:50 to 22:30 lands entirely in hour 21, and sessions that cross midnight go to the first day.
- A session still open at `end` is dropped, and one already open at `start` is missed.
- Day D and today are re-sent on every sync, and the backend appends them without dedup, so hourly totals
  inflate. The fix belongs on the backend (upsert or bitemporal), but keep it in mind on the client side.
- The device's local time is sent as a bare date (`toIso8601String()` of a local midnight), so the
  timezone is lost.
- Location permission is requested (including background) but **no location is ever collected**.

## State and service gotchas

- Services are singletons that read `AuthService.token` **into a `final` field when the singleton is first
  created** (`AppUsageService`, `HabitService`, `SRHIService`). After logout and login as someone else they
  keep the old token, or `null`. Read `AuthService.token` at call time instead.
- `AuthService.user` / `AuthService.token` are static globals. Providers mostly just forward to them.
- `User` model stores the `password` field because the backend sends the BCrypt hash. Don't extend that.
  Drop the field once the backend stops sending it.
- `ExplorePossibleHabitsProvider` and `ExplorePossibleTriggersProvider` are empty. The latter isn't even
  registered in `main.dart`. The screens call `AppUsageService()` directly.
- `JournalService` (client) has a base URL and nothing else. `JournalEntryProvider.saveEntry()` is empty.
  The backend endpoint `POST /api/journal/addPageToJournal` already exists, so wiring it up is a client-only
  task.
- Status codes are checked exactly: login 200, register 201, addHabit 201, bulk 200 or 202, others 200.
  If the backend changes a code, the client throws.
- Navigation uses `pushReplacementNamed` and `pushNamed`, with `BuildContext` used after `await` in
  `AuthProvider` (lint `use_build_context_synchronously`). Check `context.mounted` in new code.
- `PermissionService.openLocationSettings` passes an Android settings action to `launchUrl`, which doesn't
  work. Use `AndroidIntent`, as `requestUsageAccess` does.

## Conventions when changing code

- New feature = route in `routes.dart` + screen in `screens/` + provider in `providers/` (register it in
  `main.dart` or scope it at the screen as `HabitMenuScreen` does) + HTTP in a `services/` singleton.
- Keep HTTP out of widgets. The explore screens currently break this rule. Don't copy them.
- Hand-written `fromJson`/`toJson` on models. If you add `json_serializable`, convert all the models at
  once, not just one.
- Don't duplicate a screen to make a "new" feature: the triggers screen is the cautionary example.
- When you change anything in the MethodChannel payload shape, change `MainActivity.java` and
  `AppUsageService._getApplicationsDailyUsageForDay` together.

## Contract with the backend

The full table is in `../Bachelor/AGENTS.md`. The client uses: `users/login`, `users/register`,
`users/validateToken`, `users/getHabits`, `users/addHabit`, `SRHI/result`, `appUsage/lastUpdate`,
`appUsage/bulk`, `appUsage/findPossibleHabits`. It does **not** use `users/all` or `journal/addPageToJournal`.
