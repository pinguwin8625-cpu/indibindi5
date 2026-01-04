// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'IndiBindi';

  @override
  String get home => 'Главная';

  @override
  String get myBookings => 'Мои Бронирования';

  @override
  String get inbox => 'Входящие';

  @override
  String get account => 'Аккаунт';

  @override
  String get uploadPhoto => 'Загрузить Фото';

  @override
  String get changePhoto => 'Изменить Фото';

  @override
  String get camera => 'Камера';

  @override
  String get gallery => 'Галерея';

  @override
  String get takePhoto => 'Сделать Фото';

  @override
  String get chooseFromGallery => 'Выбрать из Галереи';

  @override
  String get removePhoto => 'Удалить Фото';

  @override
  String get selectRoute => 'Выберите маршрут для начала';

  @override
  String get selectRouteTitle => 'Select Route';

  @override
  String get selectStops => 'Select Stops';

  @override
  String get findRides => 'Find Rides';

  @override
  String get screenTitleRole => 'Role';

  @override
  String get screenTitleRoute => 'Route';

  @override
  String get screenTitleStopsTime => 'Stops & Time';

  @override
  String get screenTitleSeat => 'Seats';

  @override
  String get seatsHelperText =>
      'Tap seats to mark them available/unavailable for riders. (All available by default!)';

  @override
  String get driver => 'Водитель';

  @override
  String get rider => 'Пассажир';

  @override
  String get origin => 'Отправление';

  @override
  String get destination => 'Назначение';

  @override
  String get selectOrigin => 'Выбрать Отправление';

  @override
  String get selectDestination => 'Выбрать Назначение';

  @override
  String get departureTime => 'Время Отправления';

  @override
  String get arrivalTime => 'Время Прибытия';

  @override
  String get selectTime => 'Выбрать Время';

  @override
  String get seats => 'Места';

  @override
  String get selectSeats => 'Выбрать Места';

  @override
  String get chooseYourRoute => 'какой маршрут?';

  @override
  String get chooseYourSeats => 'Выберите свои места';

  @override
  String get availableSeats => 'null мест свободно';

  @override
  String get chooseYourSeat => 'Выберите ваше место';

  @override
  String get selectYourSeat => 'Выберите место';

  @override
  String get available => 'Свободно';

  @override
  String get unavailable => 'Недоступно';

  @override
  String seatsAvailable(int count) {
    return 'мест свободно';
  }

  @override
  String seatsSelected(int count) {
    return '$count мест выбрано';
  }

  @override
  String get chooseYourStops => 'Выберите Ваши Остановки';

  @override
  String get pickUpTime => 'Начало';

  @override
  String get dropOffTime => 'Конец';

  @override
  String get today => 'Сегодня';

  @override
  String get tomorrow => 'Завтра';

  @override
  String get done => 'Готово';

  @override
  String get cancel => 'Отменить';

  @override
  String get mon => 'Пн';

  @override
  String get tue => 'Вт';

  @override
  String get wed => 'Ср';

  @override
  String get thu => 'Чт';

  @override
  String get fri => 'Пт';

  @override
  String get sat => 'Сб';

  @override
  String get sun => 'Вс';

  @override
  String get jan => 'Янв';

  @override
  String get feb => 'Фев';

  @override
  String get mar => 'Мар';

  @override
  String get apr => 'Апр';

  @override
  String get may => 'Май';

  @override
  String get jun => 'Июн';

  @override
  String get jul => 'Июл';

  @override
  String get aug => 'Авг';

  @override
  String get sep => 'Сен';

  @override
  String get oct => 'Окт';

  @override
  String get nov => 'Ноя';

  @override
  String get dec => 'Дек';

  @override
  String get confirmBooking => 'Подтвердить Бронирование';

  @override
  String get bookingConfirmed => 'Бронирование Подтверждено!';

  @override
  String get back => 'Назад';

  @override
  String get next => 'Далее';

  @override
  String get save => 'Сохранить';

  @override
  String get saved => 'Сохранено';

  @override
  String get personalInformation => 'Личная Информация';

  @override
  String get name => 'Имя';

  @override
  String get surname => 'Фамилия';

  @override
  String get phoneNumber => 'Номер Телефона';

  @override
  String get email => 'Электронная Почта';

  @override
  String get enterName => 'Введите ваше имя';

  @override
  String get enterSurname => 'Введите вашу фамилию';

  @override
  String get enterPhone => 'Введите номер телефона';

  @override
  String get enterEmail => 'Введите ваш email';

  @override
  String get pleaseEnterName => 'Пожалуйста, введите ваше имя';

  @override
  String get pleaseEnterSurname => 'Пожалуйста, введите вашу фамилию';

  @override
  String get pleaseEnterPhone => 'Пожалуйста, введите номер телефона';

  @override
  String get pleaseEnterValidEmail =>
      'Пожалуйста, введите действительный email';

  @override
  String get informationSaved => 'Информация успешно сохранена!';

  @override
  String get vehicleInformation => 'Информация о Транспорте';

  @override
  String get brand => 'Марка';

  @override
  String get model => 'Модель';

  @override
  String get color => 'Цвет';

  @override
  String get licensePlate => 'Номерной Знак';

  @override
  String get selectBrand => 'Выбрать марку';

  @override
  String get selectModel => 'Выбрать модель';

  @override
  String get selectColor => 'Выбрать цвет';

  @override
  String get selectBrandFirst => 'Сначала выберите марку';

  @override
  String get enterLicensePlate => 'Введите номерной знак';

  @override
  String examplePlate(String plate) {
    return 'Пример: $plate';
  }

  @override
  String get pleaseSelectBrand => 'Пожалуйста, выберите марку';

  @override
  String get pleaseEnterPlate => 'Пожалуйста, введите номерной знак';

  @override
  String get vehicleSaved => 'Информация о транспорте успешно сохранена!';

  @override
  String get settings => 'Настройки';

  @override
  String get notifications => 'Уведомления';

  @override
  String get pushNotifications => 'Push-Уведомления';

  @override
  String get pushNotificationsDesc =>
      'Получать уведомления об обновлениях поездки';

  @override
  String get location => 'Местоположение';

  @override
  String get locationServices => 'Службы Определения Местоположения';

  @override
  String get locationServicesDesc =>
      'Разрешить приложению доступ к вашему местоположению';

  @override
  String get appearance => 'Внешний Вид';

  @override
  String get darkMode => 'Темный Режим';

  @override
  String get darkModeDesc => 'Использовать темную тему';

  @override
  String get language => 'Язык';

  @override
  String get selectLanguage => 'Выбрать Язык';

  @override
  String languageChanged(String language) {
    return 'Язык изменен на $language';
  }

  @override
  String get privacy => 'Конфиденциальность';

  @override
  String get privacyPolicy => 'Политика Конфиденциальности';

  @override
  String get termsOfService => 'Условия Использования';

  @override
  String get data => 'Данные';

  @override
  String get downloadMyData => 'Загрузить Мои Данные';

  @override
  String get clearCache => 'Очистить Кэш';

  @override
  String get clearCacheTitle => 'Очистить Кэш';

  @override
  String get clearCacheMessage =>
      'Вы уверены, что хотите очистить все кэшированные данные? Это действие нельзя отменить.';

  @override
  String get cacheCleared => 'Кэш успешно очищен';

  @override
  String get preparingData => 'Подготовка ваших данных для загрузки...';

  @override
  String version(String version) {
    return 'Версия $version';
  }

  @override
  String get rideHistory => 'История Поездок';

  @override
  String get help => 'Помощь';

  @override
  String get faq => 'ЧЗВ';

  @override
  String get support => 'Поддержка';

  @override
  String get helpAndSupport => 'Помощь и Поддержка';

  @override
  String get about => 'О Приложении';

  @override
  String get logout => 'Выйти';

  @override
  String get clearMyBookings => 'Очистить Мои Бронирования';

  @override
  String get deleteAccount => 'Удалить Аккаунт';

  @override
  String get white => 'Белый';

  @override
  String get black => 'Черный';

  @override
  String get silver => 'Серебристый';

  @override
  String get gray => 'Серый';

  @override
  String get red => 'Красный';

  @override
  String get blue => 'Синий';

  @override
  String get green => 'Зеленый';

  @override
  String get yellow => 'Желтый';

  @override
  String get orange => 'Оранжевый';

  @override
  String get brown => 'Коричневый';

  @override
  String get beige => 'Бежевый';

  @override
  String get gold => 'Золотой';

  @override
  String get purple => 'Фиолетовый';

  @override
  String get pink => 'Розовый';

  @override
  String get turquoise => 'Бирюзовый';

  @override
  String get bronze => 'Бронзовый';

  @override
  String get maroon => 'Темно-бордовый';

  @override
  String get navyBlue => 'Темно-синий';

  @override
  String get other => 'Другой';

  @override
  String get noBookingsYet => 'Пока нет бронирований.';

  @override
  String get passenger => 'Пассажир';

  @override
  String get bookingCompleted => 'Бронирование Завершено';

  @override
  String get completeBooking => 'Завершить Бронирование';

  @override
  String get postRide => 'Опубликовать Поездку';

  @override
  String get ridePosted => 'Поездка Опубликована';

  @override
  String get noAvailableSeats => 'Нет Свободных Мест';

  @override
  String get whenDoYouWantToTravel => 'Когда вы хотите путешествовать?';

  @override
  String get matchingRides => 'Подходящие Поездки';

  @override
  String get withDriver => 'С';

  @override
  String get atTime => 'в';

  @override
  String get upcoming => 'Предстоящие';

  @override
  String get ongoing => 'В Пути';

  @override
  String get archive => 'Архив';

  @override
  String get unarchive => 'Разархивировать';

  @override
  String get canceledRides => 'Отмененные';

  @override
  String get completed => 'Завершено';

  @override
  String get canceled => 'Отменено';

  @override
  String get suggestRoute => 'Предложить новый маршрут';

  @override
  String get suggestStop => 'Предложить новую остановку';

  @override
  String get areYouDriverOrRider => 'вы водитель или пассажир сегодня?';

  @override
  String get pickUpAndDropOff => 'откуда?';

  @override
  String get hintFromStop => 'выберите начальную остановку';

  @override
  String get chooseDropOffPoint => 'куда?';

  @override
  String get hintToStop => 'выберите конечную остановку';

  @override
  String get tapSeatsToChangeAvailability => 'нажмите для изменения';

  @override
  String get setYourTime => 'время?';

  @override
  String get hintTime => 'выберите время начала или окончания';

  @override
  String get incompleteProfile => 'Незавершенный Профиль';

  @override
  String get incompleteVehicleInfo => 'Неполная Информация о Транспорте';

  @override
  String get completeProfile => 'Заполнить Профиль';

  @override
  String get addVehicle => 'Добавить Транспорт';

  @override
  String get completePersonalInfoForBooking =>
      'Пожалуйста, заполните личную информацию (имя, фамилия, email, телефон) перед бронированием поездки.';

  @override
  String get completePersonalInfoForPosting =>
      'Пожалуйста, заполните личную информацию (имя, фамилия, email, телефон) перед публикацией поездки.';

  @override
  String get completeVehicleInfoForPosting =>
      'Пожалуйста, заполните информацию о транспорте (марка, модель, цвет, номер) перед публикацией поездки.';

  @override
  String get noMatchingRidesFound => 'Подходящие поездки не найдены';

  @override
  String get tryAdjustingTimeOrRoute => 'Попробуйте изменить время или маршрут';

  @override
  String get cannotBookOwnRide =>
      'Вы не можете бронировать места в своей поездке';

  @override
  String get thisIsYourRide =>
      'Это ваша поездка - вы не можете её забронировать';

  @override
  String get alreadyHaveRideScheduled =>
      'У вас уже запланирована поездка на это время';

  @override
  String get book => 'Забронировать';

  @override
  String get booked => 'Забронировано';

  @override
  String get noMessagesYet => 'Сообщений пока нет';

  @override
  String get messagesWillAppear =>
      'Сообщения появятся, когда вы забронируете поездку';

  @override
  String get startConversation => 'Начните разговор!';

  @override
  String get pleaseLoginToViewMessages =>
      'Войдите, чтобы просмотреть сообщения';

  @override
  String get bookARide => 'Забронировать Поездку';

  @override
  String get cancelRide => 'Отменить Поездку';

  @override
  String get archived => 'Архив';

  @override
  String get autoArchived => 'Автоархив';

  @override
  String get userArchived => 'Архив';

  @override
  String get message => 'Сообщение';

  @override
  String get rate => 'Оценить';

  @override
  String get yourRating => 'Ваша Оценка:';

  @override
  String rateUser(String userName) {
    return 'Оценить $userName';
  }

  @override
  String get selectQualitiesThatApply => 'Выберите подходящие качества';

  @override
  String get submitRating => 'Отправить Оценку';

  @override
  String get safe => 'Безопасный';

  @override
  String get punctual => 'Пунктуальный';

  @override
  String get clean => 'Чистый';

  @override
  String get polite => 'Вежливый';

  @override
  String get communicative => 'Коммуникабельный';

  @override
  String get suggestion => 'Suggestion';

  @override
  String get complaint => 'Complaint';

  @override
  String get question => 'Question';

  @override
  String get delete => 'Delete';

  @override
  String get conversationArchived => 'Разговор заархивирован';

  @override
  String get conversationDeleted => 'Conversation deleted';

  @override
  String get undo => 'Undo';

  @override
  String get newRouteSuggestion => 'New Route Suggestion';

  @override
  String get newStopSuggestion => 'New Stop Suggestion';

  @override
  String get hintRoleSelection =>
      'хочешь опубликовать поездку? выбери водитель! или хочешь найти поездку? выбери пассажир!';

  @override
  String get hintRoleSelectionLine1 =>
      'do you want to post a ride? choose driver!';

  @override
  String get hintRoleSelectionOr => 'or';

  @override
  String get hintRoleSelectionLine2 =>
      'do you want to get on a ride? choose rider!';

  @override
  String get hintRouteSelection => 'выберите маршрут, по которому вы поедете';

  @override
  String get hintOriginSelection => 'выберите начальную остановку';

  @override
  String get hintDestinationSelection => 'выберите конечную остановку';

  @override
  String get hintTimeSelection => 'выберите время начала или окончания';

  @override
  String get hintSeatSelectionDriver =>
      'нажмите на места, чтобы сделать их доступными для пассажиров';

  @override
  String get hintSeatSelectionRider => 'нажмите на место, чтобы забронировать';

  @override
  String get hintMatchingRides =>
      'эти водители соответствуют вашему маршруту и времени';

  @override
  String get hintPostRide => 'проверьте и подтвердите детали поездки';

  @override
  String systemNotificationDriverCanceled(String driverName, String routeName) {
    return '$driverName отменил поездку по маршруту $routeName';
  }

  @override
  String systemNotificationRiderCanceled(String riderName) {
    return '$riderName отменил бронирование';
  }

  @override
  String systemNotificationNewRider(String riderName, String driverName) {
    return '$riderName забронировал место в поездке $driverName';
  }

  @override
  String systemNotificationRiderBooked(String riderName, String driverName) {
    return '$riderName забронировал место в поездке $driverName';
  }

  @override
  String get snackbarAdminViewOnly =>
      'Администраторы могут только просматривать сообщения, но не отправлять их';

  @override
  String get snackbarMessagingExpired =>
      'Период обмена сообщениями истёк (3 дня после прибытия)';

  @override
  String get snackbarPleaseLoginToSuggestStop =>
      'Войдите, чтобы предложить остановку';

  @override
  String get snackbarPleaseLoginToSuggestRoute =>
      'Войдите, чтобы предложить маршрут';

  @override
  String get snackbarCannotBookOwnRideDetail =>
      'Вы не можете забронировать место в своей собственной поездке. Это противоречит нашим правилам.';

  @override
  String get snackbarAlreadyBookedThisRide =>
      'Вы уже забронировали эту поездку';

  @override
  String snackbarConflictingBooking(String routeName) {
    return 'У вас есть конфликтующее бронирование на это время: $routeName';
  }

  @override
  String snackbarSwitchedToUser(String userName) {
    return 'Переключено на $userName';
  }

  @override
  String get snackbarBookingsCleared => 'Все бронирования удалены';

  @override
  String get snackbarConversationsCleared => 'Все разговоры удалены';

  @override
  String get snackbarRatingsCleared => 'Все оценки удалены';

  @override
  String snackbarAlreadyRated(String userName) {
    return 'Вы уже оценили $userName за эту поездку';
  }

  @override
  String snackbarRatingSubmitted(String rating, String userName) {
    return 'Оценка отправлена: $rating звёзд для $userName';
  }

  @override
  String snackbarCopiedToClipboard(String label) {
    return '$label скопировано в буфер обмена';
  }

  @override
  String get snackbarCannotMessageYourself =>
      'Вы не можете отправить сообщение самому себе';

  @override
  String snackbarErrorOpeningChat(String error) {
    return 'Ошибка при открытии чата поддержки: $error';
  }

  @override
  String get snackbarConversationRestored => 'Разговор восстановлен';

  @override
  String get skip => 'Skip';

  @override
  String get getStarted => 'Get Started';

  @override
  String get introWelcomeTitle => 'Welcome to IndiBindi';

  @override
  String get introWelcomeSubtitle => 'Share rides, save money, travel together';

  @override
  String get introDriverTitle => 'Offer Rides';

  @override
  String get introDriverSubtitle =>
      'Post your journey and share costs with fellow travelers';

  @override
  String get introRiderTitle => 'Find Rides';

  @override
  String get introRiderSubtitle =>
      'Discover available rides and travel together';

  @override
  String get walkthroughRoleTitle => 'Choose Your Role';

  @override
  String get walkthroughRoleDescription =>
      'Select Driver to post rides or Rider to find rides. You can switch between roles anytime.';

  @override
  String get walkthroughRouteTitle => 'Select Your Route';

  @override
  String get walkthroughRouteDescription =>
      'Choose your route, then pick your origin and destination stops along the way.';

  @override
  String get walkthroughBookingTitle => 'Set Your Journey';

  @override
  String get walkthroughBookingDescription =>
      'Pick your travel date and time. Drivers can set available seats, riders can book them.';

  @override
  String get walkthroughMyBookingsTitle => 'Manage Bookings';

  @override
  String get walkthroughMyBookingsDescription =>
      'View and manage your upcoming, ongoing, and completed rides all in one place.';

  @override
  String get walkthroughMessagingTitle => 'Stay Connected';

  @override
  String get walkthroughMessagingDescription =>
      'Chat with drivers and riders to coordinate your trip and share updates.';

  @override
  String get tutorialSearchTitle1 => 'Choose Your Role';

  @override
  String get tutorialSearchDesc1 =>
      'Tap Driver to offer rides, or Rider to find and book rides. You can switch anytime!';

  @override
  String get tutorialSearchTitle2 => 'Select Route & Stops';

  @override
  String get tutorialSearchDesc2 =>
      'Pick your travel route, then choose your origin and destination stops.';

  @override
  String get tutorialSearchTitle3 => 'Set Time & Seats';

  @override
  String get tutorialSearchDesc3 =>
      'Choose when you want to travel. Drivers set available seats, riders select their seat.';

  @override
  String get tutorialBookingsTitle1 => 'Your Rides';

  @override
  String get tutorialBookingsDesc1 =>
      'View all your upcoming, ongoing, and completed rides in one place.';

  @override
  String get tutorialBookingsTitle2 => 'Manage Bookings';

  @override
  String get tutorialBookingsDesc2 =>
      'Tap any ride to see details, message participants, or cancel if needed.';

  @override
  String get tutorialInboxTitle1 => 'Your Messages';

  @override
  String get tutorialInboxDesc1 =>
      'Chat with drivers and riders to coordinate pickup details and share updates.';

  @override
  String get tutorialInboxTitle2 => 'Get Support';

  @override
  String get tutorialInboxDesc2 =>
      'Need help? Use the support options to ask questions or share feedback.';
}
