class AppConstants {
  // Freemium limit
  static const int freeHabitLimit = 3;

  // Timer
  static const int quickStartTimerSeconds = 30;

  // Habit tracking statuses
  static const String statusDone = 'done';
  static const String statusPartial = 'partial';
  static const String statusNotDone = 'not_done';

  // Habit frequencies
  static const String frequencyDaily = 'daily';
  static const String frequencyDailyOnce = 'daily_once';
  static const String frequencyDailyMulti = 'daily_multi';
  static const String frequencyWeekly = 'weekly';

  // SharedPreferences keys
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keySubscriptionActive = 'subscription_active';
  static const String keySubscriptionPlan = 'subscription_plan';
  static const String keySubscriptionUntil = 'subscription_until';
  static const String keyRedeemedPromoCodes = 'redeemed_promo_codes';
  static const String keySubscriptionExpiredHandled = 'subscription_expired_handled_until';
  static const String keyLanguage = 'language';
  static const String keyThemeMode = 'theme_mode';
  static const String keyNotificationsEnabled = 'notifications_enabled';

  // Notification IDs
  static const int notificationChannelId = 1;
  static const String notificationChannelName = 'habit_reminders';
  static const String notificationChannelDescription = 'Напоминания о привычках';
  static const int notificationInactivityId = 900001;
  static const int notificationDayStartId = 900002;
}


