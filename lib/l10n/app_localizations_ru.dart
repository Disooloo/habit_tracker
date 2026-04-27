// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Мягкий трекер привычек';

  @override
  String get onboardingTitle1 => 'Маленькие шаги';

  @override
  String get onboardingSubtitle1 =>
      'Каждое действие имеет значение, даже самое маленькое';

  @override
  String get onboardingTitle2 => 'Без стыда';

  @override
  String get onboardingSubtitle2 =>
      'Пропустил день? Ничего страшного. Можно вернуться в любой момент';

  @override
  String get onboardingTitle3 => 'Начни с малого';

  @override
  String get onboardingSubtitle3 => '30 секунд — уже достаточно для начала';

  @override
  String get next => 'Дальше';

  @override
  String get skip => 'Пропустить';

  @override
  String get understand => 'Понятно';

  @override
  String get createHabit => 'Создать привычку';

  @override
  String get hello => 'Привет';

  @override
  String get canStartSmall => 'Можно начать с малого';

  @override
  String get habitName => 'Название привычки';

  @override
  String get minimalAction => 'Минимальное действие';

  @override
  String get minimalActionHint => 'Например: 1 минута';

  @override
  String get frequency => 'Частота';

  @override
  String get daily => 'Каждый день';

  @override
  String get weekly => 'Несколько раз в неделю';

  @override
  String get reminder => 'Напоминание';

  @override
  String get reminderTime => 'Время напоминания';

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String get edit => 'Редактировать';

  @override
  String get delete => 'Удалить';

  @override
  String get done => 'Выполнено';

  @override
  String get partial => 'Сделано немного';

  @override
  String get notDone => 'Не сделал';

  @override
  String get start30Seconds => 'Начать на 30 секунд';

  @override
  String get thisIsEnough => 'Этого уже достаточно';

  @override
  String get continueAction => 'Продолжить';

  @override
  String get finish => 'Завершить';

  @override
  String get statistics => 'Статистика';

  @override
  String get daysWithAttempt => 'Дней с попыткой';

  @override
  String get bestDayOfWeek => 'Лучший день недели';

  @override
  String get youCameBack => 'Ты возвращался после пауз';

  @override
  String get settings => 'Настройки';

  @override
  String get notifications => 'Уведомления';

  @override
  String get language => 'Язык';

  @override
  String get subscription => 'Подписка';

  @override
  String get feedback => 'Обратная связь';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get termsOfService => 'Условия использования';

  @override
  String get freeLimitReached => 'Достигнут лимит бесплатных привычек';

  @override
  String get upgradeToUnlimited =>
      'Обновитесь до премиум для неограниченного количества привычек';

  @override
  String get upgrade => 'Обновить';

  @override
  String get history => 'История';

  @override
  String get noHabitsYet => 'Пока нет привычек';

  @override
  String get createFirstHabit => 'Создайте первую привычку';

  @override
  String get noTrackingYet => 'Пока нет отметок';

  @override
  String get startTracking => 'Начните отслеживать свою привычку';

  @override
  String get homeTab => 'Главная';

  @override
  String get profileTab => 'Профиль';

  @override
  String get signInToAccount => 'Войдите в аккаунт';

  @override
  String get profileSignInSubtitle =>
      'Сохраняйте профиль, дату регистрации и тарифный план.';

  @override
  String get signInOrRegister => 'Войти или зарегистрироваться';

  @override
  String get defaultUserName => 'Пользователь';

  @override
  String get planFree => 'Бесплатный';

  @override
  String get emailLabel => 'Email';

  @override
  String get phoneLabel => 'Телефон';

  @override
  String get notSpecified => 'не указан';

  @override
  String get registrationDate => 'Дата регистрации';

  @override
  String get editName => 'Редактировать имя';

  @override
  String get nameFieldLabel => 'Имя';

  @override
  String get signOut => 'Выйти';

  @override
  String get authTitle => 'Авторизация';

  @override
  String get authSubtitle =>
      'Вход по номеру может открыть проверку reCAPTCHA, это нормально.';

  @override
  String get enterNameError => 'Введите имя';

  @override
  String get enterValidEmailError => 'Введите корректный email';

  @override
  String get passwordLabel => 'Пароль';

  @override
  String get minPasswordError => 'Минимум 6 символов';

  @override
  String get registerAction => 'Зарегистрироваться';

  @override
  String get signInAction => 'Войти';

  @override
  String get haveAccountSignIn => 'Уже есть аккаунт? Войти';

  @override
  String get noAccountRegister => 'Нет аккаунта? Зарегистрироваться';

  @override
  String get phoneHint => 'Телефон (+79991234567)';

  @override
  String get phoneHintDigitsOnly => 'Номер телефона';

  @override
  String get phoneNoPrefixHint => 'Введите только цифры без 8 и без +7';

  @override
  String get phoneRuLengthError =>
      'Для РФ номер должен содержать 10 цифр, например 9998887766';

  @override
  String get smsCodeLabel => 'Код из SMS';

  @override
  String get confirmCodeAction => 'Подтвердить код';

  @override
  String get getCodeAction => 'Получить код';

  @override
  String get googleSignIn => 'Войти через Google';

  @override
  String get authError => 'Ошибка авторизации';

  @override
  String get signInFailed => 'Не удалось выполнить вход';

  @override
  String get googleSignInError => 'Ошибка Google входа';

  @override
  String get googleSignInFailed => 'Не удалось войти через Google';

  @override
  String get enterPhoneError => 'Введите номер телефона';

  @override
  String get smsSendError => 'Не удалось отправить код';

  @override
  String get phoneSignInError => 'Ошибка входа по телефону';

  @override
  String get phoneSignInFailed => 'Не удалось выполнить вход по телефону';

  @override
  String get subscriptionStatus => 'Статус подписки';

  @override
  String get proBenefitUnlimitedHabits => 'Безлимитное количество привычек';

  @override
  String get proBenefitPrioritySupport =>
      'Приоритетная поддержка и ранний доступ';

  @override
  String get freeBenefitHabitLimit =>
      'Лимит базового тарифа по количеству привычек';

  @override
  String get freeBenefitBasicSupport =>
      'Базовая поддержка и стандартные функции';

  @override
  String get changeAvatar => 'Изменить фото профиля';

  @override
  String get avatarUpdated => 'Фото профиля обновлено';

  @override
  String get avatarUpdateFailed => 'Не удалось обновить фото профиля';

  @override
  String get accountManagement => 'Управление аккаунтом';

  @override
  String get changeEmail => 'Сменить email';

  @override
  String get changePassword => 'Сменить пароль';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get deleteAccountConfirm =>
      'Вы уверены? Аккаунт и профиль будут удалены без возможности восстановления.';

  @override
  String get emailUpdateSent =>
      'Письмо для подтверждения нового email отправлено';

  @override
  String get passwordUpdated => 'Пароль обновлен';
}
