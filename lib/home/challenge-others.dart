import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soccer_finder/models.dart';

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
                leading: const CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage('https://www.wacker1921.de/wp-content/uploads/2019/04/1FC_Wacker_1921_Lankwitz_Logo.png'),
                ),
                title: Text(team.name),
                subtitle: Text(team.points.toString()),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () async {

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
