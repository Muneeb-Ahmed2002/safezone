import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:safezone/UI/HomePage.dart';
import 'package:safezone/global%20variables.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GettingStarted extends StatefulWidget {
  const GettingStarted({super.key});

  @override
  State<GettingStarted> createState() => _GettingStartedState();
}

class _GettingStartedState extends State<GettingStarted> {
  final doc = FirebaseFirestore.instance.collection('Users');
  TextEditingController userField = TextEditingController();
  TextEditingController nameField = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Getting Started',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    color: colorScheme.primary),
              ),
              const SizedBox(height: 20,),
              TextFormField(
                controller: userField,
                validator: (userName){
                  if(userName == null || userName.isEmpty)
                    {
                      return 'This field is required';
                    }
                  if(userExist){
                    return 'User Already Exists';
                  }
                  else{
                    return null;
                  }
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelText: 'User Name',
                  hintText: 'Type a User Name',
                ),
              ),
              const SizedBox(height: 20,),
              TextFormField(
                controller: nameField,
                validator: (name){
                  if(name == null || name.isEmpty)
                  {
                    return 'This field is required';
                  }
                  else{
                    return null;
                  }
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelText: 'Name',
                  hintText: 'Type Your Name',
                ),
              ),
              const SizedBox(height: 20,),
              ElevatedButton(
                onPressed: () async{
                  await checkIfDocExist(userField.text);
                  final prefs = await SharedPreferences.getInstance();
                  if(_formKey.currentState!.validate()){
                     userName = userField.text.toString();
                     name = nameField.text.toString();
                     prefs.setString('userName', userName!);
                    prefs.setString('name', name!);
                    print('$name $userName');
                    await doc.doc(userName!).set({
                      'userName' : userName!,
                      'Name' : name!,
                      'time' :DateTime.now(),
                    });
                    sendLocationToFirebase(latitude, longitude);
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => const Homepage()));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary.withOpacity(0.8),
                ),
                autofocus: true,
                child: Text('Next', style: TextStyle(fontSize: 32, color: colorScheme.onPrimary),),

              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ExistingUser()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary.withOpacity(0.5),
                ),
                autofocus: true,
                child: Text('Already Existing User', style: TextStyle(fontSize: 12, color: colorScheme.onPrimary),),

              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExistingUser extends StatefulWidget {
  const ExistingUser({super.key});

  @override
  State<ExistingUser> createState() => _ExistingUserState();
}

class _ExistingUserState extends State<ExistingUser> {
  final _formKey = GlobalKey<FormState>();
  final userField = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Existing User',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    color: colorScheme.primary),
              ),
              const SizedBox(height: 20,),
              TextFormField(
                controller: userField,
                validator: (userName){
                  if(userName == null || userName.isEmpty)
                  {
                    return 'This field is required';
                  }
                  if(!userExist){
                    return 'This User Name does not exist';
                  }
                  else{
                    return null;
                  }
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelText: 'User Name',
                  hintText: 'Type a User Name',
                ),
              ),
              const SizedBox(height: 20,),
              ElevatedButton(
                onPressed: () async{
                  await checkIfDocExist(userField.text);
                  final prefs = await SharedPreferences.getInstance();
                  if(_formKey.currentState!.validate()){
                    if(userExist){
                      userName = userField.text.toString();
                      prefs.setString('userName', userName!);
                      prefs.setString('name', name!);
                      print('$name $userName');
                      sendLocationToFirebase(latitude, longitude);
                      Navigator.pushAndRemoveUntil(context,
                          MaterialPageRoute(builder: (context) => const Homepage()),
                              (route) => false);
                    }

                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary.withOpacity(0.8),
                ),
                autofocus: true,
                child: Text('Next', style: TextStyle(fontSize: 32, color: colorScheme.onPrimary),),

              ),
            ],
          ),
        ),
      ),
    );
  }
}
