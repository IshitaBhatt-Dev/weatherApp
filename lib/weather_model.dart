class Weather {
  final String cityName;
  final double temperature;
  final String icon;

  Weather(
      {required this.cityName, required this.temperature, required this.icon});

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temperature: json['main']['temp'],
      icon: json['weather'][0]['icon'],
    );
  }
}
