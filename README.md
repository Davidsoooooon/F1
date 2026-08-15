# F1 2026 Season Hub

A Flutter app for browsing the 2026 Formula 1 season. It includes team and driver profiles, race calendar content, live standings/results from an F1 API, and a prototype merch shop with cart and favorites.

## Features

- Home dashboard with quick access to teams, drivers, calendar, standings, and shop.
- Static 2026 season snapshots backed by bundled data and image assets.
- Live drivers, constructors, race results, and seasons via `f1api.dev`.
- Pull-to-refresh standings with a visible live-data status and static fallback state.
- Shop filters for team, category, favorites, and search.
- Persistent cart and favorites using local device storage.
- Shared app styling helpers for consistent F1 dark cards, light merch cards, and hero gradients.

## Project Structure

- `lib/main.dart` - app shell, navigation, theme setup, and shop state initialization.
- `lib/screens/` - main feature screens and detail pages.
- `lib/widgets/` - reusable cards, buttons, and tables.
- `lib/data/` - static teams, drivers, races, and product data.
- `lib/services/f1_api.dart` - live F1 API client and response models.
- `lib/state/shop_state.dart` - cart/favorites state with persistence.
- `lib/theme/app_theme.dart` - shared colors, decorations, and text helpers.

## Run Locally

```sh
flutter pub get
flutter run
```

## Quality Checks

```sh
flutter analyze
flutter test
```

## Notes

Live sections fall back to bundled snapshot data if the API is unavailable. The shop checkout is currently a prototype action; the cart and wishlist are saved locally so they survive app restarts.
