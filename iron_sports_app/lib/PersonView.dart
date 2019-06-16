import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iron_sports_app/Utility.dart';
const List<Choice> choices = const <Choice>[
  const Choice(title: 'Level 1'),
  const Choice(title: 'Level 2'),
  const Choice(title: 'Level 3'),
  const Choice(title: 'Level 4'),
  const Choice(title: 'Level 5'),
  const Choice(title: 'Elite'),
];

class PersonView extends StatefulWidget {
  final bool admin;
  final String name;
  final String fid;
  PersonView({Key key, this.name, this.fid, this.admin = false})
      : super(key: key);
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
                  onLongPress: () {
                    if (!widget.admin) return;
                    _setLevel().then((int a) {
                      final DocumentReference postRef =
                          Firestore.instance.document(slashSeperatedList([
                        'users',
                        widget.fid,
                        _selectedChoice.toString(),
                        snapshot.data.documents[index].documentID
                      ]));
                      Firestore.instance.runTransaction((Transaction tx) async {
                        DocumentSnapshot postSnapshot = await tx.get(postRef);
                        if (postSnapshot.exists) {
                          await tx.update(postRef,
                              <String, dynamic>{'Level': a.toString()});
                        }
                      });
                    });
                  },
                );
              },
            );
        }
      },
    );
  }

  Future<int> _setLevel() async {
    switch (await showDialog<Level>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Select assignment'),
            children: <Widget>[
              SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, Level.No_Data);
                  },
                  child: ListTile(
                    title: Text('No Data'),
                    trailing: _getIcon(0),
                  )),
              SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, Level.Cant_Do);
                  },
                  child: ListTile(
                    title: Text('Cannot Do Skill'),
                    trailing: _getIcon(1),
                  )),
              SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, Level.Maybe);
                  },
                  child: ListTile(
                    title: Text('Can Maybe Do Skill'),
                    trailing: _getIcon(2),
                  )),
              SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, Level.Can_Do);
                  },
                  child: ListTile(
                    title: Text('Can Do Skill'),
                    trailing: _getIcon(3),
                  )),
              SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, Level.Unown);
                  },
                  child: ListTile(
                    title: Text('Unkown'),
                    trailing: _getIcon(4),
                  )),
            ],
          );
        })) {
      case Level.No_Data:
        return 0;
        break;
      case Level.Cant_Do:
        return 1;
        break;
      case Level.Maybe:
        return 2;
        break;
      case Level.Can_Do:
        return 3;
        break;
      case Level.Unown:
        return 4;
        break;
      default:
        return 0;
    }
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
