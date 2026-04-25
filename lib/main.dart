import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'data/database/app_database.dart';
import 'data/repositories/habit_repository_impl.dart';
import 'domain/repositories/habit_repository.dart';
import 'domain/usecases/create_habit.dart';
import 'domain/usecases/update_habit.dart';
import 'domain/usecases/delete_habit.dart';
import 'domain/usecases/get_habits.dart';
import 'domain/usecases/get_habit_by_id.dart';
import 'domain/usecases/track_habit.dart';
import 'domain/usecases/get_statistics.dart';
import 'presentation/bloc/habit/habit_bloc.dart';
import 'presentation/bloc/onboarding/onboarding_bloc.dart';
import 'presentation/bloc/timer/timer_bloc.dart';
import 'presentation/bloc/statistics/statistics_bloc.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/habit_form/habit_form_screen.dart';
import 'presentation/screens/habit_detail/habit_detail_screen.dart';
import 'presentation/screens/timer/timer_screen.dart';
import 'presentation/screens/statistics/statistics_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/screens/settings/subscription_screen.dart';
import 'presentation/screens/settings/feedback_screen.dart';
import 'presentation/screens/settings/privacy_policy_screen.dart';
import 'presentation/screens/settings/terms_of_service_screen.dart';
import 'presentation/screens/notifications/notifications_screen.dart';
import 'presentation/screens/diary/diary_screen.dart';
import 'services/notification_service.dart';
import 'core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database factory first
  try {
    await AppDatabase.initialize();
    // Then initialize database
    await AppDatabase().database;
  } catch (e) {
    // Ignore errors on web for now, database will initialize on first use
    if (kDebugMode) {
      print('Database initialization error: $e');
    }
  }

  // Initialize notifications (skip on web)
  try {
    await NotificationService().initialize();
  } catch (e) {
    // Notifications may not work on web
    if (kDebugMode) {
      print('Notification initialization error: $e');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString(AppConstants.keyLanguage);
    final theme = prefs.getString(AppConstants.keyThemeMode) ?? 'system';
    if (!mounted) return;
    setState(() {
      if (language == 'ru' || language == 'en') {
        _locale = Locale(language!);
      }
      _themeMode = _parseThemeMode(theme);
    });
  }

  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> _onLanguageChanged(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyLanguage, languageCode);
    if (!mounted) return;
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  Future<void> _onThemeModeChanged(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(AppConstants.keyThemeMode, value);
    if (!mounted) return;
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Create repository and use cases
    final HabitRepository repository = HabitRepositoryImpl();
    final createHabit = CreateHabit(repository);
    final updateHabit = UpdateHabit(repository);
    final deleteHabit = DeleteHabit(repository);
    final getHabits = GetHabits(repository);
    final getHabitById = GetHabitById(repository);
    final trackHabit = TrackHabit(repository);
    final getStatistics = GetStatistics(repository);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => OnboardingBloc(),
        ),
        BlocProvider(
          create: (_) => HabitBloc(
            createHabit: createHabit,
            updateHabit: updateHabit,
            deleteHabit: deleteHabit,
            getHabits: getHabits,
            getHabitById: getHabitById,
            trackHabit: trackHabit,
            repository: repository,
          ),
        ),
        BlocProvider(
          create: (_) => TimerBloc(),
        ),
        BlocProvider(
          create: (_) => StatisticsBloc(getStatistics: getStatistics),
        ),
      ],
      child: MaterialApp(
        title: 'Мягкий трекер привычек',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: ThemeData.dark(useMaterial3: true),
        themeMode: _themeMode,
        locale: _locale,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ru', ''),
          Locale('en', ''),
        ],
        home: const AppNavigator(),
        routes: {
          '/habit-form': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            return HabitFormScreen(habitId: args as int?);
          },
          '/habit-detail': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            return HabitDetailScreen(habitId: args as int);
          },
          '/timer': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            return TimerScreen(habitId: args as int);
          },
          '/statistics': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            return StatisticsScreen(habitId: args as int?);
          },
          '/settings': (context) => SettingsScreen(
                currentLanguage: _locale?.languageCode ?? 'ru',
                currentThemeMode: _themeMode,
                onLanguageChanged: _onLanguageChanged,
                onThemeModeChanged: _onThemeModeChanged,
              ),
          '/subscription': (context) => const SubscriptionScreen(),
          '/feedback': (context) => const FeedbackScreen(),
          '/privacy-policy': (context) => const PrivacyPolicyScreen(),
          '/terms-of-service': (context) => const TermsOfServiceScreen(),
          '/notifications': (context) => const NotificationsScreen(),
          '/diary': (context) => const DiaryScreen(),
        },
      ),
    );
  }
}

class AppNavigator extends StatelessWidget {
  const AppNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: OnboardingBloc.isOnboardingCompleted(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          return const HomeScreen();
        } else {
          return const OnboardingScreen();
        }
      },
    );
  }
}

