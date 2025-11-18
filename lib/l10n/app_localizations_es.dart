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
  String get inbox => 'Inbox';

  @override
  String get account => 'Cuenta';

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
  String get chooseYourRoute => 'Elija Su Ruta';

  @override
  String get chooseYourSeats => 'Elija sus asientos';

  @override
  String get availableSeats => 'Available Seats';

  @override
  String get chooseYourSeat => 'Choose Your Seat';

  @override
  String get selectYourSeat => 'Select your seat';

  @override
  String get available => 'available';

  @override
  String seatsAvailable(int count) {
    return '$count seat(s) available';
  }

  @override
  String seatsSelected(int count) {
    return '$count seat(s) selected';
  }

  @override
  String get chooseYourStops => 'Elija Sus Paradas';

  @override
  String get pickUpTime => 'Hora de Recogida';

  @override
  String get dropOffTime => 'Hora de Bajada';

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
  String get help => 'Help';

  @override
  String get faq => 'FAQ';

  @override
  String get support => 'Support';

  @override
  String get helpAndSupport => 'Ayuda y Soporte';

  @override
  String get about => 'Acerca de';

  @override
  String get logout => 'Cerrar Sesión';

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
}
