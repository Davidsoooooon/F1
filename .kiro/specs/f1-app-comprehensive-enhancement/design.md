# Technical Design Document: F1 App Comprehensive Enhancement

## Overview

This design specifies the technical implementation for enhancing the F1 2026 Flutter application with comprehensive features across three phases: Foundation (authentication, offline support, testing), Core Features (personalization, notifications, search), and Enhanced Features (shop enhancements, live race data, comparisons, news feed).

### Design Goals

1. **Maintainability**: Extend existing architecture patterns (models, screens, services, widgets, state) without breaking changes
2. **Offline-First**: Support offline access for all cached data with automatic synchronization
3. **Performance**: Meet strict performance targets (UI < 500ms, API < 3s, sync < 5s)
4. **Scalability**: Support growing feature set with clean separation of concerns
5. **Testability**: Comprehensive test coverage (80%+ business logic) across unit, widget, and integration tests

### Technology Stack

- **Framework**: Flutter SDK 3.10.4
- **State Management**: InheritedNotifier pattern (existing), Provider for new features
- **Local Storage**: shared_preferences (simple data), sqflite (structured data), hive (offline cache)
- **Backend**: Firebase (Authentication, Firestore, Cloud Messaging, Cloud Functions)
- **API Integration**: F1API.dev (extended with new endpoints)
- **Testing**: flutter_test, mockito, integration_test
- **Additional Packages**:
  - firebase_auth, google_sign_in, sign_in_with_apple
  - cloud_firestore, firebase_messaging
  - connectivity_plus, http, dio (retry logic)
  - charts_flutter (visualizations)
  - share_plus (social sharing)


## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Presentation Layer                      │
│  ┌─────────────┬──────────────┬──────────────┬────────────┐ │
│  │  Screens    │   Widgets    │  Navigation  │   Theme    │ │
│  └─────────────┴──────────────┴──────────────┴────────────┘ │
└───────────────────────────┬─────────────────────────────────┘
                            │
┌───────────────────────────┴─────────────────────────────────┐
│                      State Management                        │
│  ┌─────────────┬──────────────┬──────────────┬────────────┐ │
│  │  AuthState  │  ShopState   │  FavState    │  NewsState │ │
│  │  SyncState  │  SearchState │  LiveState   │  etc...    │ │
│  └─────────────┴──────────────┴──────────────┴────────────┘ │
└───────────────────────────┬─────────────────────────────────┘
                            │
┌───────────────────────────┴─────────────────────────────────┐
│                      Business Logic Layer                    │
│  ┌─────────────┬──────────────┬──────────────┬────────────┐ │
│  │AuthService  │SearchEngine  │ SyncManager  │ CacheLogic │ │
│  └─────────────┴──────────────┴──────────────┴────────────┘ │
└───────────────────────────┬─────────────────────────────────┘
                            │
┌───────────────────────────┴─────────────────────────────────┐
│                         Data Layer                           │
│  ┌─────────────┬──────────────┬──────────────┬────────────┐ │
│  │ F1ApiClient │FirestoreRepo │ LocalStorage │ CacheStore │ │
│  └─────────────┴──────────────┴──────────────┴────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### Architectural Patterns


1. **Repository Pattern**: Separate data sources (API, Firestore, local) from business logic
2. **State Management**: InheritedNotifier for simple state, Provider for complex reactive state
3. **Service Layer**: Encapsulate external dependencies (Firebase, APIs) behind service interfaces
4. **Offline-First**: Local cache as source of truth, background sync to remote
5. **Error Handling**: Centralized error handling with typed exceptions and user-friendly messages

### Directory Structure Evolution

```
lib/
├── main.dart                       # App entry point
├── data/                           # Static data (existing)
├── models/                         # Data models
│   ├── driver.dart                 # Existing
│   ├── team.dart                   # Existing
│   ├── user.dart                   # NEW: User profile
│   ├── favorite.dart               # NEW: Favorites data
│   ├── news_article.dart           # NEW: News model
│   ├── live_race_data.dart         # NEW: Live race info
│   ├── order.dart                  # NEW: Order history
│   └── review.dart                 # NEW: Product reviews
├── screens/                        # UI screens
│   ├── auth/                       # NEW: Authentication screens
│   ├── profile/                    # NEW: User profile screens
│   ├── favorites/                  # NEW: Favorites screens
│   ├── live/                       # NEW: Live race screens
│   ├── comparison/                 # NEW: Comparison tools
│   ├── news/                       # NEW: News feed screens
│   └── [existing screens...]
├── services/                       # External service wrappers
│   ├── f1_api.dart                 # Extended existing service
│   ├── auth_service.dart           # NEW: Firebase Auth wrapper
│   ├── firestore_service.dart      # NEW: Firestore operations
│   ├── notification_service.dart   # NEW: FCM wrapper
│   ├── storage_service.dart        # NEW: Local storage abstraction
│   └── sync_service.dart           # NEW: Cross-device sync
├── repositories/                   # NEW: Data repositories
│   ├── user_repository.dart
│   ├── favorites_repository.dart
│   ├── news_repository.dart
│   └── race_repository.dart
├── state/                          # State management
│   ├── shop_state.dart             # Existing
│   ├── auth_state.dart             # NEW
│   ├── favorites_state.dart        # NEW
│   ├── search_state.dart           # NEW
│   └── news_state.dart             # NEW
├── widgets/                        # Reusable widgets
├── theme/                          # Theming
└── utils/                          # NEW: Utilities
    ├── error_handler.dart
    ├── connectivity_manager.dart
    └── cache_manager.dart
```


## Components and Interfaces

### PHASE 1: Foundation Components

#### 1.1 Authentication System

**AuthService Interface**
```dart
abstract class AuthService {
  // Email/Password authentication
  Future<User> signUpWithEmail(String email, String password);
  Future<User> signInWithEmail(String email, String password);
  Future<void> signOut();
  Future<void> resetPassword(String email);

  // Social authentication
  Future<User> signInWithGoogle();
  Future<User> signInWithApple();

  // State management
  Stream<User?> get authStateChanges;
  User? get currentUser;
}
```

**Implementation Details**:
- Use firebase_auth for backend
- Store auth tokens securely using flutter_secure_storage
- Implement token refresh logic (background)
- Handle auth state persistence across app restarts
- Support biometric authentication for returning users (future enhancement)

**Error Handling**:
```dart
class AuthException implements Exception {
  final AuthErrorType type;
  final String message;

  String get userMessage {
    switch (type) {
      case AuthErrorType.emailInUse: return 'Email already registered';
      case AuthErrorType.invalidEmail: return 'Invalid email format';
      case AuthErrorType.weakPassword: return 'Password too weak (min 8 chars)';
      case AuthErrorType.wrongPassword: return 'Invalid credentials';
      case AuthErrorType.userNotFound: return 'Account not found';
      case AuthErrorType.networkError: return 'Network error, please retry';
      default: return 'Authentication failed';
    }
  }
}
```


#### 1.2 Profile Management System

**UserProfile Model**
```dart
class UserProfile {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final AuthProvider provider;
  final UserPreferences preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory UserProfile.fromFirestore(DocumentSnapshot doc);
  Map<String, dynamic> toFirestore();
}

class UserPreferences {
  final Set<String> favoriteDriverIds;
  final Set<String> favoriteTeamIds;
  final NotificationSettings notifications;

  Map<String, dynamic> toJson();
  factory UserPreferences.fromJson(Map<String, dynamic> json);
}

class NotificationSettings {
  final bool raceReminders;
  final bool qualifyingReminders;
  final bool favoriteUpdates;
  final bool newsUpdates;
  final bool raceIncidents;
}
```

**ProfileService Interface**
```dart
abstract class ProfileService {
  Future<UserProfile> getProfile(String uid);
  Future<void> updateProfile(String uid, Map<String, dynamic> updates);
  Future<void> updatePreferences(String uid, UserPreferences prefs);
  Stream<UserProfile> watchProfile(String uid);
}
```


#### 1.3 Cross-Device Synchronization System

**SyncService Architecture**

The sync system uses a queue-based approach with conflict resolution:

