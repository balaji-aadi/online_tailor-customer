import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;
import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final loc.Location _location = loc.Location();

  LocationBloc() : super(LocationState()) {
    on<GetUserLocation>(_getUserLocation);
  }

  Future<void> _getUserLocation(
      GetUserLocation event, Emitter<LocationState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      final permission = await _location.hasPermission();
      if (permission == loc.PermissionStatus.denied) {
        final requestPermission = await _location.requestPermission();
        if (requestPermission != loc.PermissionStatus.granted) {
          emit(state.copyWith(
              isLoading: false, errorMessage: "Location permission denied"));
          return;
        }
      }

      final locationData = await _location.getLocation();
      if (locationData.latitude == null || locationData.longitude == null) {
        emit(state.copyWith(
            isLoading: false, errorMessage: "Could not fetch location"));
        return;
      }

      final placemarks = await placemarkFromCoordinates(
        locationData.latitude!,
        locationData.longitude!,
      );

      final place = placemarks.first;

      emit(state.copyWith(
        latitude: locationData.latitude,
        longitude: locationData.longitude,
        street: place.street,
        landmark: place.subLocality,
        postalCode: place.postalCode,
        city: place.locality,
        country: place.isoCountryCode,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
          isLoading: false, errorMessage: "Failed to get location: $e"));
    }
  }
}
