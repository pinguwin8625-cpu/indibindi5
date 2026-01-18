// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'IndiBindi';

  @override
  String get home => 'Ara';

  @override
  String get myBookings => 'Rezervasyonlarım';

  @override
  String get inbox => 'Gelen Kutusu';

  @override
  String get account => 'Hesap';

  @override
  String get uploadPhoto => 'Fotoğraf Yükle';

  @override
  String get changePhoto => 'Fotoğraf Değiştir';

  @override
  String get camera => 'Kamera';

  @override
  String get gallery => 'Galeri';

  @override
  String get takePhoto => 'Fotoğraf Çek';

  @override
  String get chooseFromGallery => 'Galeriden Seç';

  @override
  String get removePhoto => 'Fotoğrafı Kaldır';

  @override
  String get selectRoute => 'Başlamak için bir rota seçin';

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
  String get driver => 'Sürücü';

  @override
  String get rider => 'Yolcu';

  @override
  String get origin => 'Başlangıç';

  @override
  String get destination => 'Varış';

  @override
  String get selectOrigin => 'Başlangıç Noktası Seçin';

  @override
  String get selectDestination => 'Varış Noktası Seçin';

  @override
  String get departureTime => 'Kalkış Saati';

  @override
  String get arrivalTime => 'Varış Saati';

  @override
  String get selectTime => 'Saat Seçin';

  @override
  String get seats => 'Koltuklar';

  @override
  String get selectSeats => 'Koltuk Seçin';

  @override
  String get chooseYourRoute => 'hangi rota?';

  @override
  String get chooseYourSeats => 'düzenlemek için koltuklara dokunun';

  @override
  String get availableSeats => 'Müsait Koltuklar';

  @override
  String get chooseYourSeat => 'Koltuğunuzu Seçin';

  @override
  String get selectYourSeat => 'Koltuğunuzu seçin';

  @override
  String get available => 'Müsait';

  @override
  String get unavailable => 'Müsait Değil';

  @override
  String seatsAvailable(int count) {
    return '$count koltuk müsait';
  }

  @override
  String seatsSelected(int count) {
    return '$count koltuk seçildi';
  }

  @override
  String get chooseYourStops => 'Duraklarınızı Seçin';

  @override
  String get pickUpTime => 'Başlangıç';

  @override
  String get dropOffTime => 'Bitiş';

  @override
  String get today => 'Bugün';

  @override
  String get tomorrow => 'Yarın';

  @override
  String get done => 'Tamam';

  @override
  String get cancel => 'İptal';

  @override
  String get mon => 'Pzt';

  @override
  String get tue => 'Sal';

  @override
  String get wed => 'Çar';

  @override
  String get thu => 'Per';

  @override
  String get fri => 'Cum';

  @override
  String get sat => 'Cmt';

  @override
  String get sun => 'Paz';

  @override
  String get jan => 'Oca';

  @override
  String get feb => 'Şub';

  @override
  String get mar => 'Mar';

  @override
  String get apr => 'Nis';

  @override
  String get may => 'May';

  @override
  String get jun => 'Haz';

  @override
  String get jul => 'Tem';

  @override
  String get aug => 'Ağu';

  @override
  String get sep => 'Eyl';

  @override
  String get oct => 'Eki';

  @override
  String get nov => 'Kas';

  @override
  String get dec => 'Ara';

  @override
  String get confirmBooking => 'Rezervasyonu Onayla';

  @override
  String get bookingConfirmed => 'Rezervasyon Onaylandı!';

  @override
  String get back => 'Geri';

  @override
  String get next => 'İleri';

  @override
  String get save => 'Kaydet';

  @override
  String get saved => 'Kaydedildi';

  @override
  String get personalInformation => 'Kişisel Bilgiler';

  @override
  String get name => 'Ad';

  @override
  String get surname => 'Soyad';

  @override
  String get phoneNumber => 'Cep Telefonu Numarası';

  @override
  String get email => 'E-posta Adresi';

  @override
  String get enterName => 'Adınızı girin';

  @override
  String get enterSurname => 'Soyadınızı girin';

  @override
  String get enterPhone => 'Telefon numarası girin';

  @override
  String get enterEmail => 'E-posta adresinizi girin';

  @override
  String get pleaseEnterName => 'Lütfen adınızı girin';

  @override
  String get pleaseEnterSurname => 'Lütfen soyadınızı girin';

  @override
  String get pleaseEnterPhone => 'Lütfen telefon numarası girin';

  @override
  String get pleaseEnterValidEmail => 'Lütfen geçerli bir e-posta girin';

  @override
  String get informationSaved => 'Bilgiler başarıyla kaydedildi!';

  @override
  String get vehicleInformation => 'Araç Bilgileri';

  @override
  String get brand => 'Marka';

  @override
  String get model => 'Model';

  @override
  String get color => 'Renk';

  @override
  String get licensePlate => 'Plaka';

  @override
  String get selectBrand => 'Marka seçin';

  @override
  String get selectModel => 'Model seçin';

  @override
  String get selectColor => 'Renk seçin';

  @override
  String get selectBrandFirst => 'Önce marka seçin';

  @override
  String get enterLicensePlate => 'Plaka girin';

  @override
  String examplePlate(String plate) {
    return 'Örnek: $plate';
  }

  @override
  String get pleaseSelectBrand => 'Lütfen marka seçin';

  @override
  String get pleaseEnterPlate => 'Lütfen plaka girin';

  @override
  String get vehicleSaved => 'Araç bilgileri başarıyla kaydedildi!';

  @override
  String get settings => 'Ayarlar';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get pushNotifications => 'Anlık Bildirimler';

  @override
  String get pushNotificationsDesc =>
      'Seyahat güncellemeleri hakkında bildirim alın';

  @override
  String get location => 'Konum';

  @override
  String get locationServices => 'Konum Servisleri';

  @override
  String get locationServicesDesc =>
      'Uygulamanın konumunuza erişmesine izin verin';

  @override
  String get appearance => 'Görünüm';

  @override
  String get darkMode => 'Karanlık Mod';

  @override
  String get darkModeDesc => 'Karanlık tema kullan';

  @override
  String get language => 'Dil';

  @override
  String get selectLanguage => 'Dil Seçin';

  @override
  String languageChanged(String language) {
    return 'Dil $language olarak değiştirildi';
  }

  @override
  String get privacy => 'Gizlilik';

  @override
  String get privacyPolicy => 'Gizlilik Politikası';

  @override
  String get termsOfService => 'Hizmet Şartları';

  @override
  String get data => 'Veri';

  @override
  String get downloadMyData => 'Verilerimi İndir';

  @override
  String get clearCache => 'Önbelleği Temizle';

  @override
  String get clearCacheTitle => 'Önbelleği Temizle';

  @override
  String get clearCacheMessage =>
      'Tüm önbelleğe alınmış verileri temizlemek istediğinizden emin misiniz? Bu işlem geri alınamaz.';

  @override
  String get cacheCleared => 'Önbellek başarıyla temizlendi';

  @override
  String get preparingData => 'Verileriniz indirme için hazırlanıyor...';

  @override
  String version(String version) {
    return 'Sürüm $version';
  }

  @override
  String get rideHistory => 'Seyahat Geçmişi';

  @override
  String get help => 'Yardım';

  @override
  String get faq => 'SSS';

  @override
  String get support => 'Destek';

  @override
  String get helpAndSupport => 'Yardım ve Destek';

  @override
  String get about => 'Hakkında';

  @override
  String get logout => 'Çıkış Yap';

  @override
  String get clearMyBookings => 'Rezervasyonlarımı Temizle';

  @override
  String get deleteAccount => 'Hesabı Sil';

  @override
  String get white => 'Beyaz';

  @override
  String get black => 'Siyah';

  @override
  String get silver => 'Gümüş';

  @override
  String get gray => 'Gri';

  @override
  String get red => 'Kırmızı';

  @override
  String get blue => 'Mavi';

  @override
  String get green => 'Yeşil';

  @override
  String get yellow => 'Sarı';

  @override
  String get orange => 'Turuncu';

  @override
  String get brown => 'Kahverengi';

  @override
  String get beige => 'Bej';

  @override
  String get gold => 'Altın';

  @override
  String get purple => 'Mor';

  @override
  String get pink => 'Pembe';

  @override
  String get turquoise => 'Turkuaz';

  @override
  String get bronze => 'Bronz';

  @override
  String get maroon => 'Bordo';

  @override
  String get navyBlue => 'Lacivert';

  @override
  String get other => 'Diğer';

  @override
  String get noBookingsYet => 'Henüz rezervasyon yok.';

  @override
  String get passenger => 'Yolcu';

  @override
  String get bookingCompleted => 'Rezervasyon Tamamlandı';

  @override
  String get completeBooking => 'Rezervasyonu Tamamla';

  @override
  String get postRide => 'Yolculuk Yayınla';

  @override
  String get ridePosted => 'Yolculuk Yayınlandı';

  @override
  String get noAvailableSeats => 'Müsait Koltuk Yok';

  @override
  String get whenDoYouWantToTravel => 'Ne zaman seyahat etmek istiyorsunuz?';

  @override
  String get matchingRides => 'Eşleşen Yolculuklar';

  @override
  String get chooseASeatOnMatchingRides => 'Koltuk Seçin';

  @override
  String get withDriver => 'ile';

  @override
  String get atTime => 'saat';

  @override
  String get upcoming => 'Yaklaşan';

  @override
  String get ongoing => 'Devam Eden';

  @override
  String get archive => 'Arşiv';

  @override
  String get unarchive => 'Arşivden Çıkar';

  @override
  String get canceledRides => 'İptal Edilen';

  @override
  String get completed => 'Tamamlanan';

  @override
  String get canceled => 'İptal Edildi';

  @override
  String get suggestRoute => 'Yeni güzergah öner';

  @override
  String get suggestStop => 'Yeni durak öner';

  @override
  String get areYouDriverOrRider => 'bugün sürücü müsün yoksa yolcu mu?';

  @override
  String get pickUpAndDropOff => 'nereden?';

  @override
  String get hintFromStop => 'başlangıç durağınızı seçin';

  @override
  String get chooseDropOffPoint => 'nereye?';

  @override
  String get hintToStop => 'bitiş durağınızı seçin';

  @override
  String get tapSeatsToChangeAvailability => 'koltukları düzenlemek için dokun';

  @override
  String get setYourTime => 'ne zaman?';

  @override
  String get hintTime => 'başlangıç veya bitiş saati seçin';

  @override
  String get incompleteProfile => 'Eksik Profil';

  @override
  String get incompleteVehicleInfo => 'Eksik Araç Bilgisi';

  @override
  String get completeProfile => 'Profili Tamamla';

  @override
  String get addVehicle => 'Araç Ekle';

  @override
  String get completePersonalInfoForBooking =>
      'Yolculuk rezervasyonu yapmadan önce lütfen kişisel bilgilerinizi (ad, soyad, e-posta, telefon numarası) tamamlayın.';

  @override
  String get completePersonalInfoForPosting =>
      'Yolculuk yayınlamadan önce lütfen kişisel bilgilerinizi (ad, soyad, e-posta, telefon numarası) tamamlayın.';

  @override
  String get completeVehicleInfoForPosting =>
      'Yolculuk yayınlamadan önce lütfen araç bilgilerinizi (marka, model, renk, plaka) tamamlayın.';

  @override
  String get noMatchingRidesFound => 'Eşleşen yolculuk bulunamadı';

  @override
  String get tryAdjustingTimeOrRoute =>
      'Saatinizi veya güzergahınızı ayarlamayı deneyin';

  @override
  String get cannotBookOwnRide =>
      'Kendi yolculuğunuza rezervasyon yapamazsınız';

  @override
  String get thisIsYourRide =>
      'Bu sizin yolculuğunuz - rezervasyon yapamazsınız';

  @override
  String get alreadyHaveRideScheduled =>
      'Bu saatte zaten planlanmış bir yolculuğunuz var';

  @override
  String get book => 'Rezerve Et';

  @override
  String get booked => 'Rezerve Edildi';

  @override
  String get pending => 'Bekleyen';

  @override
  String get noMessagesYet => 'Henüz mesaj yok';

  @override
  String get messagesWillAppear =>
      'Yolculuk rezervasyonu yaptığınızda mesajlar görünecek';

  @override
  String get startConversation => 'Bir sohbet başlatın!';

  @override
  String get pleaseLoginToViewMessages => 'Mesajları görmek için giriş yapın';

  @override
  String get bookARide => 'Yolculuk Rezerve Et';

  @override
  String get cancelRide => 'Yolculuğu İptal Et';

  @override
  String get archived => 'Arşivlenmiş';

  @override
  String get autoArchived => 'Otomatik arşivlendi';

  @override
  String get userArchived => 'Arşivlendi';

  @override
  String get message => 'Mesaj';

  @override
  String get rate => 'Değerlendir';

  @override
  String get yourRating => 'Değerlendirmeniz:';

  @override
  String rateUser(String userName) {
    return '$userName\'i Değerlendir';
  }

  @override
  String get selectQualitiesThatApply => 'Geçerli olan nitelikleri seçin';

  @override
  String get submitRating => 'Değerlendirmeyi Gönder';

  @override
  String get safe => 'Güvenli';

  @override
  String get punctual => 'Dakik';

  @override
  String get clean => 'Temiz';

  @override
  String get polite => 'Kibar';

  @override
  String get communicative => 'İletişim Kurabilen';

  @override
  String get suggestion => 'Suggestion';

  @override
  String get complaint => 'Complaint';

  @override
  String get question => 'Question';

  @override
  String get delete => 'Delete';

  @override
  String get conversationArchived => 'Konuşma arşivlendi';

  @override
  String get conversationUnarchived => 'Conversation unarchived';

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
      'yolculuk paylaşmak mı istiyorsun? sürücü seç! yoksa yolculuğa katılmak mı istiyorsun? yolcu seç!';

  @override
  String get hintRoleSelectionLine1 =>
      'do you want to post a ride? choose driver!';

  @override
  String get hintRoleSelectionOr => 'or';

  @override
  String get hintRoleSelectionLine2 =>
      'do you want to get on a ride? choose rider!';

  @override
  String get hintRouteSelection => 'seyahat edeceğiniz güzergahı seçin';

  @override
  String get hintOriginSelection => 'başlangıç durağınızı seçin';

  @override
  String get hintDestinationSelection => 'bitiş durağınızı seçin';

  @override
  String get hintTimeSelection => 'başlangıç veya bitiş saati seçin';

  @override
  String get hintSeatSelectionDriver =>
      'Koltuklara dokunarak müsaitliğini düzenleyebilirsiniz';

  @override
  String get hintSeatSelectionRider =>
      'yerinizi ayırtmak için bir koltuğa dokunun';

  @override
  String get hintMatchingRides =>
      'bu sürücüler güzergahınız ve saatinizle eşleşiyor';

  @override
  String get hintPostRide =>
      'yolculuk detaylarınızı gözden geçirin ve onaylayın';

  @override
  String systemNotificationDriverCanceled(String driverName, String routeName) {
    return '$driverName, $routeName güzergahındaki yolculuğu iptal etti';
  }

  @override
  String systemNotificationRiderCanceled(String riderName) {
    return '$riderName rezervasyonunu iptal etti';
  }

  @override
  String systemNotificationNewRider(String riderName, String driverName) {
    return '$riderName, $driverName\'in yolculuğuna koltuk rezerve etti';
  }

  @override
  String systemNotificationRiderBooked(String riderName, String driverName) {
    return '$riderName, $driverName\'in yolculuğuna koltuk rezerve etti';
  }

  @override
  String systemNotificationPreBooking(String riderName, String driverName) {
    return '$riderName, $driverName ile iletişime geçti';
  }

  @override
  String get snackbarAdminViewOnly =>
      'Yöneticiler yalnızca mesajları görüntüleyebilir, gönderemez';

  @override
  String get snackbarMessagingExpired =>
      'Mesajlaşma süresi doldu (varıştan 3 gün sonra)';

  @override
  String get snackbarPleaseLoginToSuggestStop =>
      'Durak önermek için giriş yapın';

  @override
  String get snackbarPleaseLoginToSuggestRoute =>
      'Güzergah önermek için giriş yapın';

  @override
  String get snackbarCannotBookOwnRideDetail =>
      'Kendi yolculuğunuza koltuk rezerve edemezsiniz. Bu kurallarımıza aykırıdır.';

  @override
  String get snackbarAlreadyBookedThisRide =>
      'Bu yolculuğu zaten rezerve ettiniz';

  @override
  String snackbarConflictingBooking(String routeName) {
    return 'Bu saatte çakışan bir rezervasyonunuz var: $routeName';
  }

  @override
  String snackbarSwitchedToUser(String userName) {
    return '$userName kullanıcısına geçildi';
  }

  @override
  String get snackbarBookingsCleared => 'Tüm rezervasyonlar silindi';

  @override
  String get snackbarConversationsCleared => 'Tüm konuşmalar silindi';

  @override
  String get snackbarRatingsCleared => 'Tüm değerlendirmeler silindi';

  @override
  String snackbarAlreadyRated(String userName) {
    return 'Bu yolculuk için $userName kullanıcısını zaten değerlendirdiniz';
  }

  @override
  String snackbarRatingSubmitted(String rating, String userName) {
    return 'Değerlendirme gönderildi: $userName için $rating yıldız';
  }

  @override
  String snackbarCopiedToClipboard(String label) {
    return '$label panoya kopyalandı';
  }

  @override
  String get snackbarCannotMessageYourself => 'Kendinize mesaj gönderemezsiniz';

  @override
  String snackbarErrorOpeningChat(String error) {
    return 'Destek sohbeti açılırken hata oluştu: $error';
  }

  @override
  String get snackbarConversationRestored => 'Konuşma geri yüklendi';

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
