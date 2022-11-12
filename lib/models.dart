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

class Place{
  Place({
    required this.name,
    required this.adress,
    required this.linkToImage,
    required this.lat,
    required this.lon,
    this.id
  });

  final String name;
  final String adress;
  final String linkToImage;
  final double lat;
  final double lon;
  String? id;

  Place.fromJson(Map<String, Object?> json)
      : this(
    name: json['name']! as String,
    adress: json['adress']! as String,
    linkToImage: json['linkToImage']! as String,
    lat: json['lat']! as double,
    lon: json['lon']! as double,
    id: json['id'] != null ? (json['id']! as String) : null,
  );

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'adress': adress,
      'linkToImage': linkToImage,
      'lat': lat,
      'lon': lon,
      'id': id,
    };
  }
}

class Challange {
  Challange({
    required this.challangeID,
    required this.challangedID,
    required this.challangerID,
    required this.output,
    required this.place,
    required this.status,
    required this.time
  });

  Challange.fromJson(Map<String, Object?> json)
      : this(
    challangeID: json['challangeID']! as String,
    challangedID: json['challangedID']! as String,
    challangerID: json['challangerID']! as String,
    output: json['output']! as String,
    place: json['place']! as String,
    status: json['status']! as String,
    time: json['time']! as Timestamp,
  );

  final String challangeID;
  final String challangedID;
  final String challangerID;
  final String output;
  final String place;
  final String status;
  final Timestamp time;

  Map<String, Object?> toJson() {
    return {
      'challangeID': challangeID,
      'challangedID': challangedID,
      'challangerID': challangerID,
      'output': output,
      'place': place,
      'status': status,
      'time': time,
    };
  }
}