import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:soccer_finder/models.dart';

class OldGames extends StatefulWidget {
  const OldGames({Key? key}) : super(key: key);

  @override
  State<OldGames> createState() => _OldGamesState();
}

class _OldGamesState extends State<OldGames> {
  var isLoading = false;

  var challangeTeams = <Team>[];
  var challangedTeams = <Team>[];
  var places = <Place>[];
  var outcomes = <String>[];

  @override
  void initState() {
    getData();
    super.initState();
  }

  Future getData() async {
    setState(() {
      isLoading = true;
    });

    final challangeQuery = await FirebaseFirestore.instance.collection('challanges').where('status', isEqualTo: 'DONE').get();

    for(final doc in challangeQuery.docs){
      final challanged = doc.get('challangedID');
      final teamsRef = FirebaseFirestore.instance.collection("teams").doc(challanged).withConverter<Team>(
        fromFirestore: (snapshot, _) => Team.fromJson(snapshot.data()!),
        toFirestore: (team, _) => team.toJson(),
      );
      Team team = await teamsRef.get().then((snapshot) => snapshot.data()!);
      challangeTeams.add(team);

      final challanger = doc.get('challangerID');
      final teamsRef2 = FirebaseFirestore.instance.collection("teams").doc(challanger).withConverter<Team>(
        fromFirestore: (snapshot, _) => Team.fromJson(snapshot.data()!),
        toFirestore: (team, _) => team.toJson(),
      );
      Team team2 = await teamsRef2.get().then((snapshot) => snapshot.data()!);
      challangedTeams.add(team2);

      final placeid = doc.get('place');
      final placesQuery = FirebaseFirestore.instance.collection('places').doc(placeid).withConverter<Place>(
        fromFirestore: (snapshot, _) => Place.fromJson(snapshot.data()!),
        toFirestore: (place, _) => place.toJson(),
      );
      Place place = await placesQuery.get().then((snapshot) => snapshot.data()!);
      places.add(place);

      outcomes.add(doc.get('output'));

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      body: ListView.builder(
          padding: EdgeInsets.zero,
          physics: const AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: challangeTeams.length,
          itemBuilder: (context, index) {
            var team1 = challangeTeams[index];
            var team2 = challangedTeams[index];
            var place = places[index];
            var outcome = outcomes[index];
            return ListTile(
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: team1.linkToPicture.isNotEmpty ? NetworkImage(team1.linkToPicture) : null,
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: team2.linkToPicture.isNotEmpty ? NetworkImage(team2.linkToPicture) : null,
                  ),
                ],
              ),
              trailing: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: place.linkToImage.isNotEmpty ? NetworkImage(place.linkToImage) : null,
              ),
              onTap: (){},
              title: Text('${team1.name} gegen ${team2.name}'),
              subtitle: Text('Ausgang: $outcome'),
            );
          }
      ),
    );
  }
}
