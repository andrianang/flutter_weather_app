import 'package:flutter/material.dart';


class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController cityController = TextEditingController();
    return Scaffold(
      appBar:AppBar(
        title:Text('Search City')
        ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller:cityController,
              decoration: InputDecoration(
                labelText: "Enter City Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String cityName = cityController.text;
                Navigator.pop(context, cityName); 
              },
              child: Text("Add"),
            )
          ],
        ),
        )
    );
  }
}