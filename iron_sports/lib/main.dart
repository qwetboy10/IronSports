//0 is no data
//1 is cant do
//2 is maybe
//3 is can do
//4 is unknown
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Iron Sports',
      theme: ThemeData(primarySwatch: Colors.red),
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

/* const List<Choice> choices = const <Choice>[
  const Choice(title: 'Level 1'),
  const Choice(title: 'Level 2'),
  const Choice(title: 'Level 3'),
  const Choice(title: 'Level 4'),
  const Choice(title: 'Level 5'),
  const Choice(title: 'Elite'),
]; */

class _MyHomePageState extends State<MyHomePage> {
  /* _setName(String s) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', s);
  }

  Future<String> _getName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('name');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          RaisedButton(
            child: new Text('View Person List'),
            onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      return PersonList(title: widget.title);
                    },
                  ),
                ),
          ),
          TextField(
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(hintText: 'Please enter your name'),
            onSubmitted: (String name) {
              _setName(name);
            },
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
            print('e');
          },
        child: new Icon(Icons.add),
      ),
    );
  } */
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: new Text('eat shit')
    );
  } 
}

/* class PersonList extends StatefulWidget {
  PersonList({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _PersonListState createState() => _PersonListState();
} */

/* class _PersonListState extends State<PersonList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: _getStreamBuilder(),
      ),
    );
  }

  Widget _getStreamBuilder() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          Firestore.instance.collection('users').orderBy('Name').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Text('Loading...');
          default:
            return ListView.separated(
              itemCount: snapshot.data.documents.length,
              separatorBuilder: (BuildContext context, int index) => Divider(),
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  child: ListTile(
                    title: Text(
                        snapshot.data.documents[index]['Name'].toString() ??
                            'Name Not Found'),
                    trailing: Text(
                        snapshot.data.documents[index]['Level'].toString() ??
                            'Level Not Found'),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) {
                          return PersonView(
                              name: snapshot.data.documents[index]['Name'],
                              fid: snapshot.data.documents[index].documentID);
                        },
                      ),
                    );
                  },
                );
              },
            );
        }
      },
    );
  }
} */

/* class PersonView extends StatefulWidget {
  final String name;
  final String fid;
  PersonView({Key key, this.name, this.fid}) : super(key: key);
  @override
  _PersonViewState createState() => _PersonViewState();
}

class _PersonViewState extends State<PersonView> {
  Choice _selectedChoice = choices[0];

  void _selectLevel(Choice choice) {
    setState(() {
      _selectedChoice = choice;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(_selectedChoice.title);
    return Scaffold(
        appBar: AppBar(
          title: Text(
              '${widget.name} - ${_selectedChoice.title}' ?? 'No Name Found'),
          actions: <Widget>[
            PopupMenuButton<Choice>(
              onSelected: _selectLevel,
              itemBuilder: (BuildContext context) {
                return choices.map((Choice choice) {
                  return PopupMenuItem<Choice>(
                    value: choice,
                    child: Text(choice.title),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: SafeArea(child: _getStreamBuilder()));
  }

  Widget _getStreamBuilder() {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('users')
          .document(widget.fid)
          .collection(_selectedChoice.title)
          .orderBy('Name')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Text('Loading...');
          default:
            return ListView.separated(
              itemCount: snapshot.data.documents.length,
              separatorBuilder: (BuildContext context, int index) => Divider(),
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  child: ListTile(
                    title: Text(
                        snapshot.data.documents[index]['Name'].toString() ??
                            'No Name Found'),
                    trailing: _getIcon(
                      int.parse(
                          snapshot.data.documents[index]['Level'].toString() ??
                              '0'),
                    ),
                  ),
                );
              },
            );
        }
      },
    );
  }

  Widget _getIcon(int code) {
    assert(code >= 0 && code <= 4);
    if (code == 0) return Icon(Icons.close, color: Colors.black);
    if (code == 1) return Icon(Icons.close, color: Colors.red);
    if (code == 2)
      return Icon(IconData('?'.codeUnitAt(0)), color: Colors.amber);
    if (code == 3) return Icon(Icons.check, color: Colors.green);
    if (code == 4) return Icon(IconData('?'.codeUnitAt(0)), color: Colors.blue);
    return Icon(Icons.child_care);
  }
}

class Choice {
  const Choice({this.title});
  final String title;
}
 */