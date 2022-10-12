import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soccer_finder/models.dart';
import 'package:soccer_finder/signin/buisness-logic/service.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class OtherTeam extends StatefulWidget {
  final Team team;
  const OtherTeam({Key? key, required this.team}) : super(key: key);

  @override
  State<OtherTeam> createState() => _OtherTeamState();
}

class _OtherTeamState extends State<OtherTeam> {
  String? myTeamId;
  var _isAlreadyInChallange = false;
  var _isloading = false;

  @override
  void initState() {
    getIsInChallange();
    super.initState();
  }

  void getIsInChallange() async {
    setState(() {
      _isloading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    myTeamId = prefs.getString('teamId')!;

    AuthService()
        .isInChallange(
      challanger: myTeamId!,
      challanged: widget.team.id!,
    )
        .then((value) {
      _isAlreadyInChallange = value;
      setState(() {
        _isloading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.team.name} Herausfordern'),
      ),
      body: !_isloading
          ? Column(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: SizedBox(
                      width: 300.0,
                      height: 300.0,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: widget.team.linkToPicture.isNotEmpty
                            ? NetworkImage(widget.team.linkToPicture)
                            : null,
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
                        title: Center(
                            child: Text(
                                'Punkte: ${widget.team.points.toString()}')),
                      ),
                      if (!_isAlreadyInChallange)
                        Center(
                            child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: OutlinedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(30.0))),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => _addChallangeDialog(context),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text('${widget.team.name} Herausfordern'),
                            ),
                          ),
                        )),
                      if (_isAlreadyInChallange)
                        Center(
                            child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                    '${widget.team.name} wurde berits herausgefordert oder hat dich heraus gefordert.')))
                    ],
                  ),
                )
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _addChallangeDialog(BuildContext context) {
    final myAdressController = TextEditingController();
    DateTime? selectedDate;
    return AlertDialog(
      title: const Text('Neue Herausforderung:'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          TextField(
            controller: myAdressController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Adresse',
                hintText: 'Musterstraße 123'),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: TextButton(
              style: ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.all(Colors.grey),
                  foregroundColor:
                  MaterialStateProperty.all(Colors.black),
                  minimumSize: MaterialStateProperty.all(
                      const Size(100, 50))),
              onPressed: () async {
                DatePicker.showDateTimePicker(context,
                    showTitleActions: true,
                    minTime: DateTime.now(),
                    maxTime: DateTime(2050),
                    onConfirm: (date) {
                      selectedDate = date;
                    },
                    locale: LocaleType.de);
              },
              child: Text('Wähle ein Termin'),
            ),
          ),
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
            if(selectedDate == null || myAdressController.text.isEmpty){
              return;
            }
            AuthService().addChallange(
              challanger: myTeamId!,
              challanged: widget.team.id!,
              time: selectedDate!,
              place: myAdressController.text,
            );
            setState(() {
              _isAlreadyInChallange = true;
            });
            Navigator.of(context).pop();
          },
          child: const Text('Ok'),
        )
      ],
    );
  }
}
