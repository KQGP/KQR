import 'package:hive/hive.dart';

part 'team_set.g.dart';

@HiveType(typeId: 0)
class TeamSet extends HiveObject {
  @HiveField(0)
  String name;
  @HiveField(1)
  List<String> names;
  @HiveField(2)
  List<List<String>> teams;

  TeamSet({required this.name, required this.names, required this.teams});
} 