```dart
class SyncService {
  final FirestoreService _firestore;
  final LocalStorageService _localStorage;
  final ConnectivityManager _connectivity;

  // Sync queue for offline operations
  final Queue<SyncOperation> _syncQueue = Queue();

  Future<void> syncUserData(String uid) async {
    if (!await _connectivity.isOnline) {
      return; // Queue will be processed when online
    }

    // Fetch remote data
    final remoteData = await _firestore.getUserData(uid);
    final localData = await _localStorage.getUserData(uid);

    // Resolve conflicts using last-write-wins
    final merged = _resolveConflicts(localData, remoteData);

    // Update both stores
    await Future.wait([
      _firestore.updateUserData(uid, merged),
      _localStorage.saveUserData(uid, merged),
    ]);
  }

  void queueSyncOperation(SyncOperation op) {
    _syncQueue.add(op);
    _processSyncQueue();
  }

  Future<void> _processSyncQueue() async {
    while (_syncQueue.isNotEmpty && await _connectivity.isOnline) {
      final op = _syncQueue.removeFirst();
      await _executeSyncOperation(op);
    }
  }

  Map<String, dynamic> _resolveConflicts(
    LocalUserData local,
    RemoteUserData remote,
  ) {
    // Last-write-wins strategy
    return local.updatedAt.isAfter(remote.updatedAt)
      ? local.toMap()
      : remote.toMap();
  }
}

class SyncOperation {
  final SyncType type;
  final String userId;
  final Map<String, dynamic> data;
  final DateTime timestamp;
}

enum SyncType { favorites, preferences, wishlist, savedArticles }
```

**Sync Triggers**:
1. User modifies favorites → Queue sync operation
2. Network connectivity restored → Process queued operations
3. App foreground → Sync check (if last sync > 5 minutes ago)
4. Background sync (periodic, every 30 minutes when online)


#### 1.4 Error Handling System

**Centralized Error Handler**

```dart
class AppErrorHandler {
  static void handleError(Object error, StackTrace? stackTrace) {
    if (error is AppException) {
      _handleAppException(error);
    } else if (error is FirebaseException) {
      _handleFirebaseException(error);
    } else if (error is DioException) {
      _handleNetworkException(error);
    } else {
      _handleUnknownError(error, stackTrace);
    }
  }

  static void _handleAppException(AppException e) {
    switch (e.type) {
      case AppExceptionType.auth:
        _showErrorSnackbar(e.userMessage);
        break;
      case AppExceptionType.network:
        _showRetryableError(e.userMessage, e.retryAction);
        break;
      case AppExceptionType.validation:
        _showValidationError(e.userMessage);
        break;
    }
  }
}

// HTTP Status Code Mapping
class ApiErrorHandler {
  static AppException fromStatusCode(int statusCode, String? message) {
    switch (statusCode) {
      case 400: return ValidationException('Invalid request');
      case 401: return AuthException.unauthorized();
      case 403: return AuthException.accessDenied();
      case 404: return NotFoundException('Resource not found');
      case 500: return ServerException('Server error, please try again');
      case 503: return ServiceUnavailableException('Service temporarily unavailable');
      default: return UnknownException('Request failed');
    }
  }
}
```

**Error Logging**

```dart
class ErrorLogger {
  static void log(Object error, StackTrace? stackTrace, {
    Map<String, dynamic>? context,
  }) {
    final entry = ErrorLogEntry(
      error: error.toString(),
      stackTrace: stackTrace?.toString(),
      timestamp: DateTime.now(),
      context: context,
    );

    // Log to local storage
    _localStorage.appendErrorLog(entry);

    // Report to crash analytics (Firebase Crashlytics)
    if (error is! AppException || error.shouldReport) {
      _crashlytics.recordError(error, stackTrace);
    }
  }
}
```


#### 1.5 Loading States and Feedback

**LoadingState Pattern**

```dart
enum LoadingState { idle, loading, success, error }

class AsyncValue<T> {
  final LoadingState state;
  final T? data;
  final Object? error;

  bool get isLoading => state == LoadingState.loading;
  bool get hasData => data != null;
  bool get hasError => error != null;

  AsyncValue.loading() : state = LoadingState.loading, data = null, error = null;
  AsyncValue.success(T value) : state = LoadingState.success, data = value, error = null;
  AsyncValue.error(Object err) : state = LoadingState.error, data = null, error = err;
}

// Usage in state classes
class DriversState extends ChangeNotifier {
  AsyncValue<List<Driver>> _drivers = AsyncValue.loading();

  AsyncValue<List<Driver>> get drivers => _drivers;

  Future<void> loadDrivers() async {
    _drivers = AsyncValue.loading();
    notifyListeners();

    try {
      final data = await _api.fetchDrivers();
      _drivers = AsyncValue.success(data);
    } catch (e) {
      _drivers = AsyncValue.error(e);
    }
    notifyListeners();
  }
}
```

**UI Loading Components**

```dart
class LoadingStateBuilder<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final Widget Function()? loadingBuilder;
  final Widget Function(Object error)? errorBuilder;

  @override
  Widget build(BuildContext context) {
    if (value.isLoading) {
      return loadingBuilder?.call() ?? _defaultLoadingWidget();
    }
    if (value.hasError) {
      return errorBuilder?.call(value.error!) ?? _defaultErrorWidget(value.error!);
    }
    if (value.hasData) {
      return builder(value.data!);
    }
    return SizedBox.shrink();
  }

  Widget _defaultLoadingWidget() => SkeletonLoader();
  Widget _defaultErrorWidget(Object error) => ErrorDisplay(error);
}

// Skeleton loaders for different content types
class SkeletonLoader extends StatelessWidget {
  final SkeletonType type;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case SkeletonType.list:
        return ListView.builder(
          itemCount: 5,
          itemBuilder: (_, __) => SkeletonCard(),
        );
      case SkeletonType.grid:
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemCount: 6,
          itemBuilder: (_, __) => SkeletonCard(),
        );
    }
  }
}
```


#### 1.6 Offline Caching System

**Multi-Layer Cache Architecture**

```dart
class CacheManager {
  final HiveInterface _hive;
  final SharedPreferences _prefs;

  // Cache layers
  static const int MAX_CACHE_SIZE_MB = 50;
  static const Duration CACHE_EXPIRY = Duration(hours: 24);

  // Cache boxes (Hive)
  late Box<CachedDriver> _driversBox;
  late Box<CachedTeam> _teamsBox;
  late Box<CachedRace> _racesBox;
  late Box<CachedStanding> _standingsBox;

  Future<void> initialize() async {
    await Hive.initFlutter();
    _driversBox = await Hive.openBox<CachedDriver>('drivers');
    _teamsBox = await Hive.openBox<CachedTeam>('teams');
    _racesBox = await Hive.openBox<CachedRace>('races');
    _standingsBox = await Hive.openBox<CachedStanding>('standings');
  }

  Future<void> cacheDrivers(List<Driver> drivers) async {
    final cached = drivers.map((d) => CachedDriver(
      data: d,
      cachedAt: DateTime.now(),
    )).toList();

    await _driversBox.clear();
    await _driversBox.addAll(cached);
    await _checkCacheSize();
  }

  Future<List<Driver>?> getCachedDrivers() async {
    if (_driversBox.isEmpty) return null;

    final cached = _driversBox.values.toList();
    final isExpired = DateTime.now().difference(cached.first.cachedAt) > CACHE_EXPIRY;

    return isExpired ? null : cached.map((c) => c.data).toList();
  }

  Future<void> _checkCacheSize() async {
    final sizeBytes = await _calculateCacheSize();
    final sizeMB = sizeBytes / (1024 * 1024);

    if (sizeMB > MAX_CACHE_SIZE_MB) {
      await _evictOldestEntries();
    }
  }

  Future<void> _evictOldestEntries() async {
    // LRU eviction: remove oldest cached items
    final allBoxes = [_driversBox, _teamsBox, _racesBox, _standingsBox];

    for (final box in allBoxes) {
      final entries = box.values.toList()
        ..sort((a, b) => a.cachedAt.compareTo(b.cachedAt));

      final toRemove = (entries.length * 0.2).ceil(); // Remove 20%
      for (var i = 0; i < toRemove; i++) {
        await box.delete(entries[i].key);
      }
    }
  }
}

@HiveType(typeId: 0)
class CachedDriver extends HiveObject {
  @HiveField(0)
  final Driver data;

  @HiveField(1)
  final DateTime cachedAt;
}
```


#### 1.7 Network Connectivity Detection

**ConnectivityManager**

