class Team {
  Team({
    required this.name,
    required this.points,
    required this.linkToPicture,
    required this.pw,
  });

  Team.fromJson(Map<String, Object?> json)
      : this(
    name: json['name']! as String,
    points: json['points']! as int,
    linkToPicture: json['linkToPicture']! as String,
    pw: json['pw']! as String,
  );

  final String name;
  final int points;
  final String linkToPicture;
  final String pw;

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'points': points,
      'linkToPicture': linkToPicture,
      'pw': pw,
    };
  }
}