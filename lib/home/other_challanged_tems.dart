import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soccer_finder/home/single-challange.dart';
import 'package:soccer_finder/models.dart';

class OtherChallangedTeams extends StatefulWidget {
  const OtherChallangedTeams({Key? key}) : super(key: key);

  @override
  State<OtherChallangedTeams> createState() => _OtherChallangedTeamsState();
}

class _OtherChallangedTeamsState extends State<OtherChallangedTeams> {
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
      if(mounted){
        setState(() {
          isLoading = true;
          myTeamId = prefs.getString('teamId')!;
        });
      }
    } else {
      print('Error, no team id found');
    }

    final challangeQuery = await FirebaseFirestore.instance
        .collection('challanges')
        .where('challangedID', isEqualTo: myTeamId)
        .where('status', isNotEqualTo: 'DONE')
        .get();

    for(final doc in challangeQuery.docs){
      final challange = doc.get('challangeID');
      challangeID.add(challange);

      final challanged = doc.get('challangerID');
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
        body: Column(
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text("Teams von denen dein Team herausgefordert wurde.", textAlign: TextAlign.center,),
                )
            ),
            ListView.builder(
                padding: EdgeInsets.zero,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: challangeTeams.length,
                itemBuilder: (context, index) {
                  var team = challangeTeams[index];
                  var challangeId = challangeID[index];
                  print(challangeId);
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: team.linkToPicture.isNotEmpty ? NetworkImage(team.linkToPicture) : null,
                    ),
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SingleChallange(challangeID: challangeId,)),
                      );
                    },
                    title: Text(team.name),
                    subtitle: Text(challangeId),
                  );
                }
            ),
          ],
        )
    );
  }
}
