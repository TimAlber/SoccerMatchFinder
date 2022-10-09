import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soccer_finder/models.dart';

import 'other-team.dart';

class ChallengeOthers extends StatefulWidget {
  const ChallengeOthers({Key? key}) : super(key: key);

  @override
  State<ChallengeOthers> createState() => _ChallengeOthersState();
}

class _ChallengeOthersState extends State<ChallengeOthers> {

  String? myTeamId;

  @override
  void initState() {
    printTeamId();
    super.initState();
  }

  Future<void> printTeamId() async {
    final prefs = await SharedPreferences.getInstance();
    if(prefs.getString('teamId') != null){
      setState(() {
        myTeamId = prefs.getString('teamId')!;
      });
    } else {
      print('Error, no team id found');
    }
  }

  @override
  Widget build(BuildContext context) {
    if(myTeamId == null){
      return const Center(child: CircularProgressIndicator());
    }

    final teamsQuery = FirebaseFirestore.instance.collection('teams').where('id', isNotEqualTo: myTeamId)
        .withConverter<Team>(
      fromFirestore: (snapshot, _) => Team.fromJson(snapshot.data()!),
      toFirestore: (team, _) => team.toJson(),
    );
    
    return Scaffold(
      body: FirestoreListView<Team>(
        query: teamsQuery,
        itemBuilder: (context, snapshot) {
          Team team = snapshot.data();
          return Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: team.linkToPicture.isNotEmpty ? NetworkImage(team.linkToPicture) : null,
                ),
                title: Text(team.name),
                subtitle: Text(team.points.toString()),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OtherTeam(team: team,)),
                  );
                },
              ),
              const Divider(),
            ],
          );
        },
       ),
    );
  }
}
