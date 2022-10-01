import 'package:cloud_firestore/cloud_firestore.dart';

class Team {
  Team({required this.name, required this.points, required this.linkToPicture});

  Team.fromJson(Map<String, Object?> json)
      : this(
    name: json['name']! as String,
    points: json['points']! as int,
    linkToPicture: json['linkToPicture']! as String,
  );

  final String name;
  final int points;
  final String linkToPicture;

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'points': points,
      'linkToPicture': linkToPicture,
    };
  }
}