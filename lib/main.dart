import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'weather_service.dart';
import 'weather_model.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final WeatherService weatherService = WeatherService();
  Weather? weatherObj;
  String selectedCity = 'Miami';

  @override
  void initState() {
    super.initState();
    //_fetchWeather();
    _detectLocation();
  }

  void _fetchWeather() async {
    final weather = await weatherService.fetchWeather(selectedCity);
    setState(() {
      weatherObj = weather;
    });
  }

  void _detectLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        _fetchWeather(); // Fallback to default city if location service is not enabled
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        _fetchWeather(); // Fallback to default city if permission is denied
        return;
      }
    }

    locationData = await location.getLocation();

    final weather = await weatherService.fetchWeatherByCoordinates(
        locationData.latitude!, locationData.longitude!);
    setState(() {
      weatherObj = weather;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Weather Widget'),
        ),
        backgroundColor:
            const Color(0xff8fdeff), // Set the background color here
        body: Center(
          child: weatherObj == null
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton<String>(
                      value: selectedCity,
                      items: <String>['Miami', 'New York', 'Los Angeles']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCity = newValue!;
                          _fetchWeather();
                        });
                      },
                    ),
                    Text(
                      weatherObj!.cityName,
                      style: const TextStyle(fontSize: 24),
                    ),
                    Text(
                      '${weatherObj!.temperature}°F',
                      style: const TextStyle(fontSize: 24),
                    ),
                    Image.network(
                      'https://openweathermap.org/img/w/${weatherObj!.icon}.png',
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
