class User {
  final String id;
  final String name;
  final String surname;
  final String email;
  final String phoneNumber;
  final String countryCode;
  final String? profilePhotoUrl;
  final String? vehicleBrand;
  final String? vehicleModel;
  final String? vehicleColor;
  final String? licensePlate;
  final bool isAdmin;
  final double rating;

  User({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
    required this.phoneNumber,
    required this.countryCode,
    this.profilePhotoUrl,
    this.vehicleBrand,
    this.vehicleModel,
    this.vehicleColor,
    this.licensePlate,
    this.isAdmin = false,
    this.rating = 0.0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      surname: json['surname'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      countryCode: json['countryCode'],
      profilePhotoUrl: json['profilePhotoUrl'],
      vehicleBrand: json['vehicleBrand'],
      vehicleModel: json['vehicleModel'],
      vehicleColor: json['vehicleColor'],
      licensePlate: json['licensePlate'],
      isAdmin: json['isAdmin'] ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'email': email,
      'phoneNumber': phoneNumber,
      'countryCode': countryCode,
      'profilePhotoUrl': profilePhotoUrl,
      'vehicleBrand': vehicleBrand,
      'vehicleModel': vehicleModel,
      'vehicleColor': vehicleColor,
      'licensePlate': licensePlate,
      'isAdmin': isAdmin,
      'rating': rating,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? surname,
    String? email,
    String? phoneNumber,
    String? countryCode,
    String? profilePhotoUrl,
    String? vehicleBrand,
    String? vehicleModel,
    String? vehicleColor,
    String? licensePlate,
    bool? isAdmin,
    double? rating,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      vehicleBrand: vehicleBrand ?? this.vehicleBrand,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      licensePlate: licensePlate ?? this.licensePlate,
      isAdmin: isAdmin ?? this.isAdmin,
      rating: rating ?? this.rating,
    );
  }

  String get fullName => '$name $surname';

  String get formattedPhone => '$countryCode $phoneNumber';

  bool get hasVehicle =>
      vehicleBrand != null &&
      vehicleModel != null &&
      vehicleColor != null &&
      licensePlate != null;

  bool get hasCompletePersonalInfo =>
      name.isNotEmpty &&
      surname.isNotEmpty &&
      email.isNotEmpty &&
      phoneNumber.isNotEmpty &&
      countryCode.isNotEmpty;
}
