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
  String get uploadPhoto => 'Upload Photo';

  @override
  String get changePhoto => 'Fotoğraf Değiştir';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get takePhoto => 'Fotoğraf Çek';

  @override
  String get chooseFromGallery => 'Galeriden Seç';

  @override
  String get removePhoto => 'Remove Photo';

  @override
  String get selectRoute => 'Başlamak için bir rota seçin';

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
  String get chooseYourRoute => 'Rotanızı Seçin';

  @override
  String get chooseYourSeats => 'Koltuklarınızı seçin';

  @override
  String get availableSeats => 'Müsait Koltuklar';

  @override
  String get chooseYourSeat => 'Koltuğunuzu Seçin';

  @override
  String get selectYourSeat => 'Koltuğunuzu seçin';

  @override
  String get available => 'müsait';

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
  String get pickUpTime => 'Biniş Saati';

  @override
  String get dropOffTime => 'İniş Saati';

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
  String get help => 'Help';

  @override
  String get faq => 'FAQ';

  @override
  String get support => 'Support';

  @override
  String get helpAndSupport => 'Yardım ve Destek';

  @override
  String get about => 'Hakkında';

  @override
  String get logout => 'Çıkış Yap';

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
  String get noAvailableSeats => 'Müsait Koltuk Yok';

  @override
  String get whenDoYouWantToTravel => 'Ne zaman seyahat etmek istiyorsunuz?';

  @override
  String get matchingRides => 'Eşleşen Yolculuklar';

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
}