```dart
class ConnectivityManager {
  final Connectivity _connectivity;
  final StreamController<ConnectionState> _stateController;

  Stream<ConnectionState> get connectionStream => _stateController.stream;
  ConnectionState _currentState = ConnectionState.unknown;

  ConnectionState get currentState => _currentState;
  bool get isOnline => _currentState == ConnectionState.online;

  void initialize() {
    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((result) {
      _updateConnectionState(result);
    });

    // Initial state check
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionState(result);
  }

  void _updateConnectionState(ConnectivityResult result) {
    final newState = _mapToConnectionState(result);

    if (newState != _currentState) {
      _currentState = newState;
      _stateController.add(newState);

      // Trigger sync when coming back online
      if (newState == ConnectionState.online) {
        _onBackOnline();
      }
    }
  }

  ConnectionState _mapToConnectionState(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
        return ConnectionState.online;
      case ConnectivityResult.none:
        return ConnectionState.offline;
      default:
        return ConnectionState.unknown;
    }
  }

  Future<void> _onBackOnline() async {
    // Trigger background sync
    await GetIt.I<SyncService>().syncAll();

    // Refresh stale cache
    await GetIt.I<CacheManager>().refreshExpiredCache();
  }
}

// UI Integration
class ConnectivityBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectionState>(
      stream: GetIt.I<ConnectivityManager>().connectionStream,
      builder: (context, snapshot) {
        if (snapshot.data == ConnectionState.offline) {
          return MaterialBanner(
            content: Text('You are offline. Some features unavailable.'),
            actions: [TextButton(onPressed: () {}, child: Text('OK'))],
            backgroundColor: Colors.orange,
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}
```


### PHASE 2: Core Features Components

#### 2.1 Favorites Management System

**FavoritesRepository**

```dart
class FavoritesRepository {
  final FirestoreService _firestore;
  final LocalStorageService _localStorage;
  final SyncService _sync;

  // In-memory cache for fast access
  final Set<String> _favoriteDriverIds = {};
  final Set<String> _favoriteTeamIds = {};

  Future<void> loadFavorites(String userId) async {
    // Try local first
    final local = await _localStorage.getFavorites(userId);
    if (local != null) {
      _favoriteDriverIds.addAll(local.driverIds);
      _favoriteTeamIds.addAll(local.teamIds);
    }

    // Sync with remote in background
    _syncFavorites(userId);
  }

  Future<void> toggleDriverFavorite(String userId, String driverId) async {
    if (_favoriteDriverIds.contains(driverId)) {
      _favoriteDriverIds.remove(driverId);
    } else {
      if (_favoriteDriverIds.length >= 20) {
        throw FavoritesLimitException('Maximum 20 drivers');
      }
      _favoriteDriverIds.add(driverId);
    }

    // Save locally immediately
    await _localStorage.saveFavorites(userId, Favorites(
      driverIds: _favoriteDriverIds,
      teamIds: _favoriteTeamIds,
    ));

    // Queue remote sync
    _sync.queueSyncOperation(SyncOperation(
      type: SyncType.favorites,
      userId: userId,
      data: {'favoriteDrivers': _favoriteDriverIds.toList()},
      timestamp: DateTime.now(),
    ));
  }

  bool isDriverFavorite(String driverId) => _favoriteDriverIds.contains(driverId);
  bool isTeamFavorite(String teamId) => _favoriteTeamIds.contains(teamId);

  List<String> get favoriteDriverIds => _favoriteDriverIds.toList();
  List<String> get favoriteTeamIds => _favoriteTeamIds.toList();
}
```

**FavoritesState (UI State Management)**

```dart
class FavoritesState extends ChangeNotifier {
  final FavoritesRepository _repository;
  final AuthService _auth;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  Future<void> load() async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _repository.loadFavorites(userId);
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> toggleDriver(String driverId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw UnauthenticatedException();

    await _repository.toggleDriverFavorite(userId, driverId);
    notifyListeners();
  }

  bool isDriverFavorite(String driverId) {
    return _repository.isDriverFavorite(driverId);
  }

  List<Driver> getFavoriteDrivers(List<Driver> allDrivers) {
    return allDrivers
      .where((d) => _repository.isDriverFavorite(d.id))
      .toList()
      ..sort((a, b) => a.position.compareTo(b.position));
  }
}
```


#### 2.2 Personalized Home Screen

**HomeScreenStrategy Pattern**

```dart
abstract class HomeContentStrategy {
  List<HomeSection> buildSections(HomeContext context);
}

class PersonalizedHomeStrategy implements HomeContentStrategy {
  @override
  List<HomeSection> buildSections(HomeContext context) {
    final sections = <HomeSection>[];

    // Favorite drivers section (if user has favorites)
    if (context.favoriteDrivers.isNotEmpty) {
      sections.add(FavoriteDriversSection(
        drivers: context.favoriteDrivers,
        standings: context.driverStandings,
      ));
    }

    // Favorite teams section
    if (context.favoriteTeams.isNotEmpty) {
      sections.add(FavoriteTeamsSection(
        teams: context.favoriteTeams,
        standings: context.teamStandings,
      ));
    }

    // Latest race results (filtered for favorites)
    if (context.latestRace != null) {
      sections.add(LatestRaceSection(
        race: context.latestRace!,
        highlightDrivers: context.favoriteDrivers.map((d) => d.id).toSet(),
      ));
    }

    // Next race
    sections.add(NextRaceSection(nextRace: context.nextRace));

    // General standings (non-personalized)
    sections.add(StandingsSection(
      driverStandings: context.driverStandings,
      teamStandings: context.teamStandings,
    ));

    return sections;
  }
}

class DefaultHomeStrategy implements HomeContentStrategy {
  @override
  List<HomeSection> buildSections(HomeContext context) {
    return [
      LatestRaceSection(race: context.latestRace),
      NextRaceSection(nextRace: context.nextRace),
      StandingsSection(
        driverStandings: context.driverStandings,
        teamStandings: context.teamStandings,
      ),
    ];
  }
}

class HomeContext {
  final List<Driver> favoriteDrivers;
  final List<Team> favoriteTeams;
  final List<DriverStanding> driverStandings;
  final List<TeamStanding> teamStandings;
  final Race? latestRace;
  final Race? nextRace;
}
```


#### 2.3 Push Notification System

**NotificationService Architecture**

```dart
class NotificationService {
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final FirestoreService _firestore;

  Future<void> initialize() async {
    // Request permissions
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get FCM token
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveToken(token);
      }

      // Listen to token refresh
      _messaging.onTokenRefresh.listen(_saveToken);

      // Setup message handlers
      _setupMessageHandlers();
    }
  }

  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background messages (app opened from notification)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Terminated state (app opened from notification)
    _messaging.getInitialMessage().then((message) {
      if (message != null) _handleNotificationTap(message);
    });
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    // Show local notification when app is in foreground
    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      _getNotificationDetails(message.data['type']),
      payload: jsonEncode(message.data),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    final type = message.data['type'] as String?;
    final payload = message.data;

    switch (type) {
      case 'race_reminder':
        _navigateToRaceDetails(payload['raceId']);
        break;
      case 'favorite_podium':
        _navigateToDriverProfile(payload['driverId']);
        break;
      case 'race_incident':
        _navigateToLiveRace(payload['raceId']);
        break;
      case 'news':
        _navigateToArticle(payload['articleId']);
        break;
    }
  }

  Future<void> updatePreferences(
    String userId,
    NotificationSettings settings,
  ) async {
    await _firestore.updateUserNotificationSettings(userId, settings);

    // Subscribe/unsubscribe from FCM topics
    if (settings.raceReminders) {
      await _messaging.subscribeToTopic('race_reminders');
    } else {
      await _messaging.unsubscribeFromTopic('race_reminders');
    }

    // Repeat for other topics...
  }
}
```

**Notification Scheduling (Cloud Functions)**

```typescript
// Firebase Cloud Function for scheduling notifications
export const scheduleRaceNotifications = functions.pubsub
  .schedule('every 1 hours')
  .onRun(async (context) => {
    const races = await getRacesInNext24Hours();

    for (const race of races) {
      // 24-hour reminder
      if (isWithin24Hours(race.startTime)) {
        await sendNotificationToTopic('race_reminders', {
          title: `Race Tomorrow: ${race.name}`,
          body: `${race.circuit} - ${formatTime(race.startTime)}`,
          data: { type: 'race_reminder', raceId: race.id },
        });
      }

      // 1-hour reminder
      if (isWithin1Hour(race.startTime)) {
        await sendNotificationToTopic('race_reminders', {
          title: `Race Starting Soon: ${race.name}`,
          body: `Starting in 1 hour`,
          data: { type: 'race_reminder', raceId: race.id },
        });
      }
    }
  });
```


