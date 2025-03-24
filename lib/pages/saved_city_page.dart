import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../pages/search_page.dart';

class SavedCitiesPage extends StatefulWidget {
  final List<String> savedCities;
  final Function(String) onCityDeleted;
  final WeatherService weatherService;
  
  const SavedCitiesPage(this.savedCities, this.onCityDeleted, this.weatherService, {super.key});

  @override
  State<SavedCitiesPage> createState() => _SavedCitiesPageState();
}

class _SavedCitiesPageState extends State<SavedCitiesPage> {
  Map<String, Weather> weatherData = {};

  Future<void> _fetchWeatherForSavedCities() async {
    for (var city in widget.savedCities) {
      await _fetchWeather(city);
    }
  }

  Future<void> _fetchWeather(String city) async {
    try {
      Weather weather = await widget.weatherService.getWeather(city);
      setState(() {
        weatherData[city] = weather;
      });
    } catch (e) {
      print("Error fetching weather for $city: $e");
    }
  }

  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/sunny.json';

    switch (mainCondition.toLowerCase()) {
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

  void _editCity(int index) async{
    String oldCity = widget.savedCities[index];
    TextEditingController cityController = TextEditingController(text: oldCity);

    String? newCity = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit City"),
          content: TextField(
            controller: cityController,
            decoration: InputDecoration(
              labelText: "Enter new city name",
              border: OutlineInputBorder(),
            )
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, cityController.text),
              child: Text("Save"),
            ),
          ]
        );
      }
    );

    if (newCity != null && newCity.isNotEmpty && newCity != oldCity) {
      setState(() {
        widget.savedCities[index] = newCity;
        weatherData.remove(oldCity);
      });
      _fetchWeather(newCity);
    }
  }
  void _addCity(String city) {
    if (!widget.savedCities.contains(city)) {
      setState(() {
        widget.savedCities.add(city);
      });
      _fetchWeather(city);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeatherForSavedCities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Saved Cities")),
      body: widget.savedCities.isEmpty
          ? Center(child: Text("No saved cities yet"))
          : Padding(
              padding: EdgeInsets.all(10),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Two columns
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8, // Adjust for better layout
                ),
                itemCount: widget.savedCities.length,
                itemBuilder: (context, index) {
                  String city = widget.savedCities[index];
                  Weather? weather = weatherData[city];

                  return Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          weather?.cityName ?? "Loading...",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Lottie.asset(getWeatherAnimation(weather?.mainCondition), height: 80),
                        Text(
                          weather != null ? '${weather.temperature.round()}°C' : "Loading...",
                          style: TextStyle(fontSize: 18),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editCity(index),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  widget.savedCities.removeAt(index);
                                });
                                widget.onCityDeleted(city);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String? newCity = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SearchPage()),
          );
          if (newCity != null && newCity.isNotEmpty) {
            _addCity(newCity);
          }
        },
        child: Icon(Icons.search),
      ),
    );
  }
}