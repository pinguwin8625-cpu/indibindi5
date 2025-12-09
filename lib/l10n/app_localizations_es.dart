// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'IndiBindi';

  @override
  String get home => 'Inicio';

  @override
  String get myBookings => 'Mis Reservas';

  @override
  String get inbox => 'Bandeja de Entrada';

  @override
  String get account => 'Cuenta';

  @override
  String get uploadPhoto => 'Subir Foto';

  @override
  String get changePhoto => 'Cambiar Foto';

  @override
  String get camera => 'Cámara';

  @override
  String get gallery => 'Galería';

  @override
  String get takePhoto => 'Tomar Foto';

  @override
  String get chooseFromGallery => 'Elegir de la Galería';

  @override
  String get removePhoto => 'Eliminar Foto';

  @override
  String get selectRoute => 'Selecciona una ruta para comenzar';

  @override
  String get driver => 'Conductor';

  @override
  String get rider => 'Pasajero';

  @override
  String get origin => 'Origen';

  @override
  String get destination => 'Destino';

  @override
  String get selectOrigin => 'Seleccionar Origen';

  @override
  String get selectDestination => 'Seleccionar Destino';

  @override
  String get departureTime => 'Hora de Salida';

  @override
  String get arrivalTime => 'Hora de Llegada';

  @override
  String get selectTime => 'Seleccionar Hora';

  @override
  String get seats => 'Asientos';

  @override
  String get selectSeats => 'Elegir Asientos';

  @override
  String get chooseYourRoute => '¿qué ruta?';

  @override
  String get chooseYourSeats => 'Elija sus asientos';

  @override
  String get availableSeats => 'null asientos disponibles';

  @override
  String get chooseYourSeat => 'Elige tu asiento';

  @override
  String get selectYourSeat => 'Selecciona tu asiento';

  @override
  String get available => 'Disponible';

  @override
  String get unavailable => 'No Disponible';

  @override
  String seatsAvailable(int count) {
    return 'asientos disponibles';
  }

  @override
  String seatsSelected(int count) {
    return '$count asientos seleccionados';
  }

  @override
  String get chooseYourStops => 'Elija Sus Paradas';

  @override
  String get pickUpTime => 'Recogida';

  @override
  String get dropOffTime => 'Bajada';

  @override
  String get today => 'Hoy';

  @override
  String get tomorrow => 'Mañana';

  @override
  String get done => 'Listo';

  @override
  String get cancel => 'Cancelar';

  @override
  String get mon => 'Lun';

  @override
  String get tue => 'Mar';

  @override
  String get wed => 'Mié';

  @override
  String get thu => 'Jue';

  @override
  String get fri => 'Vie';

  @override
  String get sat => 'Sáb';

  @override
  String get sun => 'Dom';

  @override
  String get jan => 'Ene';

  @override
  String get feb => 'Feb';

  @override
  String get mar => 'Mar';

  @override
  String get apr => 'Abr';

  @override
  String get may => 'May';

  @override
  String get jun => 'Jun';

  @override
  String get jul => 'Jul';

  @override
  String get aug => 'Ago';

  @override
  String get sep => 'Sep';

  @override
  String get oct => 'Oct';

  @override
  String get nov => 'Nov';

  @override
  String get dec => 'Dic';

  @override
  String get confirmBooking => 'Confirmar Reserva';

  @override
  String get bookingConfirmed => '¡Reserva Confirmada!';

  @override
  String get back => 'Atrás';

  @override
  String get next => 'Siguiente';

  @override
  String get save => 'Guardar';

  @override
  String get saved => 'Guardado';

  @override
  String get personalInformation => 'Información Personal';

  @override
  String get name => 'Nombre';

  @override
  String get surname => 'Apellido';

  @override
  String get phoneNumber => 'Número de Teléfono';

  @override
  String get email => 'Correo Electrónico';

  @override
  String get enterName => 'Ingrese su nombre';

  @override
  String get enterSurname => 'Ingrese su apellido';

  @override
  String get enterPhone => 'Ingrese número de teléfono';

  @override
  String get enterEmail => 'Ingrese su correo electrónico';

  @override
  String get pleaseEnterName => 'Por favor ingrese su nombre';

  @override
  String get pleaseEnterSurname => 'Por favor ingrese su apellido';

  @override
  String get pleaseEnterPhone => 'Por favor ingrese número de teléfono';

  @override
  String get pleaseEnterValidEmail => 'Por favor ingrese un correo válido';

  @override
  String get informationSaved => '¡Información guardada exitosamente!';

  @override
  String get vehicleInformation => 'Información del Vehículo';

  @override
  String get brand => 'Marca';

  @override
  String get model => 'Modelo';

  @override
  String get color => 'Color';

  @override
  String get licensePlate => 'Matrícula';

  @override
  String get selectBrand => 'Seleccionar marca';

  @override
  String get selectModel => 'Seleccionar modelo';

  @override
  String get selectColor => 'Seleccionar color';

  @override
  String get selectBrandFirst => 'Seleccione primero una marca';

  @override
  String get enterLicensePlate => 'Ingrese matrícula';

  @override
  String examplePlate(String plate) {
    return 'Ejemplo: $plate';
  }

  @override
  String get pleaseSelectBrand => 'Por favor seleccione una marca';

  @override
  String get pleaseEnterPlate => 'Por favor ingrese matrícula';

  @override
  String get vehicleSaved => '¡Información del vehículo guardada exitosamente!';

  @override
  String get settings => 'Configuración';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get pushNotifications => 'Notificaciones Push';

  @override
  String get pushNotificationsDesc =>
      'Recibir notificaciones sobre actualizaciones de viajes';

  @override
  String get location => 'Ubicación';

  @override
  String get locationServices => 'Servicios de Ubicación';

  @override
  String get locationServicesDesc =>
      'Permitir que la aplicación acceda a su ubicación';

  @override
  String get appearance => 'Apariencia';

  @override
  String get darkMode => 'Modo Oscuro';

  @override
  String get darkModeDesc => 'Usar tema oscuro';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Seleccionar Idioma';

  @override
  String languageChanged(String language) {
    return 'Idioma cambiado a $language';
  }

  @override
  String get privacy => 'Privacidad';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get termsOfService => 'Términos de Servicio';

  @override
  String get data => 'Datos';

  @override
  String get downloadMyData => 'Descargar Mis Datos';

  @override
  String get clearCache => 'Limpiar Caché';

  @override
  String get clearCacheTitle => 'Limpiar Caché';

  @override
  String get clearCacheMessage =>
      '¿Está seguro de que desea borrar todos los datos en caché? Esta acción no se puede deshacer.';

  @override
  String get cacheCleared => 'Caché limpiado exitosamente';

  @override
  String get preparingData => 'Preparando sus datos para descargar...';

  @override
  String version(String version) {
    return 'Versión $version';
  }

  @override
  String get rideHistory => 'Historial de Viajes';

  @override
  String get help => 'Ayuda';

  @override
  String get faq => 'FAQ';

  @override
  String get support => 'Soporte';

  @override
  String get helpAndSupport => 'Ayuda y Soporte';

  @override
  String get about => 'Acerca de';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get clearMyBookings => 'Borrar Mis Reservas';

  @override
  String get deleteAccount => 'Eliminar Cuenta';

  @override
  String get white => 'Blanco';

  @override
  String get black => 'Negro';

  @override
  String get silver => 'Plateado';

  @override
  String get gray => 'Gris';

  @override
  String get red => 'Rojo';

  @override
  String get blue => 'Azul';

  @override
  String get green => 'Verde';

  @override
  String get yellow => 'Amarillo';

  @override
  String get orange => 'Naranja';

  @override
  String get brown => 'Marrón';

  @override
  String get beige => 'Beige';

  @override
  String get gold => 'Dorado';

  @override
  String get purple => 'Púrpura';

  @override
  String get pink => 'Rosa';

  @override
  String get turquoise => 'Turquesa';

  @override
  String get bronze => 'Bronce';

  @override
  String get maroon => 'Granate';

  @override
  String get navyBlue => 'Azul Marino';

  @override
  String get other => 'Otro';

  @override
  String get noBookingsYet => 'Aún no hay reservas.';

  @override
  String get passenger => 'Pasajero';

  @override
  String get bookingCompleted => 'Reserva Completada';

  @override
  String get completeBooking => 'Completar Reserva';

  @override
  String get postRide => 'Publicar Viaje';

  @override
  String get ridePosted => 'Viaje Publicado';

  @override
  String get noAvailableSeats => 'No Hay Asientos Disponibles';

  @override
  String get whenDoYouWantToTravel => '¿Cuándo quieres viajar?';

  @override
  String get matchingRides => 'Viajes Coincidentes';

  @override
  String get withDriver => 'Con';

  @override
  String get atTime => 'a las';

  @override
  String get upcoming => 'Próximos';

  @override
  String get ongoing => 'En Curso';

  @override
  String get archive => 'Archivo';

  @override
  String get unarchive => 'Desarchivar';

  @override
  String get canceledRides => 'Cancelados';

  @override
  String get completed => 'Completado';

  @override
  String get canceled => 'Cancelado';

  @override
  String get suggestRoute => 'Sugerir una nueva ruta';

  @override
  String get suggestStop => 'Sugerir una nueva parada';

  @override
  String get areYouDriverOrRider => '¿eres conductor o pasajero hoy?';

  @override
  String get pickUpAndDropOff => '¿desde?';

  @override
  String get chooseDropOffPoint => '¿hasta?';

  @override
  String get tapSeatsToChangeAvailability => 'toca para cambiar';

  @override
  String get setYourTime => '¿hora?';

  @override
  String get incompleteProfile => 'Perfil Incompleto';

  @override
  String get incompleteVehicleInfo => 'Info de Vehículo Incompleta';

  @override
  String get completeProfile => 'Completar Perfil';

  @override
  String get addVehicle => 'Agregar Vehículo';

  @override
  String get completePersonalInfoForBooking =>
      'Por favor completa tu información personal (nombre, apellido, correo, teléfono) antes de reservar un viaje.';

  @override
  String get completePersonalInfoForPosting =>
      'Por favor completa tu información personal (nombre, apellido, correo, teléfono) antes de publicar un viaje.';

  @override
  String get completeVehicleInfoForPosting =>
      'Por favor completa la información de tu vehículo (marca, modelo, color, matrícula) antes de publicar un viaje.';

  @override
  String get noMatchingRidesFound => 'No se encontraron viajes coincidentes';

  @override
  String get tryAdjustingTimeOrRoute => 'Intenta ajustar la hora o la ruta';

  @override
  String get cannotBookOwnRide =>
      'No puedes reservar asientos en tu propio viaje';

  @override
  String get thisIsYourRide => 'Este es tu viaje - no puedes reservarlo';

  @override
  String get alreadyHaveRideScheduled =>
      'Ya tienes un viaje programado a esta hora';

  @override
  String get book => 'Reservar';

  @override
  String get booked => 'Reservado';

  @override
  String get noMessagesYet => 'Aún no hay mensajes';

  @override
  String get messagesWillAppear =>
      'Los mensajes aparecerán cuando reserves un viaje';

  @override
  String get startConversation => '¡Inicia una conversación!';

  @override
  String get pleaseLoginToViewMessages => 'Inicia sesión para ver los mensajes';

  @override
  String get bookARide => 'Reservar un Viaje';

  @override
  String get cancelRide => 'Cancelar Viaje';
}