#### 2.4 Global Search System

**SearchEngine Implementation**

```dart
class SearchEngine {
  final F1ApiService _api;
  final CacheManager _cache;

  // In-memory search index
  late SearchIndex _index;

  Future<void> buildIndex() async {
    final drivers = await _api.fetchDrivers();
    final teams = await _api.fetchTeams();
    final races = await _api.fetchSeasons(); // Includes races
    final products = productsData;

    _index = SearchIndex()
      ..addDrivers(drivers)
      ..addTeams(teams)
      ..addRaces(races)
      ..addProducts(products);
  }

  Future<SearchResults> search(String query) async {
    if (query.isEmpty) return SearchResults.empty();

    final normalized = _normalizeQuery(query);

    return SearchResults(
      drivers: _index.searchDrivers(normalized),
      teams: _index.searchTeams(normalized),
      races: _index.searchRaces(normalized),
      products: _index.searchProducts(normalized),
    );
  }

  String _normalizeQuery(String query) {
    return query.toLowerCase().trim();
  }
}

class SearchIndex {
  final Map<String, Driver> _drivers = {};
  final Map<String, Team> _teams = {};
  final Map<String, Race> _races = {};
  final Map<String, Product> _products = {};

  // Inverted index for fast lookup
  final Map<String, Set<String>> _driverIndex = {};
  final Map<String, Set<String>> _teamIndex = {};
  final Map<String, Set<String>> _raceIndex = {};
  final Map<String, Set<String>> _productIndex = {};

  void addDrivers(List<Driver> drivers) {
    for (final driver in drivers) {
      _drivers[driver.id] = driver;
      _indexTerms(driver.fullName, driver.id, _driverIndex);
      _indexTerms(driver.nationality, driver.id, _driverIndex);
    }
  }

  void _indexTerms(String text, String id, Map<String, Set<String>> index) {
    final terms = text.toLowerCase().split(' ');
    for (final term in terms) {
      if (term.length >= 2) { // Min 2 chars
        index.putIfAbsent(term, () => {}).add(id);

        // Add prefixes for autocomplete
        for (var i = 2; i <= term.length; i++) {
          final prefix = term.substring(0, i);
          index.putIfAbsent(prefix, () => {}).add(id);
        }
      }
    }
  }

  List<Driver> searchDrivers(String query) {
    final terms = query.split(' ');
    final matchedIds = _findMatches(terms, _driverIndex);

    return matchedIds
      .map((id) => _drivers[id])
      .whereType<Driver>()
      .toList()
      ..sort((a, b) => _scoreMatch(query, a.fullName)
          .compareTo(_scoreMatch(query, b.fullName)));
  }

  Set<String> _findMatches(List<String> terms, Map<String, Set<String>> index) {
    if (terms.isEmpty) return {};

    Set<String>? result;
    for (final term in terms) {
      final matches = index[term] ?? {};
      result = result == null ? matches : result.intersection(matches);
    }
    return result ?? {};
  }

  int _scoreMatch(String query, String text) {
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    // Exact match = highest score
    if (lowerText == lowerQuery) return 0;

    // Starts with = high score
    if (lowerText.startsWith(lowerQuery)) return 1;

    // Contains = medium score
    if (lowerText.contains(lowerQuery)) return 2;

    // Otherwise, score by position
    return lowerText.indexOf(lowerQuery);
  }
}
```


**Search History Management**

```dart
class SearchHistoryManager {
  final SharedPreferences _prefs;
  static const _key = 'search_history';
  static const _maxHistory = 20;

  List<String> getHistory() {
    return _prefs.getStringList(_key) ?? [];
  }

  Future<void> addQuery(String query) async {
    final history = getHistory();

    // Remove if exists (to move to front)
    history.remove(query);

    // Add to front
    history.insert(0, query);

    // Limit size
    if (history.length > _maxHistory) {
      history.removeRange(_maxHistory, history.length);
    }

    await _prefs.setStringList(_key, history);
  }

  Future<void> clearHistory() async {
    await _prefs.remove(_key);
  }
}

// Autocomplete suggestions
class AutocompleteProvider {
  final SearchIndex _index;

  List<String> getSuggestions(String query) {
    if (query.length < 2) return [];

    final drivers = _index.searchDrivers(query).take(2);
    final teams = _index.searchTeams(query).take(2);
    final races = _index.searchRaces(query).take(1);

    final suggestions = <String>[
      ...drivers.map((d) => d.fullName),
      ...teams.map((t) => t.name),
      ...races.map((r) => r.name),
    ];

    return suggestions.take(5).toList();
  }
}
```


#### 2.5 Advanced Filtering System

**FilterEngine Architecture**

```dart
abstract class Filter<T> {
  bool apply(T item);
  Filter<T> and(Filter<T> other);
  Filter<T> or(Filter<T> other);
}

class DriverFilter implements Filter<Driver> {
  final Set<String>? teamIds;
  final Set<String>? nationalities;

  @override
  bool apply(Driver driver) {
    if (teamIds != null && !teamIds.contains(driver.teamId)) {
      return false;
    }
    if (nationalities != null && !nationalities.contains(driver.nationality)) {
      return false;
    }
    return true;
  }

  @override
  Filter<Driver> and(Filter<Driver> other) => CompositeFilter([this, other]);
}

class ProductFilter implements Filter<Product> {
  final Set<String>? teamIds;
  final Set<String>? categories;
  final PriceRange? priceRange;

  @override
  bool apply(Product product) {
    if (teamIds != null && !teamIds.contains(product.teamId)) {
      return false;
    }
    if (categories != null && !categories.contains(product.category)) {
      return false;
    }
    if (priceRange != null &&
        (product.price < priceRange.min || product.price > priceRange.max)) {
      return false;
    }
    return true;
  }
}

class FilterState extends ChangeNotifier {
  DriverFilter? _driverFilter;
  ProductFilter? _productFilter;

  void setDriverFilter({Set<String>? teamIds, Set<String>? nationalities}) {
    _driverFilter = DriverFilter(
      teamIds: teamIds,
      nationalities: nationalities,
    );
    notifyListeners();
  }

  void clearDriverFilter() {
    _driverFilter = null;
    notifyListeners();
  }

  List<Driver> applyDriverFilter(List<Driver> drivers) {
    if (_driverFilter == null) return drivers;
    return drivers.where(_driverFilter!.apply).toList();
  }

  int getDriverFilteredCount(List<Driver> drivers) {
    return applyDriverFilter(drivers).length;
  }
}
```


### PHASE 3: Enhanced Features Components

#### 3.1 Enhanced Shop System

**Wishlist Management**

```dart
class WishlistRepository {
  final FirestoreService _firestore;
  final LocalStorageService _localStorage;

  final Set<String> _wishlistProductIds = {};

  Future<void> loadWishlist(String userId) async {
    final local = await _localStorage.getWishlist(userId);
    if (local != null) {
      _wishlistProductIds.addAll(local);
    }

    // Background sync
    _syncWishlist(userId);
  }

  Future<void> toggleWishlist(String userId, String productId) async {
    if (_wishlistProductIds.contains(productId)) {
      _wishlistProductIds.remove(productId);
    } else {
      if (_wishlistProductIds.length >= 50) {
        throw WishlistLimitException('Maximum 50 products');
      }
      _wishlistProductIds.add(productId);
    }

    await _localStorage.saveWishlist(userId, _wishlistProductIds);
    _syncToFirestore(userId);
  }

  bool isInWishlist(String productId) => _wishlistProductIds.contains(productId);

  List<Product> getWishlistProducts(List<Product> allProducts) {
    return allProducts
      .where((p) => _wishlistProductIds.contains(p.id))
      .toList();
  }
}
```

**Order History System**

