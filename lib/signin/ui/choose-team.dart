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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => _addNewTeamPopupDialog(context),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _addNewTeamPopupDialog(BuildContext context) {
    final newTeamNameTextFieldController = TextEditingController();
    final newTeamPwTextFieldController = TextEditingController();
    return AlertDialog(
      title: const Text('Neues Team anlegen:'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          TextField(
              controller: newTeamNameTextFieldController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Name des neuen Teams',
              ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: TextField(
              controller: newTeamPwTextFieldController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Passwort',
              ),
            ),
          ),
          Text(
            style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 10),
            'Das passwort kannst du deinen Team Mitgliedern sagen. Es dient dazu das nicht jeder in dein Team gehen kann.',
          )
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Abbrechen'),
        ),
        TextButton(
          onPressed: () async {
          },
          child: const Text('Anlegen'),
        )
      ],
    );
  }
}
