// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'IndiBindi';

  @override
  String get home => 'الرئيسية';

  @override
  String get myBookings => 'حجوزاتي';

  @override
  String get inbox => 'البريد الوارد';

  @override
  String get account => 'الحساب';

  @override
  String get uploadPhoto => 'رفع صورة';

  @override
  String get changePhoto => 'تغيير الصورة';

  @override
  String get camera => 'الكاميرا';

  @override
  String get gallery => 'المعرض';

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get chooseFromGallery => 'اختر من المعرض';

  @override
  String get removePhoto => 'إزالة الصورة';

  @override
  String get selectRoute => 'اختر مساراً للبدء';

  @override
  String get driver => 'السائق';

  @override
  String get rider => 'الراكب';

  @override
  String get origin => 'نقطة الانطلاق';

  @override
  String get destination => 'الوجهة';

  @override
  String get selectOrigin => 'اختر نقطة الانطلاق';

  @override
  String get selectDestination => 'اختر الوجهة';

  @override
  String get departureTime => 'وقت المغادرة';

  @override
  String get arrivalTime => 'وقت الوصول';

  @override
  String get selectTime => 'اختر الوقت';

  @override
  String get seats => 'المقاعد';

  @override
  String get selectSeats => 'اختر المقاعد';

  @override
  String get chooseYourRoute => 'أي طريق؟';

  @override
  String get chooseYourSeats => 'اختر مقاعدك';

  @override
  String get availableSeats => 'null مقاعد متاحة';

  @override
  String get chooseYourSeat => 'اختر مقعدك';

  @override
  String get selectYourSeat => 'اختر مقعدك';

  @override
  String get available => 'متاح';

  @override
  String get unavailable => 'غير متاح';

  @override
  String seatsAvailable(int count) {
    return 'مقاعد متاحة';
  }

  @override
  String seatsSelected(int count) {
    return '$count مقاعد محددة';
  }

  @override
  String get chooseYourStops => 'اختر محطاتك';

  @override
  String get pickUpTime => 'الاستلام';

  @override
  String get dropOffTime => 'التسليم';

  @override
  String get today => 'اليوم';

  @override
  String get tomorrow => 'غداً';

  @override
  String get done => 'تم';

  @override
  String get cancel => 'إلغاء';

  @override
  String get mon => 'الإثنين';

  @override
  String get tue => 'الثلاثاء';

  @override
  String get wed => 'الأربعاء';

  @override
  String get thu => 'الخميس';

  @override
  String get fri => 'الجمعة';

  @override
  String get sat => 'السبت';

  @override
  String get sun => 'الأحد';

  @override
  String get jan => 'يناير';

  @override
  String get feb => 'فبراير';

  @override
  String get mar => 'مارس';

  @override
  String get apr => 'أبريل';

  @override
  String get may => 'مايو';

  @override
  String get jun => 'يونيو';

  @override
  String get jul => 'يوليو';

  @override
  String get aug => 'أغسطس';

  @override
  String get sep => 'سبتمبر';

  @override
  String get oct => 'أكتوبر';

  @override
  String get nov => 'نوفمبر';

  @override
  String get dec => 'ديسمبر';

  @override
  String get confirmBooking => 'تأكيد الحجز';

  @override
  String get bookingConfirmed => 'تم تأكيد الحجز!';

  @override
  String get back => 'رجوع';

  @override
  String get next => 'التالي';

  @override
  String get save => 'حفظ';

  @override
  String get saved => 'تم الحفظ';

  @override
  String get personalInformation => 'المعلومات الشخصية';

  @override
  String get name => 'الاسم';

  @override
  String get surname => 'اللقب';

  @override
  String get phoneNumber => 'رقم الهاتف المحمول';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get enterName => 'أدخل اسمك';

  @override
  String get enterSurname => 'أدخل لقبك';

  @override
  String get enterPhone => 'أدخل رقم الهاتف';

  @override
  String get enterEmail => 'أدخل بريدك الإلكتروني';

  @override
  String get pleaseEnterName => 'الرجاء إدخال اسمك';

  @override
  String get pleaseEnterSurname => 'الرجاء إدخال لقبك';

  @override
  String get pleaseEnterPhone => 'الرجاء إدخال رقم الهاتف';

  @override
  String get pleaseEnterValidEmail => 'الرجاء إدخال بريد إلكتروني صحيح';

  @override
  String get informationSaved => 'تم حفظ المعلومات بنجاح!';

  @override
  String get vehicleInformation => 'معلومات المركبة';

  @override
  String get brand => 'العلامة التجارية';

  @override
  String get model => 'الطراز';

  @override
  String get color => 'اللون';

  @override
  String get licensePlate => 'لوحة الترخيص';

  @override
  String get selectBrand => 'اختر العلامة التجارية';

  @override
  String get selectModel => 'اختر الطراز';

  @override
  String get selectColor => 'اختر اللون';

  @override
  String get selectBrandFirst => 'اختر العلامة التجارية أولاً';

  @override
  String get enterLicensePlate => 'أدخل لوحة الترخيص';

  @override
  String examplePlate(String plate) {
    return 'مثال: $plate';
  }

  @override
  String get pleaseSelectBrand => 'الرجاء اختيار العلامة التجارية';

  @override
  String get pleaseEnterPlate => 'الرجاء إدخال لوحة الترخيص';

  @override
  String get vehicleSaved => 'تم حفظ معلومات المركبة بنجاح!';

  @override
  String get settings => 'الإعدادات';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get pushNotifications => 'الإشعارات الفورية';

  @override
  String get pushNotificationsDesc => 'تلقي إشعارات حول تحديثات الرحلة';

  @override
  String get location => 'الموقع';

  @override
  String get locationServices => 'خدمات الموقع';

  @override
  String get locationServicesDesc => 'السماح للتطبيق بالوصول إلى موقعك';

  @override
  String get appearance => 'المظهر';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get darkModeDesc => 'استخدام السمة الداكنة';

  @override
  String get language => 'اللغة';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String languageChanged(String language) {
    return 'تم تغيير اللغة إلى $language';
  }

  @override
  String get privacy => 'الخصوصية';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get data => 'البيانات';

  @override
  String get downloadMyData => 'تنزيل بياناتي';

  @override
  String get clearCache => 'مسح ذاكرة التخزين المؤقت';

  @override
  String get clearCacheTitle => 'مسح ذاكرة التخزين المؤقت';

  @override
  String get clearCacheMessage =>
      'هل أنت متأكد من أنك تريد مسح جميع البيانات المخزنة مؤقتاً؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get cacheCleared => 'تم مسح ذاكرة التخزين المؤقت بنجاح';

  @override
  String get preparingData => 'جاري تحضير بياناتك للتنزيل...';

  @override
  String version(String version) {
    return 'الإصدار $version';
  }

  @override
  String get rideHistory => 'سجل الرحلات';

  @override
  String get help => 'مساعدة';

  @override
  String get faq => 'الأسئلة الشائعة';

  @override
  String get support => 'الدعم';

  @override
  String get helpAndSupport => 'المساعدة والدعم';

  @override
  String get about => 'حول';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get clearMyBookings => 'مسح حجوزاتي';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get white => 'أبيض';

  @override
  String get black => 'أسود';

  @override
  String get silver => 'فضي';

  @override
  String get gray => 'رمادي';

  @override
  String get red => 'أحمر';

  @override
  String get blue => 'أزرق';

  @override
  String get green => 'أخضر';

  @override
  String get yellow => 'أصفر';

  @override
  String get orange => 'برتقالي';

  @override
  String get brown => 'بني';

  @override
  String get beige => 'بيج';

  @override
  String get gold => 'ذهبي';

  @override
  String get purple => 'بنفسجي';

  @override
  String get pink => 'وردي';

  @override
  String get turquoise => 'فيروزي';

  @override
  String get bronze => 'برونزي';

  @override
  String get maroon => 'كستنائي';

  @override
  String get navyBlue => 'أزرق داكن';

  @override
  String get other => 'آخر';

  @override
  String get noBookingsYet => 'لا توجد حجوزات حتى الآن.';

  @override
  String get passenger => 'راكب';

  @override
  String get bookingCompleted => 'اكتمل الحجز';

  @override
  String get completeBooking => 'إكمال الحجز';

  @override
  String get postRide => 'نشر رحلة';

  @override
  String get ridePosted => 'تم نشر الرحلة';

  @override
  String get noAvailableSeats => 'لا توجد مقاعد متاحة';

  @override
  String get whenDoYouWantToTravel => 'متى تريد السفر؟';

  @override
  String get matchingRides => 'الرحلات المطابقة';

  @override
  String get withDriver => 'مع';

  @override
  String get atTime => 'في';

  @override
  String get upcoming => 'القادمة';

  @override
  String get ongoing => 'جارية';

  @override
  String get archive => 'الأرشيف';

  @override
  String get unarchive => 'إلغاء الأرشفة';

  @override
  String get canceledRides => 'الملغاة';

  @override
  String get completed => 'مكتمل';

  @override
  String get canceled => 'ملغي';

  @override
  String get suggestRoute => 'اقتراح مسار جديد';

  @override
  String get suggestStop => 'اقتراح محطة جديدة';

  @override
  String get areYouDriverOrRider => 'هل أنت سائق أم راكب اليوم؟';

  @override
  String get pickUpAndDropOff => 'من أين؟';

  @override
  String get chooseDropOffPoint => 'إلى أين؟';

  @override
  String get tapSeatsToChangeAvailability => 'اضغط للتغيير';

  @override
  String get setYourTime => 'الوقت؟';

  @override
  String get incompleteProfile => 'ملف شخصي غير مكتمل';

  @override
  String get incompleteVehicleInfo => 'معلومات السيارة غير مكتملة';

  @override
  String get completeProfile => 'أكمل الملف الشخصي';

  @override
  String get addVehicle => 'إضافة سيارة';

  @override
  String get completePersonalInfoForBooking =>
      'يرجى إكمال معلوماتك الشخصية (الاسم، اللقب، البريد الإلكتروني، رقم الهاتف) قبل حجز رحلة.';

  @override
  String get completePersonalInfoForPosting =>
      'يرجى إكمال معلوماتك الشخصية (الاسم، اللقب، البريد الإلكتروني، رقم الهاتف) قبل نشر رحلة.';

  @override
  String get completeVehicleInfoForPosting =>
      'يرجى إكمال معلومات السيارة (العلامة التجارية، الموديل، اللون، رقم اللوحة) قبل نشر رحلة.';

  @override
  String get noMatchingRidesFound => 'لم يتم العثور على رحلات مطابقة';

  @override
  String get tryAdjustingTimeOrRoute => 'حاول تعديل الوقت أو المسار';

  @override
  String get cannotBookOwnRide => 'لا يمكنك حجز مقاعد في رحلتك الخاصة';

  @override
  String get thisIsYourRide => 'هذه رحلتك - لا يمكنك حجزها';

  @override
  String get alreadyHaveRideScheduled => 'لديك بالفعل رحلة مجدولة في هذا الوقت';

  @override
  String get book => 'احجز';

  @override
  String get booked => 'محجوز';

  @override
  String get noMessagesYet => 'لا توجد رسائل بعد';

  @override
  String get messagesWillAppear => 'ستظهر الرسائل عند حجز رحلة';

  @override
  String get startConversation => 'ابدأ محادثة!';

  @override
  String get pleaseLoginToViewMessages => 'يرجى تسجيل الدخول لعرض الرسائل';

  @override
  String get bookARide => 'حجز رحلة';

  @override
  String get cancelRide => 'إلغاء الرحلة';

  @override
  String get archived => 'مؤرشف';

  @override
  String get message => 'رسالة';

  @override
  String get rate => 'تقييم';

  @override
  String get yourRating => 'تقييمك:';

  @override
  String rateUser(String userName) {
    return 'تقييم $userName';
  }

  @override
  String get selectQualitiesThatApply => 'اختر الصفات المناسبة';

  @override
  String get submitRating => 'إرسال التقييم';

  @override
  String get safe => 'آمن';

  @override
  String get punctual => 'دقيق';

  @override
  String get clean => 'نظيف';

  @override
  String get polite => 'مؤدب';

  @override
  String get communicative => 'متواصل';

  @override
  String get suggestion => 'Suggestion';

  @override
  String get complaint => 'Complaint';

  @override
  String get delete => 'Delete';

  @override
  String get conversationArchived => 'تم أرشفة المحادثة';

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
      'تريد نشر رحلة؟ اختر سائق! أو تريد ركوب رحلة؟ اختر راكب!';

  @override
  String get hintRouteSelection => 'اختر المسار الذي ستسافر عليه';

  @override
  String get hintOriginSelection => 'من أين ستبدأ رحلتك؟';

  @override
  String get hintDestinationSelection => 'أين ستنتهي رحلتك؟';

  @override
  String get hintTimeSelection => 'متى تخطط للسفر؟';

  @override
  String get hintSeatSelectionDriver =>
      'اضغط على المقاعد لتحديدها متاحة للركاب';

  @override
  String get hintSeatSelectionRider => 'اضغط على مقعد لحجز مكانك';

  @override
  String get hintMatchingRides => 'هؤلاء السائقون يطابقون مسارك ووقتك';

  @override
  String get hintPostRide => 'راجع وأكد تفاصيل رحلتك';

  @override
  String systemNotificationDriverCanceled(String driverName, String routeName) {
    return '$driverName ألغى الرحلة على $routeName';
  }

  @override
  String systemNotificationRiderCanceled(String riderName) {
    return '$riderName ألغى حجزه';
  }

  @override
  String systemNotificationNewRider(String riderName, String driverName) {
    return '$riderName حجز مقعداً في رحلة $driverName';
  }

  @override
  String systemNotificationRiderBooked(String riderName, String driverName) {
    return '$riderName حجز مقعداً في رحلة $driverName';
  }

  @override
  String get snackbarAdminViewOnly =>
      'يمكن للمسؤولين عرض الرسائل فقط، وليس إرسالها';

  @override
  String get snackbarMessagingExpired =>
      'انتهت فترة المراسلة (3 أيام بعد الوصول)';

  @override
  String get snackbarPleaseLoginToSuggestStop =>
      'يرجى تسجيل الدخول لاقتراح محطة';

  @override
  String get snackbarPleaseLoginToSuggestRoute =>
      'يرجى تسجيل الدخول لاقتراح مسار';

  @override
  String get snackbarCannotBookOwnRideDetail =>
      'لا يمكنك حجز مقعد في رحلتك الخاصة. هذا مخالف للوائحنا.';

  @override
  String get snackbarAlreadyBookedThisRide => 'لقد حجزت هذه الرحلة مسبقاً';

  @override
  String snackbarConflictingBooking(String routeName) {
    return 'لديك حجز متعارض في هذا الوقت: $routeName';
  }

  @override
  String snackbarSwitchedToUser(String userName) {
    return 'تم التبديل إلى $userName';
  }

  @override
  String get snackbarBookingsCleared => 'تم مسح جميع الحجوزات';

  @override
  String get snackbarConversationsCleared => 'تم مسح جميع المحادثات';

  @override
  String get snackbarRatingsCleared => 'تم مسح جميع التقييمات';

  @override
  String snackbarAlreadyRated(String userName) {
    return 'لقد قيّمت $userName مسبقاً لهذه الرحلة';
  }

  @override
  String snackbarRatingSubmitted(String rating, String userName) {
    return 'تم إرسال التقييم: $rating نجوم لـ $userName';
  }

  @override
  String snackbarCopiedToClipboard(String label) {
    return 'تم نسخ $label إلى الحافظة';
  }

  @override
  String get snackbarCannotMessageYourself => 'لا يمكنك مراسلة نفسك';

  @override
  String snackbarErrorOpeningChat(String error) {
    return 'خطأ في فتح محادثة الدعم: $error';
  }

  @override
  String get snackbarConversationRestored => 'تمت استعادة المحادثة';
}
