import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';
import 'package:lottie/lottie.dart';
import '../pages/saved_city_page.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService = WeatherService('6c28ddb50757bea3de0294e5ef474fe8');
  Weather? _weather;
  List<String> _savedCities = [];
  _fetchWeather([String? cityName]) async {
    try {
      final weather = await _weatherService.getWeather(cityName ?? await _weatherService.getCurrentCity());
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      print(e);
    }
  }

  String getWeatherAnimation(String? mainCondition){
    if (mainCondition == null) return 'assets/sunny.json';

    switch (mainCondition.toLowerCase()){
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/cloudy.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rain.json';
      case 'thunderstorm':
        return 'assets/thunderstorm.json';
      default:
        return 'assets/sunny.json';
    }
  }

  void initState(){
    super.initState();

    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children:[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // city name
                Text(_weather?.cityName ?? "loading city.."),
                Lottie.asset(getWeatherAnimation(_weather?.mainCondition)),
                // temperature
                Text('${_weather?.temperature.round()}°C'),
              ],
            ),
          ),
        Positioned(
            right: 20,  // Adjust to position button properly
            bottom: 50,  // Adjust to move button up/down
            child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SavedCitiesPage(
                          _savedCities,
                          (city) {
                            setState(() {
                              _savedCities.remove(city);
                            });
                          },
                          _weatherService,
                        ),
                      ),
                    );
                  },
                  child: Icon(Icons.list),
                ),
          ),
        ],      
      ),
    );
  }
}