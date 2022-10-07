import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:soccer_finder/home/home-page.dart';
import 'package:soccer_finder/models.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:soccer_finder/signin/buisness-logic/service.dart';

class ChooseTeam extends StatefulWidget {
  const ChooseTeam({Key? key}) : super(key: key);

  @override
  State<ChooseTeam> createState() => _ChooseTeamState();
}

class _ChooseTeamState extends State<ChooseTeam> {
  var db = FirebaseFirestore.instance;
  XFile? picture;
  var isloading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final teamsQuery =
        FirebaseFirestore.instance.collection('teams').withConverter<Team>(
              fromFirestore: (snapshot, _) => Team.fromJson(snapshot.data()!),
              toFirestore: (team, _) => team.toJson(),
            );

    return Scaffold(
      body: !isloading ? FirestoreListView<Team>(
        query: teamsQuery,
        itemBuilder: (context, snapshot) {
          Team team = snapshot.data();
          return Column(
            children: [
              ListTile(
                title: Text(team.name),
                subtitle: Text(team.points.toString()),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () async {
                  showDialog(
                    context: context,
                    builder: (_) => _showPwPopupDialog(context, team),
                  );
                },
              ),
              const Divider(),
            ],
          );
        },
      ) : const Center(child: CircularProgressIndicator()),
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
      content: SingleChildScrollView(
        child: Column(
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
              style:
                  TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 10),
              'Das passwort kannst du deinen Team Mitgliedern sagen. Es dient dazu das nicht jeder in dein Team gehen kann.',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25),
              child: TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.grey),
                      foregroundColor: MaterialStateProperty.all(Colors.black),
                      minimumSize:
                          MaterialStateProperty.all(const Size(100, 50))),
                  onPressed: () {
                    showModalSheet();
                  },
                  child: picture == null
                      ? Text('Team Bild hinzufügen')
                      : Text('Team Bild ändern')),
            ),
          ],
        ),
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
            setState(() {
              isloading = true;
            });
            Navigator.of(context).pop();
            final newTeam = await AuthService().addNewTeam(
                name: newTeamNameTextFieldController.text,
                pw: newTeamPwTextFieldController.text,
                teamPic: picture,
                );
            if (newTeam == null) {
              setState(() {
                isloading = false;
              });
              Logger().e('Cant create team');
            } else {
              final worked = await AuthService().addUserToTeam(
                  userId: AuthService().getSignedInUserID()!,
                  teamId: newTeam.id!);
              if (worked) {
                setState(() {
                  isloading = false;
                });
                openHomePage();
              } else {
                setState(() {
                  isloading = false;
                });
                Logger().e('Cant join team');
              }
            }
          },
          child: const Text('Anlegen'),
        )
      ],
    );
  }

  void openHomePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  Widget _showPwPopupDialog(BuildContext context, Team team) {
    final pwTextFieldController = TextEditingController();
    return AlertDialog(
      title: const Text('Passwort des Teams: '),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          TextField(
              controller: pwTextFieldController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Passwort',
              ))
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
            if (pwTextFieldController.text == team.pw) {
              final worked = await AuthService().addUserToTeam(
                  userId: AuthService().getSignedInUserID()!, teamId: team.id!);
              if (worked) {
                openHomePage();
              } else {
                Logger().e('Cant join team');
              }
            } else {
              showErrorAlert(
                  context,
                  "Passwort ist falsch. Probiere es nochmal.",
                  const SizedBox.shrink());
            }
          },
          child: const Text('Ok'),
        )
      ],
    );
  }

  void showModalSheet() {
    showModalBottomSheet<void>(
      elevation: 10,
      context: context,
      builder: (BuildContext context) {
        return ListView(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Team Bild mit Kamera machen'),
              onTap: () {
                final ImagePicker _picker = ImagePicker();
                _picker.pickImage(source: ImageSource.camera).then((value) => {
                      setState(() {
                        picture = value;
                        Navigator.of(context).pop();
                        showErrorAlert(
                          context,
                          'Dieses Bild wird als Team Bild hinzugefügt:',
                          Container(
                              width: 120.0,
                              height: 120.0,
                              decoration:  BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image:  FileImage(File(picture!.path))
                                  )
                              )
                          ),
                        );
                      }),
                    });
              },
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text('Team Bild aus Gallery wählen'),
              onTap: () {
                final ImagePicker _picker = ImagePicker();
                _picker.pickImage(source: ImageSource.gallery).then((value) => {
                      setState(() {
                        picture = value;
                        Navigator.of(context).pop();
                        showErrorAlert(
                          context,
                          'Dieses Bild wird als Team Bild hinzugefügt:',

                          Container(
                              width: 120.0,
                              height: 120.0,
                              decoration:  BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image:  FileImage(File(picture!.path))
                                  )
                              )
                          ),
                        );
                      }),
                    });
              },
            )
          ],
        );
      },
    );
  }

  void showErrorAlert(BuildContext context, String text, Widget body) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(title: Text(text), content: body));
  }
}
