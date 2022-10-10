import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soccer_finder/models.dart';

class ChallangedTeams extends StatefulWidget {
  const ChallangedTeams({Key? key}) : super(key: key);

  @override
  State<ChallangedTeams> createState() => _ChallangedTeamsState();
}

class _ChallangedTeamsState extends State<ChallangedTeams> {
  String? myTeamId;

  var challangeID = [];
  var challangeTeams = <Team>[];

  var isLoading = false;

  @override
  void initState() {
    printTeamId();
    super.initState();
  }

  Future<void> printTeamId() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('teamId') != null) {
      if (mounted) {
        setState(() {
          myTeamId = prefs.getString('teamId')!;
          isLoading = true;
        });
      }
    } else {
      print('Error, no team id found');
    }

    final challangeQuery = await FirebaseFirestore.instance
        .collection('challanges')
        .where('challangerID', isEqualTo: myTeamId)
        .where('status', isNotEqualTo: 'DONE')
        .get();
    
    for(final doc in challangeQuery.docs){
      final challange = doc.get('challangeID');
      challangeID.add(challange);

      final challanged = doc.get('challangedID');
      final teamsRef = FirebaseFirestore.instance.collection("teams").doc(challanged).withConverter<Team>(
        fromFirestore: (snapshot, _) => Team.fromJson(snapshot.data()!),
        toFirestore: (team, _) => team.toJson(),
      );
      Team team = await teamsRef.get().then((snapshot) => snapshot.data()!);
      challangeTeams.add(team);
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (myTeamId == null || isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      body: ListView.builder(
          padding: EdgeInsets.zero,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: challangeTeams.length,
          itemBuilder: (context, index) {
            var team = challangeTeams[index];
            var challangeId = challangeID[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: team.linkToPicture.isNotEmpty ? NetworkImage(team.linkToPicture) : null,
              ),
              title: Text(team.name),
              subtitle: Text(challangeId),
            );
          }
      )
    );
  }
}
