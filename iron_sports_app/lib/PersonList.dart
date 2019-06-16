import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iron_sports_app/PersonView.dart';
import 'package:iron_sports_app/SkillList.dart';
import 'package:tuple/tuple.dart';

class PersonList extends StatefulWidget {
  final bool admin;
  PersonList({Key key, this.title, this.admin}) : super(key: key);
  final String title;
  @override
  _PersonListState createState() => _PersonListState();
}

class _PersonListState extends State<PersonList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: _getStreamBuilder(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          if (!widget.admin) return;
          showDialog<Tuple2<String, String>>(
            context: context,
            child: MyDialog(title: 'Add Person'),
          ).then(
            (Tuple2<String, String> s) {
              Firestore.instance.collection('users').add(
                <String, dynamic>{
                  'Name': s.item1,
                  'Level': (s.item2 == 'Elite'
                      ? 'Elite'
                      : s.item2.substring(s.item2.indexOf(' ') + 1))
                },
              ).then(
                (DocumentReference dr) {
                  Firestore.instance.collection('skills').getDocuments().then(
                    (QuerySnapshot qs) {
                      qs.documents.forEach(
                        (DocumentSnapshot sdr) {
                          dr
                              .collection(sdr.data['Level'] == 'Elite'
                                  ? 'Elite'
                                  : 'Level ' + sdr.data['Level'])
                              .add(
                            <String, dynamic>{
                              'Name': sdr.data['Name'],
                              'Level': '0',
                            },
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
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
                    trailing: Text((snapshot.data.documents[index]['Level']
                                    .toString() ==
                                'Elite'
                            ? snapshot.data.documents[index]['Level'].toString()
                            : 'Level ' +
                                snapshot.data.documents[index]['Level']
                                    .toString()) ??
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
                  onLongPress: () {
                    if (!widget.admin) return;
                    showAreYouSureDialog(context).then((bool b) {
                      if (b)
                        Firestore.instance
                            .document(
                                '/users/${snapshot.data.documents[index].documentID}')
                            .delete();
                    });
                  },
                );
              },
            );
        }
      },
    );
  }
}
