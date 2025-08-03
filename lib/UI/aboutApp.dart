import 'package:flutter/material.dart';

class Aboutapp extends StatelessWidget {
  const Aboutapp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About SafeZone'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SafeZone',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'SafeZone is a disaster preparedness and management application designed to keep users informed about potential or ongoing natural disasters in their area. '
                  'This app operates through centralized alerts and verified data to ensure accuracy and reliability.',
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5,
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Disasters Covered',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'The app provides early warnings and situational updates for a range of major natural disasters, including:\n\n'
                  '• Earthquakes – sudden seismic activity caused by movements in the Earth’s crust.\n'
                  '• Floods – hydrological disasters caused by excessive water accumulation or river overflows.\n'
                  '• Storms and Cyclones – severe atmospheric events including high winds and heavy rainfall.\n'
                  '• Heatwaves – extreme temperature events driven by climate fluctuations and prolonged dry weather.',
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Location-Based Awareness',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'SafeZone uses your device\'s location data to track your current position and updates it securely to Database. '
                  'This enables the app to send highly accurate and timely alerts about disasters occurring nearby, helping you stay aware and safe.',
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5,
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Disaster Response Guide',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'The app also includes a dedicated section offering safety guidelines and preparation tips for various disaster scenarios. '
                  'This ensures that users not only receive alerts but also understand what actions to take in an emergency.',
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5,
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                'Version 1.0.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }
}
