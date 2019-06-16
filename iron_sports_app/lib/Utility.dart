class Choice {
  const Choice({this.title});
  final String title;
  String toString() => title;
}

enum Level { No_Data, Cant_Do, Maybe, Can_Do, Unown }
enum SkillLevel { Level_1, Level_2, Level_3, Level_4, Level_5, Elite }
String slashSeperatedList(List<String> args) {
  String ret = '';
  for (int i = 0; i < args.length; i++) ret += '/' + args[i];
  return ret;
}
