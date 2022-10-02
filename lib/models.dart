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