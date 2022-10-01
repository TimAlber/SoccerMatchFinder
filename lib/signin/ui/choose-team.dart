import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:soccer_finder/models.dart';
import 'package:flutterfire_ui/firestore.dart';

class ChooseTeam extends StatefulWidget {
  const ChooseTeam({Key? key}) : super(key: key);

  @override
  State<ChooseTeam> createState() => _ChooseTeamState();
}

class _ChooseTeamState extends State<ChooseTeam> {
  var db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final teamsQuery = FirebaseFirestore.instance.collection('teams')
        .withConverter<Team>(
      fromFirestore: (snapshot, _) => Team.fromJson(snapshot.data()!),
      toFirestore: (team, _) => team.toJson(),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wähle dein Team oder füge eins Hinzu'),
      ),
      body: FirestoreListView<Team>(
        query: teamsQuery,
        itemBuilder: (context, snapshot) {
          // Data is now typed!
          Team team = snapshot.data();

          //return Text(team.name);
          return ListTile(
            title: Text(team.name),
            subtitle: Text(team.points.toString()),
          );
        },
      ),
    );
  }
}