```dart
class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double total;
  final OrderStatus status;
  final DateTime orderDate;
  final ShippingAddress shippingAddress;
  final PaymentMethod paymentMethod;

  Map<String, dynamic> toFirestore();
  factory Order.fromFirestore(DocumentSnapshot doc);
}

enum OrderStatus { pending, confirmed, shipped, delivered, cancelled }

class OrderRepository {
  final FirestoreService _firestore;

  Future<List<Order>> getOrderHistory(String userId) async {
    final snapshot = await _firestore
      .collection('orders')
      .where('userId', isEqualTo: userId)
      .orderBy('orderDate', descending: true)
      .get();

    return snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList();
  }

  Future<Order> getOrderDetails(String orderId) async {
    final doc = await _firestore.collection('orders').doc(orderId).get();
    return Order.fromFirestore(doc);
  }

  Future<void> reorder(String userId, Order order) async {
    // Add all items from order to cart
    final cartService = GetIt.I<ShopState>();
    for (final item in order.items) {
      for (var i = 0; i < item.quantity; i++) {
        cartService.addToCart(item.product);
      }
    }
  }
}
```


**Product Reviews System**

```dart
class Review {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final int rating; // 1-5
  final String text;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toFirestore();
  factory Review.fromFirestore(DocumentSnapshot doc);
}

class ReviewRepository {
  final FirestoreService _firestore;

  Future<List<Review>> getProductReviews(String productId) async {
    final snapshot = await _firestore
      .collection('reviews')
      .where('productId', isEqualTo: productId)
      .orderBy('createdAt', descending: true)
      .get();

    return snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList();
  }

  Future<ReviewStats> getReviewStats(String productId) async {
    final reviews = await getProductReviews(productId);

    if (reviews.isEmpty) {
      return ReviewStats(averageRating: 0, totalReviews: 0);
    }

    final totalRating = reviews.fold<int>(0, (sum, r) => sum + r.rating);
    final average = totalRating / reviews.length;

    return ReviewStats(
      averageRating: average,
      totalReviews: reviews.length,
      ratingDistribution: _calculateDistribution(reviews),
    );
  }

  Map<int, int> _calculateDistribution(List<Review> reviews) {
    final dist = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final review in reviews) {
      dist[review.rating] = (dist[review.rating] ?? 0) + 1;
    }
    return dist;
  }

  Future<void> submitReview({
    required String productId,
    required String userId,
    required String userName,
    required int rating,
    required String text,
  }) async {
    if (rating < 1 || rating > 5) {
      throw ValidationException('Rating must be 1-5');
    }
    if (text.length < 10) {
      throw ValidationException('Review must be at least 10 characters');
    }
    if (text.length > 500) {
      throw ValidationException('Review must be at most 500 characters');
    }

    await _firestore.collection('reviews').add({
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
```


**Payment Processing System**

```dart
class PaymentService {
  final StripePaymentService _stripe;
  final ApplePayService _applePay;
  final GooglePayService _googlePay;

  Future<PaymentResult> processPayment({
    required PaymentMethod method,
    required double amount,
    required Order order,
  }) async {
    switch (method.type) {
      case PaymentMethodType.card:
        return await _stripe.processCardPayment(
          amount: amount,
          cardToken: method.cardToken!,
          orderId: order.id,
        );

      case PaymentMethodType.applePay:
        if (!await _applePay.isAvailable()) {
          throw PaymentException('Apple Pay not available');
        }
        return await _applePay.processPayment(amount, order);

      case PaymentMethodType.googlePay:
        if (!await _googlePay.isAvailable()) {
          throw PaymentException('Google Pay not available');
        }
        return await _googlePay.processPayment(amount, order);
    }
  }

  Future<void> savePaymentMethod(
    String userId,
    PaymentMethod method,
  ) async {
    // Save tokenized payment method (never store raw card data)
    await _firestore.collection('users/$userId/payment_methods').add({
      'type': method.type.name,
      'token': method.token,
      'lastFour': method.lastFour,
      'brand': method.brand,
      'expiryMonth': method.expiryMonth,
      'expiryYear': method.expiryYear,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  bool _validateCardNumber(String cardNumber) {
    // Luhn algorithm
    final digits = cardNumber.replaceAll(' ', '').split('').map(int.parse);
    var sum = 0;
    var alternate = false;

    for (var i = digits.length - 1; i >= 0; i--) {
      var digit = digits[i];
      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  bool _validateExpiry(int month, int year) {
    final now = DateTime.now();
    final expiryDate = DateTime(year, month + 1, 0); // Last day of month
    return expiryDate.isAfter(now);
  }
}
```


#### 3.2 Live Race System

**Live Race Data Models**

```dart
class LiveRaceData {
  final String raceId;
  final RaceStatus status;
  final int currentLap;
  final int totalLaps;
  final List<LiveDriverPosition> positions;
  final List<CommentaryEntry> commentary;
  final List<RaceIncident> incidents;
  final DateTime lastUpdated;
}

class LiveDriverPosition {
  final String driverId;
  final String driverName;
  final String teamId;
  final int position;
  final int startPosition;
  final String lapTime;
  final List<SectorTime> sectors;
  final String gapToLeader;
  final String intervalToAhead;
  final TireCompound currentTire;
  final int pitStops;
  final bool isRetired;
}

class CommentaryEntry {
  final String id;
  final int lap;
  final String text;
  final DateTime timestamp;
  final CommentaryType type; // incident, overtake, pitstop, general
}

class RaceIncident {
  final String id;
  final IncidentType type; // safety_car, red_flag, crash, penalty
  final String description;
  final String? affectedDriverId;
  final int lap;
  final DateTime timestamp;
}
```

**LiveRaceService**

```dart
class LiveRaceService {
  final F1ApiService _api;
  final StreamController<LiveRaceData> _controller;
  Timer? _pollTimer;

  Stream<LiveRaceData> watchRace(String raceId) {
    _startPolling(raceId);
    return _controller.stream;
  }

  void _startPolling(String raceId) {
    _pollTimer?.cancel();

    // Poll every 5 seconds during active race
    _pollTimer = Timer.periodic(Duration(seconds: 5), (_) async {
      try {
        final data = await _api.fetchLiveRaceData(raceId);
        _controller.add(data);

        // Stop polling if race is finished
        if (data.status == RaceStatus.finished) {
          _pollTimer?.cancel();
        }
      } catch (e) {
        _controller.addError(e);
      }
    });
  }

  void stopWatching() {
    _pollTimer?.cancel();
  }

  Future<List<CommentaryEntry>> fetchCommentary(
    String raceId, {
    int? sinceId,
  }) async {
    // Fetch new commentary since last fetch
    final response = await _api.fetchRaceCommentary(
      raceId,
      sinceId: sinceId,
    );
    return response.map((e) => CommentaryEntry.fromJson(e)).toList();
  }
}
```


**Race Incident Notification Triggers**

```dart
class RaceIncidentMonitor {
  final LiveRaceService _liveRace;
  final NotificationService _notifications;
  final FavoritesRepository _favorites;

  StreamSubscription? _subscription;
  Set<String> _processedIncidents = {};

  void startMonitoring(String raceId) {
    _subscription = _liveRace.watchRace(raceId).listen((data) {
      _checkForIncidents(data);
    });
  }

  void _checkForIncidents(LiveRaceData data) {
    for (final incident in data.incidents) {
      if (_processedIncidents.contains(incident.id)) continue;

      _processedIncidents.add(incident.id);
      _sendIncidentNotification(incident);
    }
  }

  void _sendIncidentNotification(RaceIncident incident) {
    String title, body;

    switch (incident.type) {
      case IncidentType.safetyCar:
        title = '🚨 Safety Car Deployed';
        body = incident.description;
        break;
      case IncidentType.redFlag:
        title = '🔴 Red Flag - Race Stopped';
        body = incident.description;
        break;
      case IncidentType.crash:
        title = '💥 Incident on Track';
        body = incident.description;
        break;
      case IncidentType.penalty:
        title = '⚠️ Penalty Issued';
        body = incident.description;
        break;
    }

    // Prioritize if favorite driver involved
    final priority = incident.affectedDriverId != null &&
      _favorites.isDriverFavorite(incident.affectedDriverId!)
      ? NotificationPriority.high
      : NotificationPriority.normal;

    _notifications.sendLocalNotification(
      title: title,
      body: body,
      priority: priority,
      payload: {'type': 'race_incident', 'incidentId': incident.id},
    );
  }
}
```

**Position Change Tracking**

