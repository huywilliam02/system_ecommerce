class RecordLocationBody {
  String? token;
  double? longitude;
  double? latitude;
  String? location;

  RecordLocationBody({this.token, this.longitude, this.latitude, this.location});

  RecordLocationBody.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    longitude = json['longitude'].toDouble();
    latitude = json['latitude'].toDouble();
    location = json['location'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    data['longitude'] = longitude;
    data['latitude'] = latitude;
    data['location'] = location;
    return data;
  }
}
