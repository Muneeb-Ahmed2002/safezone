import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:safezone/global%20variables.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {

  Future fetchEarthquakeMagnitude(url)async {
    final res = await http.get(Uri.parse(url));
    final data = jsonDecode(res.body);
    return data['properties'];
  }
  bool earthquakeActive = false;
  bool floodActive = false;

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
                    // SizedBox.shrink(),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance.collection('earthquakes')
                          .orderBy('timestamp', descending: true).snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const CircularProgressIndicator();
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.sizeOf(context).height / 1.5,
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: snapshot.data?.docs.length,
                              itemBuilder: (BuildContext context, int index) {
                                String? exist = snapshot.data?.docs[index]
                                    .data()
                                    .toString();
        
                                if(exist?.contains('description') == true) {
                                  String? magnitude;
                                  fetchEarthquakeMagnitude(snapshot.data?.docs[index]['url']).then((value){
                                    magnitude = value['earthquakedetails']["magnitude"];
                                    print("Magnitude: $magnitude");
        
                                  });
                                  return ListTile(
                                    title: Text(snapshot.data?.docs[index]['description']),
                                    subtitle: Text('Magnitude: $magnitude'),
                                  );
        
                                } else if(exist?.contains('location') == true){
                                  return ListTile(
                                    title: Text(snapshot.data!.docs[index]['location'].toString()),
                                    subtitle: Text("Magnitude: ${snapshot.data!.docs[index]['magnitude']}"),
                                  );
                                }
                                return const Text('No Data Available');
                              },
                            ),
                          ),
                        );
                      }
                    ),
                ],
              ),
            ),
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
                        floodActive = !floodActive;
                      });
                    },
                    splashColor: colorScheme.primary.withAlpha(80),
                    contentPadding: const EdgeInsets.all(16),
                    title: const Text('Floods', style: TextStyle(fontSize: 32),),
                    trailing: Icon(floodActive? Icons.keyboard_arrow_down:Icons.arrow_forward_ios, size:floodActive? 50:20,),
                  ),
                  if(floodActive)
                  // SizedBox.shrink(),
                    StreamBuilder(
                        stream: FirebaseFirestore.instance.collection('floods')
                            .orderBy('timestamp', descending: true).snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const CircularProgressIndicator();
                          return SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: MediaQuery.sizeOf(context).height / 1.5,
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: snapshot.data?.docs.length,
                                itemBuilder: (BuildContext context, int index) {
                                  String? exist = snapshot.data?.docs[index]
                                      .data()
                                      .toString();
                                  if(!snapshot.hasData){
                                    bool loading = true;
                                    Future.delayed(const Duration(seconds: 5),()=> loading = false);
                                    return loading? const Column(
                                    children: [
                                      CircularProgressIndicator(),
                                      Text('Loading Data'),
                                    ],
                                  ): const Text('No Data Available');
                                  }
                                  String? country;
                                  getLocationFromLatLon(snapshot.data?.docs[index]['latitude'], snapshot.data?.docs[index]['longitude']).then((value){
                                    print(value);
                                      country = value;
                                  });

                                    return ListTile(
                                      title: Text(snapshot.data?.docs[index]['description']),
                                      subtitle: Text('Location: $country'),
                                    );
        
                                },
                              ),
                            ),
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
