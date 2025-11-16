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
  String get inbox => 'Inbox';

  @override
  String get account => 'Аккаунт';

  @override
  String get uploadPhoto => 'Upload Photo';

  @override
  String get changePhoto => 'Change Photo';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get removePhoto => 'Remove Photo';

  @override
  String get selectRoute => 'Выберите маршрут для начала';

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
  String get chooseYourRoute => 'Выберите Ваш Маршрут';

  @override
  String get chooseYourSeats => 'Выберите свои места';

  @override
  String get availableSeats => 'Available Seats';

  @override
  String get chooseYourSeat => 'Choose Your Seat';

  @override
  String get selectYourSeat => 'Select your seat';

  @override
  String seatsAvailable(int count) {
    return '$count seat(s) available';
  }

  @override
  String seatsSelected(int count) {
    return '$count seat(s) selected';
  }

  @override
  String get chooseYourStops => 'Выберите Ваши Остановки';

  @override
  String get pickUpTime => 'Время Посадки';

  @override
  String get dropOffTime => 'Время Высадки';

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
  String get help => 'Help';

  @override
  String get faq => 'FAQ';

  @override
  String get support => 'Support';

  @override
  String get helpAndSupport => 'Помощь и Поддержка';

  @override
  String get about => 'О Приложении';

  @override
  String get logout => 'Выйти';

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
}
