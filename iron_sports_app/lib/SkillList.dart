import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuple/tuple.dart';

class SkillList extends StatefulWidget {
  final bool admin;
  SkillList({Key key, this.admin = false}) : super(key: key);
  @override
  _SkillListState createState() => _SkillListState();
}

class _SkillListState extends State<SkillList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Skills'),
      ),
      body: _getStreamBuilder(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!widget.admin) return;
          _getDialog().then((Tuple2<String, String> s) {
            Firestore.instance.collection('skills').add(
              <String, dynamic>{
                'Name': s.item1,
                'Level': s.item2 == 'Elite'
                    ? s.item2
                    : s.item2.substring(s.item2.indexOf(' ') + 1),
              },
            );
            List<String> userIDs = new List();
            CollectionReference users = Firestore.instance.collection('users');
            users.getDocuments().then(
              (QuerySnapshot qs) {
                for (DocumentSnapshot ds in qs.documents) {
                  userIDs.add(ds.documentID);
                }
              },
            ).then(
              (aNull) {
                for (String uid in userIDs) {
                  Firestore.instance
                      .collection('users')
                      .document(uid)
                      .collection(s.item2)
                      .add(
                    <String, dynamic>{
                      'Name': s.item1,
                      'Level': '0',
                    },
                  );
                }
              },
            );
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<Tuple2<String, String>> _getDialog() async {
    return showDialog<Tuple2<String, String>>(
      context: context,
      child: MyDialog(title: 'Add Skill'),
    );
  }

  Widget _getStreamBuilder() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          Firestore.instance.collection('skills').orderBy('Level').snapshots(),
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
                        (snapshot.data.documents[index]['Level'].toString() ==
                                        'Elite'
                                    ? ''
                                    : 'Level ') +
                                snapshot.data.documents[index]['Level']
                                    .toString() ??
                            'Level Not Found'),
                  ),
                  onLongPress: () {
                    if (!widget.admin) return;
                    showAreYouSureDialog(context).then(
                      (bool delete) {
                        if (delete) {
                          Firestore.instance
                              .collection('skills')
                              .document(
                                  snapshot.data.documents[index].documentID)
                              .delete();
                          String skillName =
                              snapshot.data.documents[index]['Name'];
                          String skillCol =
                              snapshot.data.documents[index]['Level'];

                          if (skillCol != 'Elite')
                            skillCol = 'Level ' + skillCol;
                          Firestore.instance
                              .collection('users')
                              .getDocuments()
                              .then(
                            (QuerySnapshot qs) {
                              qs.documents.forEach(
                                (DocumentSnapshot ds) {
                                  Firestore.instance
                                      .document('users/${ds.documentID}')
                                      .collection(skillCol)
                                      .getDocuments()
                                      .then(
                                    (QuerySnapshot ss) {
                                      ss.documents.forEach(
                                        (DocumentSnapshot ds2) {
                                          if (ds2['Name'] == skillName) {
                                            Firestore.instance
                                                .document(
                                                    'users/${ds.documentID}/$skillCol/${ds2.documentID}')
                                                .delete();
                                          }
                                        },
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          );
                        }
                      },
                    );
                  },
                );
              },
            );
        }
      },
    );
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
  String level = 'Level 1';
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(widget.title),
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 170.0,
              padding: EdgeInsets.all(8.0),
              child: TextField(
                textAlign: TextAlign.center,
                controller: controlerName,
              ),
            ),
            Container(
              width: 100.0,
              padding: EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                isExpanded: true,
                value: level,
                onChanged: (String newValue) {
                  setState(() {
                    level = newValue;
                  });
                },
                items: <String>[
                  'Level 1',
                  'Level 2',
                  'Level 3',
                  'Level 4',
                  'Level 5',
                  'Elite'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        Center(
          child: Container(
            padding: EdgeInsets.all(8.0),
            child: SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, Tuple2(controlerName.value.text, level));
              },
              child: const Text(
                'Save',
                textScaleFactor: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Future<bool> showAreYouSureDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: new Text("Delete?"),
        content: new Text("This action cannot be reversed"),
        actions: <Widget>[
          new FlatButton(
            child: new Text("Yes"),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
          new FlatButton(
            child: new Text("No"),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ],
      );
    },
  );
}