```dart
class PositionTracker {
  final Map<String, int> _startPositions = {};
  final Map<String, int> _previousPositions = {};

  void initialize(List<LiveDriverPosition> grid) {
    for (final driver in grid) {
      _startPositions[driver.driverId] = driver.startPosition;
      _previousPositions[driver.driverId] = driver.position;
    }
  }

  List<PositionChange> trackChanges(List<LiveDriverPosition> current) {
    final changes = <PositionChange>[];

    for (final driver in current) {
      final previous = _previousPositions[driver.driverId];
      if (previous != null && previous != driver.position) {
        final delta = previous - driver.position; // Positive = gained
        changes.add(PositionChange(
          driverId: driver.driverId,
          driverName: driver.driverName,
          from: previous,
          to: driver.position,
          delta: delta,
        ));
        _previousPositions[driver.driverId] = driver.position;
      }
    }

    return changes;
  }

  int getOverallChange(String driverId, int currentPosition) {
    final start = _startPositions[driverId];
    return start != null ? start - currentPosition : 0;
  }
}
```


#### 3.3 Comparison System

**ComparisonEngine**

```dart
class ComparisonEngine {
  final F1ApiService _api;
  final CacheManager _cache;

  Future<DriverComparison> compareDrivers(
    String driver1Id,
    String driver2Id,
  ) async {
    final driver1 = await _api.fetchDriverDetails(driver1Id);
    final driver2 = await _api.fetchDriverDetails(driver2Id);

    final stats1 = await _api.fetchDriverStats(driver1Id);
    final stats2 = await _api.fetchDriverStats(driver2Id);

    final headToHead = await _computeHeadToHead(driver1Id, driver2Id);

    return DriverComparison(
      driver1: driver1,
      driver2: driver2,
      stats1: stats1,
      stats2: stats2,
      headToHead: headToHead,
    );
  }

  Future<HeadToHeadRecord> _computeHeadToHead(
    String driver1Id,
    String driver2Id,
  ) async {
    final races = await _api.fetchAllRaces();

    var driver1Ahead = 0;
    var driver2Ahead = 0;
    final raceResults = <HeadToHeadRace>[];

    for (final race in races) {
      final result1 = race.results.firstWhereOrNull(
        (r) => r.driverId == driver1Id,
      );
      final result2 = race.results.firstWhereOrNull(
        (r) => r.driverId == driver2Id,
      );

      if (result1 != null && result2 != null) {
        raceResults.add(HeadToHeadRace(
          raceName: race.name,
          season: race.season,
          driver1Position: result1.position,
          driver2Position: result2.position,
        ));

        if (result1.position < result2.position) {
          driver1Ahead++;
        } else if (result2.position < result1.position) {
          driver2Ahead++;
        }
      }
    }

    return HeadToHeadRecord(
      driver1WinCount: driver1Ahead,
      driver2WinCount: driver2Ahead,
      totalRaces: raceResults.length,
      raceResults: raceResults,
    );
  }
}

class DriverComparison {
  final Driver driver1;
  final Driver driver2;
  final DriverStats stats1;
  final DriverStats stats2;
  final HeadToHeadRecord headToHead;

  // Computed properties
  bool get areTeammates => driver1.teamId == driver2.teamId;

  ComparisonMetrics get metrics => ComparisonMetrics(
    pointsDiff: stats1.points - stats2.points,
    winsDiff: stats1.wins - stats2.wins,
    podiumsDiff: stats1.podiums - stats2.podiums,
    polesDiff: stats1.poles - stats2.poles,
  );
}

class DriverStats {
  final int points;
  final int wins;
  final int podiums;
  final int poles;
  final int fastestLaps;
  final int championships;
  final List<SeasonPoints> pointsProgression;
}
```


**Performance Visualization**

```dart
class ChartBuilder {
  LineChartData buildPointsProgressionChart(DriverComparison comparison) {
    final driver1Data = comparison.stats1.pointsProgression;
    final driver2Data = comparison.stats2.pointsProgression;

    return LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: driver1Data.mapIndexed((i, pts) =>
            FlSpot(i.toDouble(), pts.points.toDouble())
          ).toList(),
          color: _getDriverColor(comparison.driver1),
          isCurved: true,
          barWidth: 3,
          dotData: FlDotData(show: true),
        ),
        LineChartBarData(
          spots: driver2Data.mapIndexed((i, pts) =>
            FlSpot(i.toDouble(), pts.points.toDouble())
          ).toList(),
          color: _getDriverColor(comparison.driver2),
          isCurved: true,
          barWidth: 3,
          dotData: FlDotData(show: true),
        ),
      ],
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < driver1Data.length) {
                return Text(driver1Data[index].raceName);
              }
              return Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) => Text('${value.toInt()}'),
          ),
        ),
      ),
      gridData: FlGridData(show: true),
      borderData: FlBorderData(show: true),
    );
  }

  BarChartData buildPodiumsChart(DriverComparison comparison) {
    final races = _getRaceNames(comparison.stats1.pointsProgression);

    return BarChartData(
      barGroups: races.mapIndexed((i, race) {
        final driver1Podium = _isPodium(comparison.stats1, race);
        final driver2Podium = _isPodium(comparison.stats2, race);

        return BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: driver1Podium ? 1 : 0,
              color: _getDriverColor(comparison.driver1),
              width: 8,
            ),
            BarChartRodData(
              toY: driver2Podium ? 1 : 0,
              color: _getDriverColor(comparison.driver2),
              width: 8,
            ),
          ],
        );
      }).toList(),
      titlesData: _buildBarChartTitles(races),
    );
  }
}
```


#### 3.4 News System

**News Data Models**

```dart
class NewsArticle {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String? imageUrl;
  final String source;
  final DateTime publishedAt;
  final Set<NewsCategory> categories;
  final Set<String> tags;
}

enum NewsCategory {
  teams,
  drivers,
  technical,
  raceReports,
  general,
}

class NewsRepository {
  final F1NewsApiService _api;
  final CacheManager _cache;
  final FirestoreService _firestore;

  Future<List<NewsArticle>> fetchLatestNews({
    Set<NewsCategory>? categories,
    int limit = 20,
  }) async {
    try {
      final articles = await _api.fetchNews(
        categories: categories,
        limit: limit,
      );

      // Cache for offline access
      await _cache.cacheNews(articles);

      return articles;
    } catch (e) {
      // Fallback to cached news
      return await _cache.getCachedNews() ?? [];
    }
  }

  Future<NewsArticle> fetchArticleDetails(String articleId) async {
    return await _api.fetchArticle(articleId);
  }

  Future<Map<NewsCategory, int>> getArticleCountByCategory() async {
    final allArticles = await fetchLatestNews();
    final counts = <NewsCategory, int>{};

    for (final category in NewsCategory.values) {
      counts[category] = allArticles
        .where((a) => a.categories.contains(category))
        .length;
    }

    return counts;
  }
}
```

**Saved Articles System**

```dart
class SavedArticlesRepository {
  final FirestoreService _firestore;
  final LocalStorageService _localStorage;

  final Set<String> _savedArticleIds = {};
  static const MAX_SAVED = 100;

  Future<void> loadSavedArticles(String userId) async {
    final local = await _localStorage.getSavedArticles(userId);
    if (local != null) {
      _savedArticleIds.addAll(local);
    }

    _syncSavedArticles(userId);
  }

  Future<void> toggleSaveArticle(
    String userId,
    String articleId,
  ) async {
    if (_savedArticleIds.contains(articleId)) {
      _savedArticleIds.remove(articleId);
    } else {
      if (_savedArticleIds.length >= MAX_SAVED) {
        throw SavedArticlesLimitException('Maximum 100 articles');
      }
      _savedArticleIds.add(articleId);
    }

    await _localStorage.saveSavedArticles(userId, _savedArticleIds);
    _syncToFirestore(userId);
  }

  bool isSaved(String articleId) => _savedArticleIds.contains(articleId);

  List<NewsArticle> getSavedArticles(List<NewsArticle> allArticles) {
    return allArticles
      .where((a) => _savedArticleIds.contains(a.id))
      .toList();
  }
}
```


**Social Sharing Integration**

