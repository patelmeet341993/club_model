import 'package:club_model/club_model.dart';

class LocationModel extends Equatable {
  GeoPoint? geoPoint;
  String address = "";
  String city = "";
  String state = "";
  Timestamp? timestamp;

  LocationModel({
    this.geoPoint,
    this.address = "",
    this.city = "",
    this.state = "",
    this.timestamp,
  });

  LocationModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    geoPoint = ParsingHelper.parseGeoPointMethod(map['geoPoint']);
    address = ParsingHelper.parseStringMethod(map['address']);
    city = ParsingHelper.parseStringMethod(map['city']);
    state = ParsingHelper.parseStringMethod(map['state']);
    timestamp = ParsingHelper.parseTimestampMethod(map['timestamp']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return {
      "geoPoint": geoPoint != null ? (toJson ? geoPoint!.getGeoPointJson() : geoPoint) : null,
      "address": address,
      "city": city,
      "state": state,
      "timestamp": timestamp != null ? (toJson ? timestamp!.toDate().getDateString() : timestamp) : null,
    };
  }

  @override
  List<Object?> get props => [
    geoPoint?.latitude,
    geoPoint?.longitude,
    address,
    city,
    state,
    timestamp?.toDate().getDateString(),
  ];

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}
