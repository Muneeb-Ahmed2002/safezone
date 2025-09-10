import 'package:flutter/material.dart';
import 'package:safezone/UI/Alerts.dart';
import 'package:safezone/UI/aboutApp.dart';
import 'package:safezone/global%20variables.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('SafeZone'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name!,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onBackground,
                  ),
                ),
                Text(
                  userName!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Welcome to SafeZone',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose an option below:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),

            // Grid of buttons
            Expanded(
              child: Center(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1, // square tiles
                  children: [
                    GridOptionButton(
                      icon: Icons.warning_amber_rounded,
                      label: 'View Alerts',
                      color: colorScheme.primaryContainer,
                      iconColor: colorScheme.onPrimaryContainer,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context)=>const AlertsPage())
                        );
                      },
                    ),
                    GridOptionButton(
                      icon: Icons.health_and_safety,
                      label: 'Safety Tips',
                      color: colorScheme.secondaryContainer,
                      iconColor: colorScheme.onSecondaryContainer,
                      onTap: () {
                        // TODO: Navigate to safety tips
                      },
                    ),
                    GridOptionButton(
                      icon: Icons.info_outline,
                      label: 'About App',
                      color: Colors.grey.shade300,
                      iconColor: Colors.black87,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context)=>const Aboutapp())
                        );
                      },
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GridOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const GridOptionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: iconColor),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