```dart
class ShareService {
  final Share _share;

  Future<void> shareArticle(NewsArticle article) async {
    final shareUrl = 'https://f1app.com/news/${article.id}';

    await _share.share(
      '${article.title}\n\n$shareUrl',
      subject: article.title,
    );
  }

  Future<void> shareArticleWithImage(NewsArticle article) async {
    if (article.imageUrl == null) {
      return shareArticle(article);
    }

    // Download image temporarily
    final tempDir = await getTemporaryDirectory();
    final imagePath = '${tempDir.path}/share_${article.id}.jpg';

    final response = await http.get(Uri.parse(article.imageUrl!));
    await File(imagePath).writeAsBytes(response.bodyBytes);

    await _share.shareXFiles(
      [XFile(imagePath)],
      text: '${article.title}\n\nhttps://f1app.com/news/${article.id}',
    );
  }

  Future<void> copyArticleLink(NewsArticle article) async {
    final url = 'https://f1app.com/news/${article.id}';
    await Clipboard.setData(ClipboardData(text: url));
  }
}
```

**Breaking News Detection (Backend)**

```typescript
// Firebase Cloud Function
export const detectBreakingNews = functions.firestore
  .document('news/{articleId}')
  .onCreate(async (snapshot, context) => {
    const article = snapshot.data();

    // Priority scoring algorithm
    const score = calculatePriorityScore(article);

    if (score >= BREAKING_NEWS_THRESHOLD) {
      // Mark as breaking news
      await snapshot.ref.update({ isBreaking: true });

      // Send notifications to subscribed users
      await sendBreakingNewsNotification({
        title: article.title,
        body: article.summary,
        articleId: context.params.articleId,
      });
    }
  });

function calculatePriorityScore(article: any): number {
  let score = 0;

  // Keywords boost
  const urgentKeywords = ['breaking', 'crash', 'penalty', 'disqualified', 'winner'];
  if (urgentKeywords.some(kw => article.title.toLowerCase().includes(kw))) {
    score += 30;
  }

  // Category boost
  if (article.categories.includes('raceReports')) {
    score += 20;
  }

  // Source reputation boost
  if (TRUSTED_SOURCES.includes(article.source)) {
    score += 10;
  }

  return score;
}
```


## Data Models

### Core Domain Models

**User Model**
```dart
@HiveType(typeId: 1)
class User {
  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String? displayName;

  @HiveField(3)
  final String? photoUrl;

  @HiveField(4)
  final AuthProvider provider;

  @HiveField(5)
  final DateTime createdAt;

  factory User.fromFirebaseUser(firebase_auth.User user);
}

enum AuthProvider { email, google, apple }
```

**Favorite Model**
```dart
class Favorite {
  final String userId;
  final FavoriteType type;
  final String entityId;
  final DateTime addedAt;
}

enum FavoriteType { driver, team, product }
```

**Extended Driver Model**
```dart
class Driver extends Equatable {
  final String id;
  final String name;
  final String surname;
  final String? shortName;
  final int number;
  final String nationality;
  final String? teamId;
  final int? position;

  // Extended stats
  final int? points;
  final int? wins;
  final int? podiums;
  final int? poles;
  final int? fastestLaps;

  String get fullName => '$name $surname';
}
```

**Extended Team Model**
```dart
class Team extends Equatable {
  final String id;
  final String name;
  final String? nationality;
  final int? firstAppearance;
  final String? logoUrl;
  final Color? primaryColor;

  // Extended stats
  final int? points;
  final int? wins;
  final int? podiums;
  final int? constructorChampionships;
}
```


### Firestore Data Structure

```
users/
  {userId}/
    - email: string
    - displayName: string
    - photoUrl: string
    - provider: string
    - createdAt: timestamp
    - updatedAt: timestamp

    preferences/
      - favoriteDrivers: string[]
      - favoriteTeams: string[]
      - notifications: map

    wishlist/
      - productIds: string[]
      - updatedAt: timestamp

    savedArticles/
      - articleIds: string[]
      - updatedAt: timestamp

    payment_methods/
      {methodId}/
        - type: string
        - token: string
        - lastFour: string
        - brand: string
        - expiryMonth: int
        - expiryYear: int

orders/
  {orderId}/
    - userId: string
    - items: array
    - total: number
    - status: string
    - orderDate: timestamp
    - shippingAddress: map
    - paymentMethod: map

reviews/
  {reviewId}/
    - productId: string
    - userId: string
    - userName: string
    - rating: int (1-5)
    - text: string
    - createdAt: timestamp
    - updatedAt: timestamp

news/
  {articleId}/
    - title: string
    - summary: string
    - content: string
    - imageUrl: string
    - source: string
    - publishedAt: timestamp
    - categories: string[]
    - tags: string[]
    - isBreaking: boolean
```


## Key Algorithms

### 1. Sync Conflict Resolution Algorithm

**Last-Write-Wins with Vector Clocks**

```dart
class ConflictResolver {
  Map<String, dynamic> resolve(
    LocalData local,
    RemoteData remote,
  ) {
    // Simple last-write-wins for this app
    if (local.updatedAt.isAfter(remote.updatedAt)) {
      return local.data;
    } else if (remote.updatedAt.isAfter(local.updatedAt)) {
      return remote.data;
    }

    // If timestamps are equal (rare), merge strategically
    return _mergeData(local.data, remote.data);
  }

  Map<String, dynamic> _mergeData(
    Map<String, dynamic> local,
    Map<String, dynamic> remote,
  ) {
    final merged = Map<String, dynamic>.from(remote);

    // For sets (favorites), take union
    if (local['favoriteDrivers'] is List && remote['favoriteDrivers'] is List) {
      final localSet = Set<String>.from(local['favoriteDrivers']);
      final remoteSet = Set<String>.from(remote['favoriteDrivers']);
      merged['favoriteDrivers'] = localSet.union(remoteSet).toList();
    }

    // For other fields, prefer remote
    return merged;
  }
}
```

### 2. Search Ranking Algorithm

**TF-IDF with Position Boost**

```dart
class SearchRanker {
  double score(String query, SearchableItem item) {
    final queryTerms = query.toLowerCase().split(' ');
    var totalScore = 0.0;

    for (final term in queryTerms) {
      // Term frequency in item
      final tf = _termFrequency(term, item.searchableText);

      // Inverse document frequency (precomputed)
      final idf = _idf(term);

      // Position boost (earlier match = higher score)
      final position = item.searchableText.indexOf(term);
      final positionBoost = position == 0 ? 2.0 : (position < 10 ? 1.5 : 1.0);

      // Field boost (title match > body match)
      final fieldBoost = item.title.toLowerCase().contains(term) ? 2.0 : 1.0;

      totalScore += tf * idf * positionBoost * fieldBoost;
    }

    return totalScore;
  }

  double _termFrequency(String term, String text) {
    final count = term.allMatches(text.toLowerCase()).length;
    final totalTerms = text.split(' ').length;
    return count / totalTerms;
  }

  double _idf(String term) {
    // Precomputed IDF values from corpus
    return _idfCache[term] ?? 1.0;
  }
}
```


### 3. Cache Eviction Strategy (LRU)

**Least Recently Used with Size Constraints**

```dart
class LRUCache<K, V> {
  final int maxSize;
  final LinkedHashMap<K, CacheEntry<V>> _cache = LinkedHashMap();

  LRUCache(this.maxSize);

  V? get(K key) {
    final entry = _cache.remove(key);
    if (entry != null) {
      // Move to end (most recently used)
      _cache[key] = entry.copyWith(lastAccessed: DateTime.now());
      return entry.value;
    }
    return null;
  }

  void put(K key, V value) {
    _cache.remove(key); // Remove if exists

    if (_cache.length >= maxSize) {
      // Remove least recently used (first item)
      _cache.remove(_cache.keys.first);
    }

    _cache[key] = CacheEntry(
      value: value,
      cachedAt: DateTime.now(),
      lastAccessed: DateTime.now(),
    );
  }

  void evictExpired(Duration maxAge) {
    final now = DateTime.now();
    _cache.removeWhere((key, entry) {
      return now.difference(entry.cachedAt) > maxAge;
    });
  }
}

class CacheEntry<V> {
  final V value;
  final DateTime cachedAt;
  final DateTime lastAccessed;

  CacheEntry copyWith({DateTime? lastAccessed}) {
    return CacheEntry(
      value: value,
      cachedAt: cachedAt,
      lastAccessed: lastAccessed ?? this.lastAccessed,
    );
  }
}
```

### 4. Live Timing Data Interpolation

**Linear Interpolation for Smooth Updates**

