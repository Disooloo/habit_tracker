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

  /// No description provided for @homeTab.
  ///
  /// In ru, this message translates to:
  /// **'Главная'**
  String get homeTab;

  /// No description provided for @profileTab.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get profileTab;

  /// No description provided for @signInToAccount.
  ///
  /// In ru, this message translates to:
  /// **'Войдите в аккаунт'**
  String get signInToAccount;

  /// No description provided for @profileSignInSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Сохраняйте профиль, дату регистрации и тарифный план.'**
  String get profileSignInSubtitle;

  /// No description provided for @signInOrRegister.
  ///
  /// In ru, this message translates to:
  /// **'Войти или зарегистрироваться'**
  String get signInOrRegister;

  /// No description provided for @defaultUserName.
  ///
  /// In ru, this message translates to:
  /// **'Пользователь'**
  String get defaultUserName;

  /// No description provided for @planFree.
  ///
  /// In ru, this message translates to:
  /// **'Бесплатный'**
  String get planFree;

  /// No description provided for @emailLabel.
  ///
  /// In ru, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In ru, this message translates to:
  /// **'Телефон'**
  String get phoneLabel;

  /// No description provided for @notSpecified.
  ///
  /// In ru, this message translates to:
  /// **'не указан'**
  String get notSpecified;

  /// No description provided for @registrationDate.
  ///
  /// In ru, this message translates to:
  /// **'Дата регистрации'**
  String get registrationDate;

  /// No description provided for @editName.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать имя'**
  String get editName;

  /// No description provided for @nameFieldLabel.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get nameFieldLabel;

  /// No description provided for @signOut.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get signOut;

  /// No description provided for @authTitle.
  ///
  /// In ru, this message translates to:
  /// **'Авторизация'**
  String get authTitle;

  /// No description provided for @authSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Вход по номеру может открыть проверку reCAPTCHA, это нормально.'**
  String get authSubtitle;

  /// No description provided for @enterNameError.
  ///
  /// In ru, this message translates to:
  /// **'Введите имя'**
  String get enterNameError;

  /// No description provided for @enterValidEmailError.
  ///
  /// In ru, this message translates to:
  /// **'Введите корректный email'**
  String get enterValidEmailError;

  /// No description provided for @passwordLabel.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get passwordLabel;

  /// No description provided for @minPasswordError.
  ///
  /// In ru, this message translates to:
  /// **'Минимум 6 символов'**
  String get minPasswordError;

  /// No description provided for @registerAction.
  ///
  /// In ru, this message translates to:
  /// **'Зарегистрироваться'**
  String get registerAction;

  /// No description provided for @signInAction.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get signInAction;

  /// No description provided for @haveAccountSignIn.
  ///
  /// In ru, this message translates to:
  /// **'Уже есть аккаунт? Войти'**
  String get haveAccountSignIn;

  /// No description provided for @noAccountRegister.
  ///
  /// In ru, this message translates to:
  /// **'Нет аккаунта? Зарегистрироваться'**
  String get noAccountRegister;

  /// No description provided for @phoneHint.
  ///
  /// In ru, this message translates to:
  /// **'Телефон (+79991234567)'**
  String get phoneHint;

  /// No description provided for @phoneHintDigitsOnly.
  ///
  /// In ru, this message translates to:
  /// **'Номер телефона'**
  String get phoneHintDigitsOnly;

  /// No description provided for @phoneNoPrefixHint.
  ///
  /// In ru, this message translates to:
  /// **'Введите только цифры без 8 и без +7'**
  String get phoneNoPrefixHint;

  /// No description provided for @phoneRuLengthError.
  ///
  /// In ru, this message translates to:
  /// **'Для РФ номер должен содержать 10 цифр, например 9998887766'**
  String get phoneRuLengthError;

  /// No description provided for @smsCodeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Код из SMS'**
  String get smsCodeLabel;

  /// No description provided for @confirmCodeAction.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердить код'**
  String get confirmCodeAction;

  /// No description provided for @getCodeAction.
  ///
  /// In ru, this message translates to:
  /// **'Получить код'**
  String get getCodeAction;

  /// No description provided for @googleSignIn.
  ///
  /// In ru, this message translates to:
  /// **'Войти через Google'**
  String get googleSignIn;

  /// No description provided for @authError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка авторизации'**
  String get authError;

  /// No description provided for @signInFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось выполнить вход'**
  String get signInFailed;

  /// No description provided for @googleSignInError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка Google входа'**
  String get googleSignInError;

  /// No description provided for @googleSignInFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось войти через Google'**
  String get googleSignInFailed;

  /// No description provided for @enterPhoneError.
  ///
  /// In ru, this message translates to:
  /// **'Введите номер телефона'**
  String get enterPhoneError;

  /// No description provided for @smsSendError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось отправить код'**
  String get smsSendError;

  /// No description provided for @phoneSignInError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка входа по телефону'**
  String get phoneSignInError;

  /// No description provided for @phoneSignInFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось выполнить вход по телефону'**
  String get phoneSignInFailed;

  /// No description provided for @subscriptionStatus.
  ///
  /// In ru, this message translates to:
  /// **'Статус подписки'**
  String get subscriptionStatus;

  /// No description provided for @proBenefitUnlimitedHabits.
  ///
  /// In ru, this message translates to:
  /// **'Безлимитное количество привычек'**
  String get proBenefitUnlimitedHabits;

  /// No description provided for @proBenefitPrioritySupport.
  ///
  /// In ru, this message translates to:
  /// **'Приоритетная поддержка и ранний доступ'**
  String get proBenefitPrioritySupport;

  /// No description provided for @freeBenefitHabitLimit.
  ///
  /// In ru, this message translates to:
  /// **'Лимит базового тарифа по количеству привычек'**
  String get freeBenefitHabitLimit;

  /// No description provided for @freeBenefitBasicSupport.
  ///
  /// In ru, this message translates to:
  /// **'Базовая поддержка и стандартные функции'**
  String get freeBenefitBasicSupport;

  /// No description provided for @changeAvatar.
  ///
  /// In ru, this message translates to:
  /// **'Изменить фото профиля'**
  String get changeAvatar;

  /// No description provided for @avatarUpdated.
  ///
  /// In ru, this message translates to:
  /// **'Фото профиля обновлено'**
  String get avatarUpdated;

  /// No description provided for @avatarUpdateFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось обновить фото профиля'**
  String get avatarUpdateFailed;

  /// No description provided for @accountManagement.
  ///
  /// In ru, this message translates to:
  /// **'Управление аккаунтом'**
  String get accountManagement;

  /// No description provided for @changeEmail.
  ///
  /// In ru, this message translates to:
  /// **'Сменить email'**
  String get changeEmail;

  /// No description provided for @changePassword.
  ///
  /// In ru, this message translates to:
  /// **'Сменить пароль'**
  String get changePassword;

  /// No description provided for @deleteAccount.
  ///
  /// In ru, this message translates to:
  /// **'Удалить аккаунт'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены? Аккаунт и профиль будут удалены без возможности восстановления.'**
  String get deleteAccountConfirm;

  /// No description provided for @emailUpdateSent.
  ///
  /// In ru, this message translates to:
  /// **'Письмо для подтверждения нового email отправлено'**
  String get emailUpdateSent;

  /// No description provided for @passwordUpdated.
  ///
  /// In ru, this message translates to:
  /// **'Пароль обновлен'**
  String get passwordUpdated;
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
