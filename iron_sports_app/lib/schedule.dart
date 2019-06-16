import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Schedule extends StatefulWidget {
  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  DateTime start = DateTime(DateTime.now().year, DateTime.now().month,
      DateTime.now().day, 19, 0, 0, 0, 0);
  DateFormat format = DateFormat('jm');
  int minutes = 20;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              buildList(
                ['Warmup', 'Station 1', 'Station 2', 'Station 3', 'Station 4'],
                start,
                Duration(minutes: minutes),
              ),
              Text('e')
            ],
          ),
        ),
      ),
    );
  }

  ListView buildList(List<String> names, DateTime start, Duration duration) {
    return ListView.builder(
      itemCount: names.length,
      itemBuilder: (BuildContext context, int index) {
        return getTime(
          names[index],
          start.add(duration * index),
          start.add(duration * (index + 1)),
        );
      },
    );
  }

  Widget getTime(String label, DateTime a, DateTime b) {
    return InkWell(
      onLongPress: () {},
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Text(
                '$label: ${format.format(a)} - ${format.format(b)}',
                textScaleFactor: 1.5,
              )
            ],
          ),
        ),
      ),
    );
  }
}
