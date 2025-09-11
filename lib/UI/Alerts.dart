import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:safezone/global%20variables.dart';
import 'package:http/http.dart' as http;

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  bool earthquakeActive = false;
  bool floodActive = false;
  bool cycloneActive = false;
  bool volcanoActive = false;
  bool heatwaveActive = false;
  final DateTime threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));

  Future fetchEarthquakeMagnitude(String url) async {
    final res = await http.get(Uri.parse(url));
    final data = jsonDecode(res.body);
    return data['properties'];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildDisasterCard(
              title: "Earthquakes",
              active: earthquakeActive,
              onTap: () => setState(() {
                earthquakeActive = !earthquakeActive;
                floodActive = cycloneActive = volcanoActive = heatwaveActive = false;
              }),
              stream: FirebaseFirestore.instance
                  .collection('earthquakes')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              itemBuilder: (doc) {
                if (doc.data().toString().contains('description')) {
                  return FutureBuilder(
                    future: fetchEarthquakeMagnitude(doc['url']),
                    builder: (context, magSnapshot) {
                      if (!magSnapshot.hasData) {
                        return const ListTile(title: Text("Loading earthquake..."));
                      }
                      final magnitude = magSnapshot.data['earthquakedetails']["magnitude"];
                      return ListTile(
                        title: Text(doc['description']),
                        subtitle: Text("Magnitude: $magnitude"),
                        trailing: Text("${DateTime.tryParse(doc['timestamp']) ?? DateTime.now()}"),
                      );
                    },
                  );
                } else {
                  return ListTile(
                    title: Text(doc['location']),
                    subtitle: Text("Magnitude: ${doc['magnitude']}"),
                    trailing: Text("${DateTime.tryParse(doc['timestamp']) ?? DateTime.now()}"),
                  );
                }
              },
            ),

            _buildDisasterCard(
              title: "Floods",
              active: floodActive,
              onTap: () => setState(() {
                floodActive = !floodActive;
                earthquakeActive = cycloneActive = volcanoActive = heatwaveActive = false;
              }),
              stream: FirebaseFirestore.instance
                  .collection('floods')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              itemBuilder: (doc) {
                return FutureBuilder<String>(
                  future: getLocationFromLatLon(doc['latitude'], doc['longitude']),
                  builder: (context, snapshot) {
                    final location = snapshot.data ?? "Loading location...";
                    return ListTile(
                      title: Text(doc['description'] ?? "No description"),
                      subtitle: Text("Location: $location • Alert: ${doc['alertLevel'] ?? 'N/A'}"),
                      trailing: Text("${DateTime.tryParse(doc['timestamp']) ?? DateTime.now()}"),
                    );
                  },
                );
              },
            ),

            _buildDisasterCard(
              title: "Tropical Cyclones",
              active: cycloneActive,
              onTap: () => setState(() {
                cycloneActive = !cycloneActive;
                earthquakeActive = floodActive = volcanoActive = heatwaveActive = false;
              }),
              stream: FirebaseFirestore.instance
                  .collection('tropical_cyclones')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              itemBuilder: (doc) => ListTile(
                title: Text(doc['description'] ?? "No description"),
                subtitle: Text(
                  "Country: ${doc['country'] == ""? 'N/A': doc['country']} • Alert: ${doc['alertLevel'] ?? 'N/A'}",
                ),
                trailing: Text("${DateTime.tryParse(doc['timestamp']) ?? DateTime.now()}"),
              ),
            ),

            _buildDisasterCard(
              title: "Volcanic Activity",
              active: volcanoActive,
              onTap: () => setState(() {
                volcanoActive = !volcanoActive;
                earthquakeActive = floodActive = cycloneActive = heatwaveActive = false;
              }),
              stream: FirebaseFirestore.instance
                  .collection('volcanic_activity')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              itemBuilder: (doc) {
                return FutureBuilder<String>(
                  future: getLocationFromLatLon(doc['latitude'], doc['longitude']),
                  builder: (context, snapshot) {
                    final location = snapshot.data ?? "Loading location...";
                    return ListTile(
                      title: Text(doc['description'] ?? "No description"),
                      subtitle: Text(
                        "Location: $location • Alert: ${doc['alertLevel'] ?? 'N/A'}",
                      ),
                      trailing: Text("${DateTime.tryParse(doc['timestamp']) ?? DateTime.now()}"),
                    );
                  },
                );
              },
            ),


            _buildDisasterCard(
              title: "Heatwaves",
              active: heatwaveActive,
              onTap: () => setState(() {
                heatwaveActive = !heatwaveActive;
                earthquakeActive = floodActive = cycloneActive = volcanoActive = false;
              }),
              stream: FirebaseFirestore.instance
                  .collection('heatwaves')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              itemBuilder: (doc) => ListTile(
                title: const Text("Forecasted Heatwave"),
                subtitle: Text(
                  "Temp: ${doc['temperature']}°C at ${doc['forecastTime'] ?? 'N/A'}",
                ),
                trailing: Text("${DateTime.tryParse(doc['timestamp']) ?? DateTime.now()}"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Reusable card builder for each disaster type
  Widget _buildDisasterCard({
    required String title,
    required bool active,
    required VoidCallback onTap,
    required Stream<QuerySnapshot<Map<String, dynamic>>> stream,
    required Widget Function(QueryDocumentSnapshot<Map<String, dynamic>> doc) itemBuilder,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
        side: BorderSide(color: colorScheme.primaryContainer, width: 3.0),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: onTap,
            splashColor: colorScheme.primary.withAlpha(80),
            contentPadding: const EdgeInsets.all(16),
            title: Text(title, style: const TextStyle(fontSize: 28)),
            trailing: Icon(
              active ? Icons.keyboard_arrow_down : Icons.arrow_forward_ios,
              size: active ? 40 : 20,
            ),
          ),
          if (active)
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        Text('Loading Data'),
                      ],
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const ListTile(
                    title: Text("No data available"),
                  );
                }
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height / 1.5,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      final tsField = doc['timestamp'];
                      DateTime ts = DateTime.now();
                      if (tsField is String) {
                        ts = DateTime.tryParse(tsField) ?? DateTime.now();
                      }
                      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
                      if (ts.isBefore(threeDaysAgo)) return const SizedBox.shrink(); // skip old records
                      return itemBuilder(doc);
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
