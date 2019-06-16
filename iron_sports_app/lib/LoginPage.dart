import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  Future<void> _setName(String s) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', s);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: Text('Login'),
              padding: EdgeInsets.all(16.0),
            ),
            Center(
              child: Container(
                width: 500.0,
                child: TextField(
                  textCapitalization: TextCapitalization.words,
                  decoration:
                      InputDecoration(hintText: 'Please enter your name'),
                  textAlign: TextAlign.center,
                  onSubmitted: (String name) {
                    _setName(name).then((void v) {
                      Navigator.of(context).pop(name);
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
