import 'package:flutter/material.dart';

class GettingStarted extends StatefulWidget {
  const GettingStarted({super.key});

  @override
  State<GettingStarted> createState() => _GettingStartedState();
}

class _GettingStartedState extends State<GettingStarted> {
  TextEditingController userName = TextEditingController();
  TextEditingController name = TextEditingController();
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
                controller: userName,
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
                controller: name,
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
                onPressed: (){},
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                ),
                autofocus: true,
                child: Text('Next', style: TextStyle(fontSize: 20, color: colorScheme.onPrimary),),

              )
            ],
          ),
        ),
      ),
    );
  }
}
