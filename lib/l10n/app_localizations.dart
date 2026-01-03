import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// Название приложения
  ///
  /// In ru, this message translates to:
  /// **'Мягкий трекер привычек'**
  String get appName;

  /// No description provided for @onboardingTitle1.
  ///
  /// In ru, this message translates to:
  /// **'Маленькие шаги'**
  String get onboardingTitle1;

  /// No description provided for @onboardingSubtitle1.
  ///
  /// In ru, this message translates to:
  /// **'Каждое действие имеет значение, даже самое маленькое'**
  String get onboardingSubtitle1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In ru, this message translates to:
  /// **'Без стыда'**
  String get onboardingTitle2;

  /// No description provided for @onboardingSubtitle2.
  ///
  /// In ru, this message translates to:
  /// **'Пропустил день? Ничего страшного. Можно вернуться в любой момент'**
  String get onboardingSubtitle2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In ru, this message translates to:
  /// **'Начни с малого'**
  String get onboardingTitle3;

  /// No description provided for @onboardingSubtitle3.
  ///
  /// In ru, this message translates to:
  /// **'30 секунд — уже достаточно для начала'**
  String get onboardingSubtitle3;

  /// No description provided for @next.
  ///
  /// In ru, this message translates to:
  /// **'Дальше'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In ru, this message translates to:
  /// **'Пропустить'**
  String get skip;

  /// No description provided for @understand.
  ///
  /// In ru, this message translates to:
  /// **'Понятно'**
  String get understand;

  /// No description provided for @createHabit.
  ///
  /// In ru, this message translates to:
  /// **'Создать привычку'**
  String get createHabit;

  /// No description provided for @hello.
  ///
  /// In ru, this message translates to:
  /// **'Привет'**
  String get hello;

  /// No description provided for @canStartSmall.
  ///
  /// In ru, this message translates to:
  /// **'Можно начать с малого'**
  String get canStartSmall;

  /// No description provided for @habitName.
  ///
  /// In ru, this message translates to:
  /// **'Название привычки'**
  String get habitName;

  /// No description provided for @minimalAction.
  ///
  /// In ru, this message translates to:
  /// **'Минимальное действие'**
  String get minimalAction;

  /// No description provided for @minimalActionHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: 1 минута'**
  String get minimalActionHint;

  /// No description provided for @frequency.
  ///
  /// In ru, this message translates to:
  /// **'Частота'**
  String get frequency;

  /// No description provided for @daily.
  ///
  /// In ru, this message translates to:
  /// **'Каждый день'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In ru, this message translates to:
  /// **'Несколько раз в неделю'**
  String get weekly;

  /// No description provided for @reminder.
  ///
  /// In ru, this message translates to:
  /// **'Напоминание'**
  String get reminder;

  /// No description provided for @reminderTime.
  ///
  /// In ru, this message translates to:
  /// **'Время напоминания'**
  String get reminderTime;

  /// No description provided for @save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @edit.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get delete;

  /// No description provided for @done.
  ///
  /// In ru, this message translates to:
  /// **'Выполнено'**
  String get done;

  /// No description provided for @partial.
  ///
  /// In ru, this message translates to:
  /// **'Сделано немного'**
  String get partial;

  /// No description provided for @notDone.
  ///
  /// In ru, this message translates to:
  /// **'Не сделал'**
  String get notDone;

  /// No description provided for @start30Seconds.
  ///
  /// In ru, this message translates to:
  /// **'Начать на 30 секунд'**
  String get start30Seconds;

  /// No description provided for @thisIsEnough.
  ///
  /// In ru, this message translates to:
  /// **'Этого уже достаточно'**
  String get thisIsEnough;

  /// No description provided for @continueAction.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get continueAction;

  /// No description provided for @finish.
  ///
  /// In ru, this message translates to:
  /// **'Завершить'**
  String get finish;

  /// No description provided for @statistics.
  ///
  /// In ru, this message translates to:
  /// **'Статистика'**
  String get statistics;

  /// No description provided for @daysWithAttempt.
  ///
  /// In ru, this message translates to:
  /// **'Дней с попыткой'**
  String get daysWithAttempt;

  /// No description provided for @bestDayOfWeek.
  ///
  /// In ru, this message translates to:
  /// **'Лучший день недели'**
  String get bestDayOfWeek;

  /// No description provided for @youCameBack.
  ///
  /// In ru, this message translates to:
  /// **'Ты возвращался после пауз'**
  String get youCameBack;

  /// No description provided for @settings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settings;

  /// No description provided for @notifications.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get notifications;

  /// No description provided for @language.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get language;

  /// No description provided for @subscription.
  ///
  /// In ru, this message translates to:
  /// **'Подписка'**
  String get subscription;

  /// No description provided for @feedback.
  ///
  /// In ru, this message translates to:
  /// **'Обратная связь'**
  String get feedback;

  /// No description provided for @privacyPolicy.
  ///
  /// In ru, this message translates to:
  /// **'Политика конфиденциальности'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In ru, this message translates to:
  /// **'Условия использования'**
  String get termsOfService;

  /// No description provided for @freeLimitReached.
  ///
  /// In ru, this message translates to:
  /// **'Достигнут лимит бесплатных привычек'**
  String get freeLimitReached;

  /// No description provided for @upgradeToUnlimited.
  ///
  /// In ru, this message translates to:
  /// **'Обновитесь до премиум для неограниченного количества привычек'**
  String get upgradeToUnlimited;

  /// No description provided for @upgrade.
  ///
  /// In ru, this message translates to:
  /// **'Обновить'**
  String get upgrade;

  /// No description provided for @history.
  ///
  /// In ru, this message translates to:
  /// **'История'**
  String get history;

  /// No description provided for @noHabitsYet.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет привычек'**
  String get noHabitsYet;

  /// No description provided for @createFirstHabit.
  ///
  /// In ru, this message translates to:
  /// **'Создайте первую привычку'**
  String get createFirstHabit;

  /// No description provided for @noTrackingYet.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет отметок'**
  String get noTrackingYet;

  /// No description provided for @startTracking.
  ///
  /// In ru, this message translates to:
  /// **'Начните отслеживать свою привычку'**
  String get startTracking;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
