import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          color: Theme.of(context).splashColor,
          child: Center(
            child: Transform.scale(scale: 2, child: const Text('Loading...')),
          ),
        ),
      ),
    );
  }
}
