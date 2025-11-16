// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'IndiBindi';

  @override
  String get home => '홈';

  @override
  String get myBookings => '내 예약';

  @override
  String get inbox => 'Inbox';

  @override
  String get account => '계정';

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
  String get selectRoute => '경로를 선택하여 시작하세요';

  @override
  String get driver => '운전자';

  @override
  String get rider => '승객';

  @override
  String get origin => '출발지';

  @override
  String get destination => '목적지';

  @override
  String get selectOrigin => '출발지 선택';

  @override
  String get selectDestination => '목적지 선택';

  @override
  String get departureTime => '출발 시간';

  @override
  String get arrivalTime => '도착 시간';

  @override
  String get selectTime => '시간 선택';

  @override
  String get seats => '좌석';

  @override
  String get selectSeats => '좌석 선택';

  @override
  String get chooseYourRoute => '경로를 선택하세요';

  @override
  String get chooseYourSeats => '좌석을 선택하세요';

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
  String get chooseYourStops => '정류장을 선택하세요';

  @override
  String get pickUpTime => '탑승 시간';

  @override
  String get dropOffTime => '하차 시간';

  @override
  String get today => '오늘';

  @override
  String get tomorrow => '내일';

  @override
  String get done => '완료';

  @override
  String get cancel => '취소';

  @override
  String get mon => '월';

  @override
  String get tue => '화';

  @override
  String get wed => '수';

  @override
  String get thu => '목';

  @override
  String get fri => '금';

  @override
  String get sat => '토';

  @override
  String get sun => '일';

  @override
  String get jan => '1월';

  @override
  String get feb => '2월';

  @override
  String get mar => '3월';

  @override
  String get apr => '4월';

  @override
  String get may => '5월';

  @override
  String get jun => '6월';

  @override
  String get jul => '7월';

  @override
  String get aug => '8월';

  @override
  String get sep => '9월';

  @override
  String get oct => '10월';

  @override
  String get nov => '11월';

  @override
  String get dec => '12월';

  @override
  String get confirmBooking => '예약 확인';

  @override
  String get bookingConfirmed => '예약이 확인되었습니다!';

  @override
  String get back => '뒤로';

  @override
  String get next => '다음';

  @override
  String get save => '저장';

  @override
  String get saved => '저장됨';

  @override
  String get personalInformation => '개인 정보';

  @override
  String get name => '이름';

  @override
  String get surname => '성';

  @override
  String get phoneNumber => '휴대전화번호';

  @override
  String get email => '이메일 주소';

  @override
  String get enterName => '이름을 입력하세요';

  @override
  String get enterSurname => '성을 입력하세요';

  @override
  String get enterPhone => '전화번호를 입력하세요';

  @override
  String get enterEmail => '이메일을 입력하세요';

  @override
  String get pleaseEnterName => '이름을 입력해주세요';

  @override
  String get pleaseEnterSurname => '성을 입력해주세요';

  @override
  String get pleaseEnterPhone => '전화번호를 입력해주세요';

  @override
  String get pleaseEnterValidEmail => '유효한 이메일을 입력해주세요';

  @override
  String get informationSaved => '정보가 성공적으로 저장되었습니다!';

  @override
  String get vehicleInformation => '차량 정보';

  @override
  String get brand => '브랜드';

  @override
  String get model => '모델';

  @override
  String get color => '색상';

  @override
  String get licensePlate => '번호판';

  @override
  String get selectBrand => '브랜드 선택';

  @override
  String get selectModel => '모델 선택';

  @override
  String get selectColor => '색상 선택';

  @override
  String get selectBrandFirst => '먼저 브랜드를 선택하세요';

  @override
  String get enterLicensePlate => '번호판 입력';

  @override
  String examplePlate(String plate) {
    return '예: $plate';
  }

  @override
  String get pleaseSelectBrand => '브랜드를 선택해주세요';

  @override
  String get pleaseEnterPlate => '번호판을 입력해주세요';

  @override
  String get vehicleSaved => '차량 정보가 성공적으로 저장되었습니다!';

  @override
  String get settings => '설정';

  @override
  String get notifications => '알림';

  @override
  String get pushNotifications => '푸시 알림';

  @override
  String get pushNotificationsDesc => '승차 업데이트에 대한 알림 받기';

  @override
  String get location => '위치';

  @override
  String get locationServices => '위치 서비스';

  @override
  String get locationServicesDesc => '앱이 위치에 액세스하도록 허용';

  @override
  String get appearance => '외관';

  @override
  String get darkMode => '다크 모드';

  @override
  String get darkModeDesc => '다크 테마 사용';

  @override
  String get language => '언어';

  @override
  String get selectLanguage => '언어 선택';

  @override
  String languageChanged(String language) {
    return '언어가 $language(으)로 변경되었습니다';
  }

  @override
  String get privacy => '개인정보';

  @override
  String get privacyPolicy => '개인정보 처리방침';

  @override
  String get termsOfService => '서비스 약관';

  @override
  String get data => '데이터';

  @override
  String get downloadMyData => '내 데이터 다운로드';

  @override
  String get clearCache => '캐시 지우기';

  @override
  String get clearCacheTitle => '캐시 지우기';

  @override
  String get clearCacheMessage => '모든 캐시 데이터를 지우시겠습니까? 이 작업은 취소할 수 없습니다.';

  @override
  String get cacheCleared => '캐시가 성공적으로 지워졌습니다';

  @override
  String get preparingData => '다운로드를 위해 데이터를 준비하는 중...';

  @override
  String version(String version) {
    return '버전 $version';
  }

  @override
  String get rideHistory => '승차 기록';

  @override
  String get help => 'Help';

  @override
  String get faq => 'FAQ';

  @override
  String get support => 'Support';

  @override
  String get helpAndSupport => '도움말 및 지원';

  @override
  String get about => '정보';

  @override
  String get logout => '로그아웃';

  @override
  String get deleteAccount => '계정 삭제';

  @override
  String get white => '흰색';

  @override
  String get black => '검정색';

  @override
  String get silver => '은색';

  @override
  String get gray => '회색';

  @override
  String get red => '빨간색';

  @override
  String get blue => '파란색';

  @override
  String get green => '녹색';

  @override
  String get yellow => '노란색';

  @override
  String get orange => '주황색';

  @override
  String get brown => '갈색';

  @override
  String get beige => '베이지색';

  @override
  String get gold => '금색';

  @override
  String get purple => '보라색';

  @override
  String get pink => '분홍색';

  @override
  String get turquoise => '청록색';

  @override
  String get bronze => '청동색';

  @override
  String get maroon => '적갈색';

  @override
  String get navyBlue => '네이비 블루';

  @override
  String get other => '기타';

  @override
  String get noBookingsYet => '아직 예약이 없습니다.';

  @override
  String get passenger => '승객';

  @override
  String get bookingCompleted => '예약 완료';

  @override
  String get completeBooking => '예약 완료하기';

  @override
  String get noAvailableSeats => '사용 가능한 좌석 없음';

  @override
  String get whenDoYouWantToTravel => '언제 여행하고 싶으세요?';

  @override
  String get matchingRides => '일치하는 탑승';

  @override
  String get withDriver => '와 함께';

  @override
  String get atTime => '에';

  @override
  String get upcoming => '예정된';

  @override
  String get ongoing => '진행 중';

  @override
  String get archive => '보관함';

  @override
  String get unarchive => '보관 취소';

  @override
  String get canceledRides => '취소됨';

  @override
  String get completed => '완료됨';

  @override
  String get canceled => '취소됨';

  @override
  String get suggestRoute => '새 경로 제안';

  @override
  String get suggestStop => '새 정류장 제안';
}
