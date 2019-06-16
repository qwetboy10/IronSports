//0 is no data
//1 is cant do
//2 is maybe
//3 is can do
//4 is unknown
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iron_sports_app/SkillList.dart';
import 'package:iron_sports_app/PersonList.dart';
import 'package:iron_sports_app/LoginPage.dart';
import 'package:iron_sports_app/PersonView.dart';
import 'package:iron_sports_app/schedule.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Iron Sports',
      theme: ThemeData(primarySwatch: Colors.red, brightness: Brightness.light),
      home: MyHomePage(title: 'Iron Sports'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool admin = false;
  String name;
  String fid;
  @override
  void initState() {
    super.initState();
    _getName().then((String s) {
      if (s == null) return;
      setState(() {
        name = s;
        Firestore.instance
            .collection('users')
            .where("Name", isEqualTo: name)
            .snapshots()
            .listen((data) =>
                data.documents.forEach((doc) => fid = doc.documentID));
      });
    });
  }

  _setName(String s) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', s);
    name = s;
  }

  Future<String> _getName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('name');
  }

  _loadLoginState(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
    await _setName(result.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                name == null || name == 'null'
                    ? 'Please\nLogin'
                    : 'Welcome\n$name',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 40.0,
                ),
              ),
            ),
            (name == 'null' || name == null)
                ? RaisedButton(
                    color: Theme.of(context).primaryColor,
                    child: Text('Login'),
                    onPressed: () => _loadLoginState(context),
                  )
                : FlatButton(
                    child: Text('View My Skils'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) {
                            Firestore.instance
                                .collection('users')
                                .where("Name", isEqualTo: name)
                                .snapshots()
                                .listen((data) => data.documents
                                    .forEach((doc) => fid = doc.documentID));

                            return PersonView(
                                name: name, fid: fid, admin: admin);
                          },
                        ),
                      );
                    })
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: Text(
                name == null || name == 'null'
                    ? 'Please\nLogin'
                    : ('Welcome\n$name'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 40.0,
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.red,
              ),
            ),
            ListTile(
              title: Text('View All Skills'),
              onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) {
                        return SkillList(admin: admin);
                      },
                    ),
                  ),
            ),
            ListTile(
                title: Text('View My Progressions'),
                onTap: () {
                  if (name != 'null' && name != null)
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) {
                          Firestore.instance
                              .collection('users')
                              .where("Name", isEqualTo: name)
                              .snapshots()
                              .listen((data) => data.documents
                                  .forEach((doc) => fid = doc.documentID));

                          return PersonView(name: name, fid: fid, admin: admin);
                        },
                      ),
                    );
                }),
            ListTile(
              title: Text('''View Everyone's Progressions'''),
              onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) {
                        return PersonList(title: widget.title, admin: admin);
                      },
                    ),
                  ),
            ),
            ListTile(
                title:
                    Text(name == null || name == 'null' ? 'Login' : 'Logout'),
                onTap: () => changeAdmin()),
            ListTile(
              title: Text(admin ? 'Logout of Admin' : 'Enter Admin Mode'),
              onTap: () => changeAdmin(),
            ),
            ListTile(
              title: Text('Schedule'),
              onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) {
                        return Schedule();
                      },
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void changeAdmin() {
    if (admin) {
      setState(() {
        admin = false;
      });
    } else {
      showDialog<String>(
              context: context, child: MyDialog(title: 'Enter Admin Password'))
          .then((String s) {
        if (s == 'IronSports212')
          setState(() {
            admin = true;
          });
      });
    }
  }
}

class MyDialog extends StatefulWidget {
  final String title;
  MyDialog({this.title});
  @override
  State createState() => new MyDialogState();
}

class MyDialogState extends State<MyDialog> {
  TextEditingController controlerName = new TextEditingController();
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(widget.title),
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 230.0,
              padding: EdgeInsets.all(8.0),
              child: TextField(
                textAlign: TextAlign.center,
                controller: controlerName,
              ),
            ),
          ],
        ),
        Center(
          child: Container(
            padding: EdgeInsets.all(8.0),
            child: SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, controlerName.value.text);
              },
              child: const Text(
                'Submit',
                textScaleFactor: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
//0 is no data
//1 is cant do
//2 is maybe
//3 is can do
//4 is unknown
