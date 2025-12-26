// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'IndiBindi';

  @override
  String get home => '首页';

  @override
  String get myBookings => '我的预订';

  @override
  String get inbox => '收件箱';

  @override
  String get account => '账户';

  @override
  String get uploadPhoto => '上传照片';

  @override
  String get changePhoto => '更换照片';

  @override
  String get camera => '相机';

  @override
  String get gallery => '相册';

  @override
  String get takePhoto => '拍照';

  @override
  String get chooseFromGallery => '从相册选择';

  @override
  String get removePhoto => '删除照片';

  @override
  String get selectRoute => '选择路线开始';

  @override
  String get driver => '司机';

  @override
  String get rider => '乘客';

  @override
  String get origin => '出发地';

  @override
  String get destination => '目的地';

  @override
  String get selectOrigin => '选择出发地';

  @override
  String get selectDestination => '选择目的地';

  @override
  String get departureTime => '出发时间';

  @override
  String get arrivalTime => '到达时间';

  @override
  String get selectTime => '选择时间';

  @override
  String get seats => '座位';

  @override
  String get selectSeats => '选择座位';

  @override
  String get chooseYourRoute => '哪条路线？';

  @override
  String get chooseYourSeats => '选择您的座位';

  @override
  String get availableSeats => 'null个座位可用';

  @override
  String get chooseYourSeat => '请选择您的座位';

  @override
  String get selectYourSeat => '选择座位';

  @override
  String get available => '可用';

  @override
  String get unavailable => '不可用';

  @override
  String seatsAvailable(int count) {
    return '个座位可用';
  }

  @override
  String seatsSelected(int count) {
    return '已选$count个座位';
  }

  @override
  String get chooseYourStops => '选择您的站点';

  @override
  String get pickUpTime => '上车';

  @override
  String get dropOffTime => '下车';

  @override
  String get today => '今天';

  @override
  String get tomorrow => '明天';

  @override
  String get done => '完成';

  @override
  String get cancel => '取消';

  @override
  String get mon => '周一';

  @override
  String get tue => '周二';

  @override
  String get wed => '周三';

  @override
  String get thu => '周四';

  @override
  String get fri => '周五';

  @override
  String get sat => '周六';

  @override
  String get sun => '周日';

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
  String get confirmBooking => '确认预订';

  @override
  String get bookingConfirmed => '预订已确认！';

  @override
  String get back => '返回';

  @override
  String get next => '下一步';

  @override
  String get save => '保存';

  @override
  String get saved => '已保存';

  @override
  String get personalInformation => '个人信息';

  @override
  String get name => '姓名';

  @override
  String get surname => '姓氏';

  @override
  String get phoneNumber => '手机号码';

  @override
  String get email => '电子邮箱';

  @override
  String get enterName => '输入您的姓名';

  @override
  String get enterSurname => '输入您的姓氏';

  @override
  String get enterPhone => '输入电话号码';

  @override
  String get enterEmail => '输入您的电子邮箱';

  @override
  String get pleaseEnterName => '请输入您的姓名';

  @override
  String get pleaseEnterSurname => '请输入您的姓氏';

  @override
  String get pleaseEnterPhone => '请输入电话号码';

  @override
  String get pleaseEnterValidEmail => '请输入有效的电子邮箱';

  @override
  String get informationSaved => '信息保存成功！';

  @override
  String get vehicleInformation => '车辆信息';

  @override
  String get brand => '品牌';

  @override
  String get model => '型号';

  @override
  String get color => '颜色';

  @override
  String get licensePlate => '车牌号';

  @override
  String get selectBrand => '选择品牌';

  @override
  String get selectModel => '选择型号';

  @override
  String get selectColor => '选择颜色';

  @override
  String get selectBrandFirst => '请先选择品牌';

  @override
  String get enterLicensePlate => '输入车牌号';

  @override
  String examplePlate(String plate) {
    return '示例：$plate';
  }

  @override
  String get pleaseSelectBrand => '请选择品牌';

  @override
  String get pleaseEnterPlate => '请输入车牌号';

  @override
  String get vehicleSaved => '车辆信息保存成功！';

  @override
  String get settings => '设置';

  @override
  String get notifications => '通知';

  @override
  String get pushNotifications => '推送通知';

  @override
  String get pushNotificationsDesc => '接收行程更新通知';

  @override
  String get location => '位置';

  @override
  String get locationServices => '位置服务';

  @override
  String get locationServicesDesc => '允许应用访问您的位置';

  @override
  String get appearance => '外观';

  @override
  String get darkMode => '深色模式';

  @override
  String get darkModeDesc => '使用深色主题';

  @override
  String get language => '语言';

  @override
  String get selectLanguage => '选择语言';

  @override
  String languageChanged(String language) {
    return '语言已更改为$language';
  }

  @override
  String get privacy => '隐私';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get termsOfService => '服务条款';

  @override
  String get data => '数据';

  @override
  String get downloadMyData => '下载我的数据';

  @override
  String get clearCache => '清除缓存';

  @override
  String get clearCacheTitle => '清除缓存';

  @override
  String get clearCacheMessage => '您确定要清除所有缓存数据吗？此操作无法撤消。';

  @override
  String get cacheCleared => '缓存清除成功';

  @override
  String get preparingData => '正在准备您的数据以供下载...';

  @override
  String version(String version) {
    return '版本 $version';
  }

  @override
  String get rideHistory => '行程历史';

  @override
  String get help => '帮助';

  @override
  String get faq => '常见问题';

  @override
  String get support => '支持';

  @override
  String get helpAndSupport => '帮助与支持';

  @override
  String get about => '关于';

  @override
  String get logout => '退出登录';

  @override
  String get clearMyBookings => '清除我的预订';

  @override
  String get deleteAccount => '删除账户';

  @override
  String get white => '白色';

  @override
  String get black => '黑色';

  @override
  String get silver => '银色';

  @override
  String get gray => '灰色';

  @override
  String get red => '红色';

  @override
  String get blue => '蓝色';

  @override
  String get green => '绿色';

  @override
  String get yellow => '黄色';

  @override
  String get orange => '橙色';

  @override
  String get brown => '棕色';

  @override
  String get beige => '米色';

  @override
  String get gold => '金色';

  @override
  String get purple => '紫色';

  @override
  String get pink => '粉色';

  @override
  String get turquoise => '青绿色';

  @override
  String get bronze => '青铜色';

  @override
  String get maroon => '栗色';

  @override
  String get navyBlue => '海军蓝';

  @override
  String get other => '其他';

  @override
  String get noBookingsYet => '暂无预订。';

  @override
  String get passenger => '乘客';

  @override
  String get bookingCompleted => '预订已完成';

  @override
  String get completeBooking => '完成预订';

  @override
  String get postRide => '发布行程';

  @override
  String get ridePosted => '行程已发布';

  @override
  String get noAvailableSeats => '无可用座位';

  @override
  String get whenDoYouWantToTravel => '您想何时出行？';

  @override
  String get matchingRides => '匹配的行程';

  @override
  String get withDriver => '与';

  @override
  String get atTime => '在';

  @override
  String get upcoming => '即将到来';

  @override
  String get ongoing => '进行中';

  @override
  String get archive => '存档';

  @override
  String get unarchive => '取消存档';

  @override
  String get canceledRides => '已取消';

  @override
  String get completed => '已完成';

  @override
  String get canceled => '已取消';

  @override
  String get suggestRoute => '建议新路线';

  @override
  String get suggestStop => '建议新站点';

  @override
  String get areYouDriverOrRider => '今天是司机还是乘客？';

  @override
  String get pickUpAndDropOff => '从哪？';

  @override
  String get chooseDropOffPoint => '到哪？';

  @override
  String get tapSeatsToChangeAvailability => '点击更改';

  @override
  String get setYourTime => '时间？';

  @override
  String get incompleteProfile => '资料不完整';

  @override
  String get incompleteVehicleInfo => '车辆信息不完整';

  @override
  String get completeProfile => '完善资料';

  @override
  String get addVehicle => '添加车辆';

  @override
  String get completePersonalInfoForBooking =>
      '预订行程前请先填写个人信息（姓名、姓氏、电子邮箱、电话号码）。';

  @override
  String get completePersonalInfoForPosting =>
      '发布行程前请先填写个人信息（姓名、姓氏、电子邮箱、电话号码）。';

  @override
  String get completeVehicleInfoForPosting => '发布行程前请先填写车辆信息（品牌、型号、颜色、车牌号）。';

  @override
  String get noMatchingRidesFound => '未找到匹配的行程';

  @override
  String get tryAdjustingTimeOrRoute => '请尝试调整时间或路线';

  @override
  String get cannotBookOwnRide => '您不能预订自己发布的行程';

  @override
  String get thisIsYourRide => '这是您的行程 - 无法预订';

  @override
  String get alreadyHaveRideScheduled => '您已在此时间安排了行程';

  @override
  String get book => '预订';

  @override
  String get booked => '已预订';

  @override
  String get noMessagesYet => '暂无消息';

  @override
  String get messagesWillAppear => '预订行程后将显示消息';

  @override
  String get startConversation => '开始对话！';

  @override
  String get pleaseLoginToViewMessages => '请登录以查看消息';

  @override
  String get bookARide => '预订行程';

  @override
  String get cancelRide => '取消行程';

  @override
  String get archived => '已归档';

  @override
  String get message => '消息';

  @override
  String get rate => '评价';

  @override
  String get yourRating => '您的评价:';

  @override
  String rateUser(String userName) {
    return '评价$userName';
  }

  @override
  String get selectQualitiesThatApply => '选择适用的品质';

  @override
  String get submitRating => '提交评价';

  @override
  String get safe => '安全';

  @override
  String get punctual => '守时';

  @override
  String get clean => '干净';

  @override
  String get polite => '礼貌';

  @override
  String get communicative => '善于沟通';

  @override
  String get suggestion => 'Suggestion';

  @override
  String get complaint => 'Complaint';

  @override
  String get question => 'Question';

  @override
  String get delete => 'Delete';

  @override
  String get conversationArchived => '对话已归档';

  @override
  String get conversationDeleted => 'Conversation deleted';

  @override
  String get undo => 'Undo';

  @override
  String get newRouteSuggestion => 'New Route Suggestion';

  @override
  String get newStopSuggestion => 'New Stop Suggestion';

  @override
  String get hintRoleSelection => '想发布行程？选择司机！想搭车？选择乘客！';

  @override
  String get hintRouteSelection => '选择您要行驶的路线';

  @override
  String get hintOriginSelection => '您的行程从哪里开始？';

  @override
  String get hintDestinationSelection => '您的行程在哪里结束？';

  @override
  String get hintTimeSelection => '您计划什么时候出行？';

  @override
  String get hintSeatSelectionDriver => '点击座位使其对乘客可用';

  @override
  String get hintSeatSelectionRider => '点击座位预订您的位置';

  @override
  String get hintMatchingRides => '这些司机与您的路线和时间匹配';

  @override
  String get hintPostRide => '查看并确认您的行程详情';

  @override
  String systemNotificationDriverCanceled(String driverName, String routeName) {
    return '$driverName取消了$routeName的行程';
  }

  @override
  String systemNotificationRiderCanceled(String riderName) {
    return '$riderName取消了预订';
  }

  @override
  String systemNotificationNewRider(String riderName, String driverName) {
    return '$riderName在$driverName的行程中预订了座位';
  }

  @override
  String systemNotificationRiderBooked(String riderName, String driverName) {
    return '$riderName在$driverName的行程中预订了座位';
  }

  @override
  String get snackbarAdminViewOnly => '管理员只能查看消息，不能发送';

  @override
  String get snackbarMessagingExpired => '消息期限已过（到达后3天）';

  @override
  String get snackbarPleaseLoginToSuggestStop => '请登录以建议停靠点';

  @override
  String get snackbarPleaseLoginToSuggestRoute => '请登录以建议路线';

  @override
  String get snackbarCannotBookOwnRideDetail => '您不能在自己的行程中预订座位。这违反了我们的规定。';

  @override
  String get snackbarAlreadyBookedThisRide => '您已预订此行程';

  @override
  String snackbarConflictingBooking(String routeName) {
    return '您在此时间有冲突的预订: $routeName';
  }

  @override
  String snackbarSwitchedToUser(String userName) {
    return '已切换到$userName';
  }

  @override
  String get snackbarBookingsCleared => '所有预订已清除';

  @override
  String get snackbarConversationsCleared => '所有对话已清除';

  @override
  String get snackbarRatingsCleared => '所有评价已清除';

  @override
  String snackbarAlreadyRated(String userName) {
    return '您已对此行程中的$userName进行了评价';
  }

  @override
  String snackbarRatingSubmitted(String rating, String userName) {
    return '评价已提交: 给$userName$rating颗星';
  }

  @override
  String snackbarCopiedToClipboard(String label) {
    return '$label已复制到剪贴板';
  }

  @override
  String get snackbarCannotMessageYourself => '您不能给自己发消息';

  @override
  String snackbarErrorOpeningChat(String error) {
    return '打开客服聊天时出错: $error';
  }

  @override
  String get snackbarConversationRestored => '对话已恢复';
}
