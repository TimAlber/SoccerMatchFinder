import 'package:cloud_firestore/cloud_firestore.dart';

class Team {
  Team({
    required this.name,
    required this.points,
    required this.linkToPicture,
    required this.pw,
    this.id,
  });

  Team.fromJson(Map<String, Object?> json)
      : this(
    name: json['name']! as String,
    points: json['points']! as int,
    linkToPicture: json['linkToPicture']! as String,
    pw: json['pw']! as String,
    id: json['id'] != null ? (json['id']! as String) : null,
  );

  final String name;
  final int points;
  final String linkToPicture;
  final String pw;
  String? id;

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'points': points,
      'linkToPicture': linkToPicture,
      'pw': pw,
      'id': id,
    };
  }
}

class ChatMessage{
  ChatMessage({
    required this.created,
    required this.message,
    required this.teamId,
    required this.teamName,
    required this.userId,
    required this.userName
  });

  final Timestamp created;
  final String message;
  final String teamId;
  final String teamName;
  final String userId;
  final String userName;

  ChatMessage.fromJson(Map<String, Object?> json)
      : this(
    created: json['created']! as Timestamp,
    message: json['message']! as String,
    teamId: json['teamId']! as String,
    teamName: json['teamName']! as String,
    userId: json['userId']! as String,
    userName: json['userName']! as String,
  );

  Map<String, Object?> toJson() {
    return {
      'created': created,
      'message': message,
      'teamId': teamId,
      'teamName': teamName,
      'userId': userId,
      'userName': userName,
    };
  }
}