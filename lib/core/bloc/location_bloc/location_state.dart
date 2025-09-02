class LocationState {
  final double? latitude;
  final double? longitude;
  final bool isLoading;
  final String? errorMessage;

  final String? street;
  final String? flatNo;
  final String? landmark;
  final String? postalCode;
  final String? city;
  final String? country;

  LocationState({
    this.latitude,
    this.longitude,
    this.isLoading = false,
    this.errorMessage,
    this.street,
    this.flatNo,
    this.landmark,
    this.postalCode,
    this.city,
    this.country,
  });

  LocationState copyWith({
    double? latitude,
    double? longitude,
    bool? isLoading,
    String? errorMessage,
    String? street,
    String? flatNo,
    String? landmark,
    String? postalCode,
    String? city,
    String? country,
  }) {
    return LocationState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      street: street ?? this.street,
      flatNo: flatNo ?? this.flatNo,
      landmark: landmark ?? this.landmark,
      postalCode: postalCode ?? this.postalCode,
      city: city ?? this.city,
      country: country ?? this.country,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationState &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage &&
        other.street == street &&
        other.flatNo == flatNo &&
        other.landmark == landmark &&
        other.postalCode == postalCode &&
        other.city == city &&
        other.country == country;
  }

  @override
  int get hashCode =>
      latitude.hashCode ^
      longitude.hashCode ^
      isLoading.hashCode ^
      errorMessage.hashCode ^
      street.hashCode ^
      flatNo.hashCode ^
      landmark.hashCode ^
      postalCode.hashCode ^
      city.hashCode ^
      country.hashCode;
}
