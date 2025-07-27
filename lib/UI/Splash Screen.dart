import 'dart:async';
import 'package:flutter/material.dart';
import 'package:safezone/UI/GettingStarted.dart';
import 'package:safezone/UI/HomePage.dart';
import 'package:safezone/global%20variables.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 2), ()
    async {
      final prefs = await SharedPreferences.getInstance();
      userName = prefs.getString('userName');
      name = prefs.getString('name');
      if(userName == null){
        Navigator.pushReplacement(context,
          MaterialPageRoute(builder:
              (context) => const GettingStarted()),
        );
      }
      else{
        Navigator.pushReplacement(context,
          MaterialPageRoute(builder:
              (context) => const Homepage()),
        );
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Center(
        child: Container(
          width: screenSize.width,
          height: screenSize.height,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.9,
              colors: [
                colorScheme.primaryContainer,
                colorScheme.primary.withOpacity(0.6),
                colorScheme.surface,
              ],
              stops: const [0.2, 0.6, 1.0],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.shield_outlined,
                size: screenSize.width,
                color: colorScheme.primary,
              ),
              Text(
                'SafeZone',
                style: TextStyle(
                  fontSize: screenSize.width / 10,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  shadows: [
                    Shadow(
                      offset: const Offset(2, 2),
                      blurRadius: 5,
                      color: colorScheme.shadow,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
