import 'package:flutter/material.dart';

class CarWashScreen extends StatelessWidget {
  const CarWashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Wash'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://cdn.pixabay.com/photo/2017/08/02/13/21/car-wash-2571939_1280.jpg',
              height: 200,
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to our Car Wash!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Get your car cleaned by our professionals.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Book Now'),
            ),
          ],
        ),
      ),
    );
  }
}
