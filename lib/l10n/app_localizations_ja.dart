// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'IndiBindi';

  @override
  String get home => 'ホーム';

  @override
  String get myBookings => '予約履歴';

  @override
  String get inbox => '受信トレイ';

  @override
  String get account => 'アカウント';

  @override
  String get uploadPhoto => '写真をアップロード';

  @override
  String get changePhoto => '写真を変更';

  @override
  String get camera => 'カメラ';

  @override
  String get gallery => 'ギャラリー';

  @override
  String get takePhoto => '写真を撮る';

  @override
  String get chooseFromGallery => 'ギャラリーから選択';

  @override
  String get removePhoto => '写真を削除';

  @override
  String get selectRoute => 'ルートを選択して開始';

  @override
  String get driver => 'ドライバー';

  @override
  String get rider => '乗客';

  @override
  String get origin => '出発地';

  @override
  String get destination => '目的地';

  @override
  String get selectOrigin => '出発地を選択';

  @override
  String get selectDestination => '目的地を選択';

  @override
  String get departureTime => '出発時刻';

  @override
  String get arrivalTime => '到着時刻';

  @override
  String get selectTime => '時刻を選択';

  @override
  String get seats => '座席';

  @override
  String get selectSeats => '座席を選択';

  @override
  String get chooseYourRoute => 'ルートを選択';

  @override
  String get chooseYourSeats => '座席を選択してください';

  @override
  String get availableSeats => 'null席空き';

  @override
  String get chooseYourSeat => '座席を選んでください';

  @override
  String get selectYourSeat => '座席を選択';

  @override
  String get available => '空き';

  @override
  String seatsAvailable(int count) {
    return '席空き';
  }

  @override
  String seatsSelected(int count) {
    return '$count席選択済み';
  }

  @override
  String get chooseYourStops => '停留所を選択';

  @override
  String get pickUpTime => '乗車時刻';

  @override
  String get dropOffTime => '降車時刻';

  @override
  String get today => '今日';

  @override
  String get tomorrow => '明日';

  @override
  String get done => '完了';

  @override
  String get cancel => 'キャンセル';

  @override
  String get mon => '月';

  @override
  String get tue => '火';

  @override
  String get wed => '水';

  @override
  String get thu => '木';

  @override
  String get fri => '金';

  @override
  String get sat => '土';

  @override
  String get sun => '日';

  @override
  String get jan => '1月';

  @override
  String get feb => '2月';

  @override
  String get mar => '3月';

  @override
  String get apr => '4月';

  @override
  String get may => '5月';

  @override
  String get jun => '6月';

  @override
  String get jul => '7月';

  @override
  String get aug => '8月';

  @override
  String get sep => '9月';

  @override
  String get oct => '10月';

  @override
  String get nov => '11月';

  @override
  String get dec => '12月';

  @override
  String get confirmBooking => '予約を確認';

  @override
  String get bookingConfirmed => '予約が確認されました！';

  @override
  String get back => '戻る';

  @override
  String get next => '次へ';

  @override
  String get save => '保存';

  @override
  String get saved => '保存済み';

  @override
  String get personalInformation => '個人情報';

  @override
  String get name => '名前';

  @override
  String get surname => '姓';

  @override
  String get phoneNumber => '携帯電話番号';

  @override
  String get email => 'メールアドレス';

  @override
  String get enterName => '名前を入力してください';

  @override
  String get enterSurname => '姓を入力してください';

  @override
  String get enterPhone => '電話番号を入力してください';

  @override
  String get enterEmail => 'メールアドレスを入力してください';

  @override
  String get pleaseEnterName => '名前を入力してください';

  @override
  String get pleaseEnterSurname => '姓を入力してください';

  @override
  String get pleaseEnterPhone => '電話番号を入力してください';

  @override
  String get pleaseEnterValidEmail => '有効なメールアドレスを入力してください';

  @override
  String get informationSaved => '情報が正常に保存されました！';

  @override
  String get vehicleInformation => '車両情報';

  @override
  String get brand => 'ブランド';

  @override
  String get model => 'モデル';

  @override
  String get color => '色';

  @override
  String get licensePlate => 'ナンバープレート';

  @override
  String get selectBrand => 'ブランドを選択';

  @override
  String get selectModel => 'モデルを選択';

  @override
  String get selectColor => '色を選択';

  @override
  String get selectBrandFirst => '最初にブランドを選択してください';

  @override
  String get enterLicensePlate => 'ナンバープレートを入力';

  @override
  String examplePlate(String plate) {
    return '例：$plate';
  }

  @override
  String get pleaseSelectBrand => 'ブランドを選択してください';

  @override
  String get pleaseEnterPlate => 'ナンバープレートを入力してください';

  @override
  String get vehicleSaved => '車両情報が正常に保存されました！';

  @override
  String get settings => '設定';

  @override
  String get notifications => '通知';

  @override
  String get pushNotifications => 'プッシュ通知';

  @override
  String get pushNotificationsDesc => '乗車の更新に関する通知を受け取る';

  @override
  String get location => '位置情報';

  @override
  String get locationServices => '位置情報サービス';

  @override
  String get locationServicesDesc => 'アプリが位置情報にアクセスすることを許可';

  @override
  String get appearance => '外観';

  @override
  String get darkMode => 'ダークモード';

  @override
  String get darkModeDesc => 'ダークテーマを使用';

  @override
  String get language => '言語';

  @override
  String get selectLanguage => '言語を選択';

  @override
  String languageChanged(String language) {
    return '言語が$languageに変更されました';
  }

  @override
  String get privacy => 'プライバシー';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get termsOfService => '利用規約';

  @override
  String get data => 'データ';

  @override
  String get downloadMyData => 'データをダウンロード';

  @override
  String get clearCache => 'キャッシュをクリア';

  @override
  String get clearCacheTitle => 'キャッシュをクリア';

  @override
  String get clearCacheMessage => 'すべてのキャッシュデータをクリアしてもよろしいですか？この操作は元に戻せません。';

  @override
  String get cacheCleared => 'キャッシュが正常にクリアされました';

  @override
  String get preparingData => 'ダウンロード用にデータを準備しています...';

  @override
  String version(String version) {
    return 'バージョン $version';
  }

  @override
  String get rideHistory => '乗車履歴';

  @override
  String get help => 'ヘルプ';

  @override
  String get faq => 'よくある質問';

  @override
  String get support => 'サポート';

  @override
  String get helpAndSupport => 'ヘルプとサポート';

  @override
  String get about => 'アプリについて';

  @override
  String get logout => 'ログアウト';

  @override
  String get clearMyBookings => '予約をクリア';

  @override
  String get deleteAccount => 'アカウントを削除';

  @override
  String get white => '白';

  @override
  String get black => '黒';

  @override
  String get silver => 'シルバー';

  @override
  String get gray => 'グレー';

  @override
  String get red => '赤';

  @override
  String get blue => '青';

  @override
  String get green => '緑';

  @override
  String get yellow => '黄色';

  @override
  String get orange => 'オレンジ';

  @override
  String get brown => '茶色';

  @override
  String get beige => 'ベージュ';

  @override
  String get gold => 'ゴールド';

  @override
  String get purple => '紫';

  @override
  String get pink => 'ピンク';

  @override
  String get turquoise => 'ターコイズ';

  @override
  String get bronze => 'ブロンズ';

  @override
  String get maroon => 'マルーン';

  @override
  String get navyBlue => 'ネイビーブルー';

  @override
  String get other => 'その他';

  @override
  String get noBookingsYet => 'まだ予約がありません。';

  @override
  String get passenger => '乗客';

  @override
  String get bookingCompleted => '予約完了';

  @override
  String get completeBooking => '予約を完了';

  @override
  String get postRide => '乗車を投稿';

  @override
  String get ridePosted => '乗車投稿完了';

  @override
  String get noAvailableSeats => '空席なし';

  @override
  String get whenDoYouWantToTravel => 'いつ旅行したいですか？';

  @override
  String get matchingRides => 'マッチする乗車';

  @override
  String get withDriver => 'と';

  @override
  String get atTime => 'で';

  @override
  String get upcoming => '今後';

  @override
  String get ongoing => '進行中';

  @override
  String get archive => 'アーカイブ';

  @override
  String get unarchive => 'アーカイブ解除';

  @override
  String get canceledRides => 'キャンセル済み';

  @override
  String get completed => '完了';

  @override
  String get canceled => 'キャンセル';

  @override
  String get suggestRoute => '新しいルートを提案';

  @override
  String get suggestStop => '新しい停留所を提案';

  @override
  String get areYouDriverOrRider => 'ドライバーですか、ライダーですか？';

  @override
  String get pickUpAndDropOff => '乗車地点を選択';

  @override
  String get chooseDropOffPoint => '降車地点を選択';

  @override
  String get tapSeatsToChangeAvailability => '座席をタップして空き状況を変更';

  @override
  String get setYourTime => '時間を設定';

  @override
  String get incompleteProfile => 'プロフィール未完了';

  @override
  String get incompleteVehicleInfo => '車両情報未完了';

  @override
  String get completeProfile => 'プロフィールを完成';

  @override
  String get addVehicle => '車両を追加';

  @override
  String get completePersonalInfoForBooking =>
      '乗車を予約する前に、個人情報（名前、姓、メール、電話番号）を入力してください。';

  @override
  String get completePersonalInfoForPosting =>
      '乗車を投稿する前に、個人情報（名前、姓、メール、電話番号）を入力してください。';

  @override
  String get completeVehicleInfoForPosting =>
      '乗車を投稿する前に、車両情報（ブランド、モデル、色、ナンバープレート）を入力してください。';

  @override
  String get noMatchingRidesFound => '一致する乗車が見つかりません';

  @override
  String get tryAdjustingTimeOrRoute => '時間やルートを調整してみてください';

  @override
  String get cannotBookOwnRide => '自分の乗車に席を予約することはできません';

  @override
  String get thisIsYourRide => 'これはあなたの乗車です - 予約できません';

  @override
  String get alreadyHaveRideScheduled => 'この時間帯にすでに乗車が予定されています';

  @override
  String get book => '予約';

  @override
  String get booked => '予約済み';

  @override
  String get noMessagesYet => 'まだメッセージはありません';

  @override
  String get messagesWillAppear => '乗車を予約するとメッセージが表示されます';

  @override
  String get startConversation => '会話を始めましょう！';

  @override
  String get pleaseLoginToViewMessages => 'メッセージを見るにはログインしてください';

  @override
  String get bookARide => '乗車を予約';

  @override
  String get cancelRide => '乗車をキャンセル';
}
