import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soccer_finder/models.dart';
import 'package:soccer_finder/signin/buisness-logic/service.dart';

class OtherTeam extends StatefulWidget {
  final Team team;
  const OtherTeam({Key? key, required this.team}) : super(key: key);

  @override
  State<OtherTeam> createState() => _OtherTeamState();
}

class _OtherTeamState extends State<OtherTeam> {

  var _isAlreadyInChallange = false;

  @override
  void initState() {
    super.initState();
  }

  // void getIs

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.team.name} Herausfordern'),
      ),
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                width: 300.0,
                height: 300.0,
                child:
                CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: widget.team.linkToPicture.isNotEmpty ? NetworkImage(widget.team.linkToPicture) : null,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Center(child: Text('Name: ${widget.team.name}')),
                ),
                ListTile(
                  title: Center(child: Text('Punkte: ${widget.team.points.toString()}')),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: OutlinedButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
                      ),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final myTeamId = prefs.getString('teamId')!;

                        AuthService().addChallange(
                            challanger: myTeamId,
                            challanged: widget.team.id!
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text('${widget.team.name} Herausfordern'),
                      ),
                    ),
                  )
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

