import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {

  Future fetchEarthquakeMagnitude(url)async {
    final res = await http.get(Uri.parse(url));
    final data = jsonDecode(res.body);
    final magnitude = await data['properties']['earthquakedetails']["magnitude"];
    print('Magnitude: $magnitude');
    return magnitude;
  }
  bool earthquakeActive = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0), // Adjust corner radius
                side: BorderSide(
                  color: colorScheme.primaryContainer, // Border color
                  width: 3.0, // Border width
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    onTap: (){
                      setState(() {
                        earthquakeActive = !earthquakeActive;
                      });
                    },
                    splashColor: colorScheme.primary.withAlpha(80),
                    contentPadding: const EdgeInsets.all(16),
                    title: const Text('Earthquakes', style: TextStyle(fontSize: 32),),
                    trailing: Icon(earthquakeActive? Icons.keyboard_arrow_down:Icons.arrow_forward_ios, size:earthquakeActive? 50:20,),
                  ),
                  if(earthquakeActive)
                    StreamBuilder(
                      stream: FirebaseFirestore.instance.collection('earthquakes').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox.shrink();
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data?.docs.length,
                          itemBuilder: (BuildContext context, int index) {
                            String? exist = snapshot.data?.docs[index]
                                .data()
                                .toString();
                            if(exist?.contains('description') == true) {
                              String? magnitude;
                              fetchEarthquakeMagnitude(snapshot.data?.docs[index]['url']).then((value){
                                magnitude = value;
                              });
                              print('magnitude: $magnitude');
                              return ListTile(
                                title: Text(snapshot.data?.docs[index]['description']),
                                subtitle: Text('magnitude: $magnitude'),
                              );
                            } else if(exist?.contains('location') == true){
                              return ListTile(
                                title: Text(snapshot.data?.docs[index]['location']),
                                subtitle: Text(snapshot.data?.docs[index]['magnitude']),
                              );
                            }
                          },
                        );
                      }
                    ),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}