```dart
class TimingInterpolator {
  // Smooth gap calculations between updates
  double interpolateGap(
    double previousGap,
    double currentGap,
    double progress, // 0.0 to 1.0
  ) {
    return previousGap + (currentGap - previousGap) * progress;
  }

  // Predict next position based on current velocity
  int predictPosition(LiveDriverPosition current, Duration timeDelta) {
    final gapChange = current.gapToLeader - current.previousGapToLeader;
    final velocity = gapChange / timeDelta.inSeconds;

    // Predict gap in 5 seconds
    final predictedGap = current.gapToLeader + (velocity * 5);

    // Estimate position based on predicted gap
    return _estimatePositionFromGap(predictedGap, current.positions);
  }
}
```


## State Management Patterns

### Provider Architecture

**App-Level State Providers**

```dart
class AppProviders extends StatelessWidget {
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services (singletons)
        Provider<AuthService>(create: (_) => FirebaseAuthService()),
        Provider<F1ApiService>(create: (_) => F1ApiService()),
        Provider<NotificationService>(create: (_) => NotificationService()),

        // Repositories
        Provider<FavoritesRepository>(
          create: (context) => FavoritesRepository(
            firestore: context.read<FirestoreService>(),
            localStorage: context.read<LocalStorageService>(),
          ),
        ),

        // State (with ChangeNotifier)
        ChangeNotifierProvider<AuthState>(
          create: (context) => AuthState(context.read<AuthService>()),
        ),
        ChangeNotifierProvider<FavoritesState>(
          create: (context) => FavoritesState(
            context.read<FavoritesRepository>(),
            context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProvider<ShopState>(
          create: (_) => ShopState(),
        ),
        ChangeNotifierProvider<SearchState>(
          create: (context) => SearchState(context.read<SearchEngine>()),
        ),
        ChangeNotifierProvider<NewsState>(
          create: (context) => NewsState(context.read<NewsRepository>()),
        ),
      ],
      child: child,
    );
  }
}
```

**State Pattern for Complex States**

```dart
abstract class AuthenticationState {}

class Unauthenticated extends AuthenticationState {}

class Authenticating extends AuthenticationState {
  final AuthMethod method;
}

class Authenticated extends AuthenticationState {
  final User user;
}

class AuthenticationError extends AuthenticationState {
  final String message;
}

class AuthState extends ChangeNotifier {
  final AuthService _authService;

  AuthenticationState _state = Unauthenticated();
  AuthenticationState get state => _state;

  User? get currentUser => _state is Authenticated
    ? (_state as Authenticated).user
    : null;

  Future<void> signInWithEmail(String email, String password) async {
    _setState(Authenticating(AuthMethod.email));

    try {
      final user = await _authService.signInWithEmail(email, password);
      _setState(Authenticated(user));
    } catch (e) {
      _setState(AuthenticationError(e.toString()));
    }
  }

  void _setState(AuthenticationState newState) {
    _state = newState;
    notifyListeners();
  }
}
```


## Error Handling

### Error Type Hierarchy

```dart
abstract class AppException implements Exception {
  final String message;
  final String? userMessage;
  final Object? originalError;
  final bool shouldReport;

  AppException(
    this.message, {
    this.userMessage,
    this.originalError,
    this.shouldReport = true,
  });
}

class AuthException extends AppException {
  final AuthErrorType type;

  AuthException._(this.type, String message, String userMessage)
    : super(message, userMessage: userMessage);

  factory AuthException.emailInUse() => AuthException._(
    AuthErrorType.emailInUse,
    'Email already in use',
    'This email is already registered',
  );

  factory AuthException.weakPassword() => AuthException._(
    AuthErrorType.weakPassword,
    'Password too weak',
    'Password must be at least 8 characters',
  );
}

class NetworkException extends AppException {
  final int? statusCode;
  final Duration? timeout;

  NetworkException(String message, {
    this.statusCode,
    this.timeout,
    String? userMessage,
  }) : super(message, userMessage: userMessage);

  factory NetworkException.timeout() => NetworkException(
    'Request timeout',
    timeout: Duration(seconds: 30),
    userMessage: 'Request timed out. Please try again.',
  );
}

class CacheException extends AppException {
  CacheException(String message)
    : super(message, shouldReport: false);
}
```

### Global Error Handler

```dart
void main() {
  // Catch Flutter framework errors
  FlutterError.onError = (details) {
    ErrorLogger.log(details.exception, details.stack);
    AppErrorHandler.handleError(details.exception, details.stack);
  };

  // Catch async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    ErrorLogger.log(error, stack);
    AppErrorHandler.handleError(error, stack);
    return true;
  };

  runApp(const F1App());
}
```


## Testing Strategy

### Unit Testing

**Coverage Requirements**:
- Business logic: 80% minimum
- Services: 90% minimum
- Repositories: 85% minimum
- Utils: 90% minimum

**Test Structure**:
```dart
void main() {
  group('AuthService', () {
    late AuthService authService;
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      authService = FirebaseAuthService(auth: mockAuth);
    });

    group('signInWithEmail', () {
      test('should return user on successful sign in', () async {
        // Arrange
        when(mockAuth.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => MockUserCredential());

        // Act
        final result = await authService.signInWithEmail(
          'test@example.com',
          'password123',
        );

        // Assert
        expect(result, isA<User>());
      });

      test('should throw AuthException on invalid credentials', () async {
        // Arrange
        when(mockAuth.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenThrow(FirebaseAuthException(code: 'wrong-password'));

        // Act & Assert
        expect(
          () => authService.signInWithEmail('test@example.com', 'wrong'),
          throwsA(isA<AuthException>()),
        );
      });
    });
  });
}
```

**Mock Strategy**:
- Use mockito for service mocking
- Create fake implementations for complex objects
- Use test doubles for Firebase services


### Widget Testing

**Test Widgets in Isolation**:
```dart
void main() {
  testWidgets('AuthScreen shows email and password fields', (tester) async {
    // Build widget
    await tester.pumpWidget(
      MaterialApp(
        home: AuthScreen(),
      ),
    );

    // Verify
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('Shows error message on invalid email', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AuthScreen(),
      ),
    );

    // Enter invalid email
    await tester.enterText(find.byType(TextField).first, 'invalid');
    await tester.tap(find.text('Sign In'));
    await tester.pump();

    // Verify error
    expect(find.text('Invalid email format'), findsOneWidget);
  });
}
```

**Golden Tests for Visual Regression**:
```dart
testWidgets('DriverCard golden test', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: DriverCard(
          driver: Driver(
            id: '1',
            name: 'Lewis',
            surname: 'Hamilton',
            number: 44,
            teamId: 'mercedes',
          ),
        ),
      ),
    ),
  );

  await expectLater(
    find.byType(DriverCard),
    matchesGoldenFile('goldens/driver_card.png'),
  );
});
```


### Integration Testing

**End-to-End User Flows**:
```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('User authentication flow', () {
    testWidgets('User can register and login', (tester) async {
      // Setup
      await Firebase.initializeApp();
      await tester.pumpWidget(const F1App());
      await tester.pumpAndSettle();

      // Navigate to registration
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Fill registration form
      await tester.enterText(
        find.byKey(Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(Key('password_field')),
        'password123',
      );
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Verify navigation to home
      expect(find.byType(HomeScreen), findsOneWidget);

      // Logout
      await tester.tap(find.byIcon(Icons.account_circle));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      // Login again
      await tester.enterText(
        find.byKey(Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(Key('password_field')),
        'password123',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Verify logged in
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });

  group('Favorites flow', () {
    testWidgets('User can add and remove favorites', (tester) async {
      // Assume logged in
      await tester.pumpWidget(const F1App());
      await tester.pumpAndSettle();

      // Navigate to drivers
      await tester.tap(find.text('Drivers'));
      await tester.pumpAndSettle();

      // Tap first driver
      await tester.tap(find.byType(DriverCard).first);
      await tester.pumpAndSettle();

      // Favorite driver
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();

      // Verify favorited
      expect(find.byIcon(Icons.favorite), findsOneWidget);

      // Go back and verify in favorites view
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Favorites'));
      await tester.pumpAndSettle();

      expect(find.byType(DriverCard), findsAtLeastNWidgets(1));
    });
  });
}
```

**Test Environment Setup**:
- Use Firebase Emulator Suite for backend testing
- Mock F1 API responses with http_mock_adapter
- Setup test database with seed data
- Clean up after each test run
