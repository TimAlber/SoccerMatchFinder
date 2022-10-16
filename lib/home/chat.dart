import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soccer_finder/models.dart';

class Chat extends StatefulWidget {
  final String challangeId;
  const Chat({Key? key, required this.challangeId}) : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {

  final chatTextController = TextEditingController();
  String? userId;
  String? teamId;
  String? userName;
  String? teamName;

  var isLoading = false;

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
    userId = FirebaseAuth.instance.currentUser!.uid;
    userName = FirebaseAuth.instance.currentUser!.displayName!;
    getTeam();
    super.initState();
  }

  Future getTeam() async{
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('teamId') != null) {
      teamId = prefs.getString('teamId');

      final doc = await FirebaseFirestore.instance.collection("teams").doc(teamId).get();
      teamName = doc.get('name');
      setState(() {
        isLoading = false;
      });
    } else {
      print('Error, no team id found');
    }
  }

  @override
  Widget build(BuildContext context) {

    final chatQuery = FirebaseFirestore.instance.collection('challanges')
        .doc(widget.challangeId)
        .collection('chat')
        .orderBy('created')
        .withConverter<ChatMessage>(
      fromFirestore: (snapshot, _) => ChatMessage.fromJson(snapshot.data()!),
      toFirestore: (chat, _) => chat.toJson(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: !isLoading ? Stack(
        children: <Widget>[
          FirestoreListView<ChatMessage>(
            physics: AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            query: chatQuery,
            itemBuilder: (context, snapshot) {
              ChatMessage message = snapshot.data();
              final isFromMyTeam = message.teamId == teamId!;
              return Column(
                children: [
                  ListTile(
                    title: Text(message.message, textAlign: isFromMyTeam ? TextAlign.right : TextAlign.left),
                    subtitle: Text(message.userName, textAlign: isFromMyTeam ? TextAlign.right : TextAlign.left),
                  ),
                  const Divider(),
                ],
              );
            },
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: const EdgeInsets.only(left: 10,bottom: 10,top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  const SizedBox(width: 15,),
                  Expanded(
                    child: TextField(
                      controller: chatTextController,
                      decoration: const InputDecoration(
                          hintText: "Schreibe eine Nachricht...",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none
                      ),
                    ),
                  ),
                  const SizedBox(width: 15,),
                  FloatingActionButton(
                    onPressed: () async {
                      final data = {
                        "message": chatTextController.text,
                        "userName": userName!,
                        "userId": userId!,
                        "teamId": teamId!,
                        "teamName": teamName!,
                        "created": DateTime.now(),
                      };
                      await FirebaseFirestore.instance.collection("challanges").doc(widget.challangeId).collection('chat').add(data);
                      chatTextController.clear();
                    },
                    backgroundColor: Colors.blue,
                    elevation: 0,
                    child: const Icon(Icons.send,color: Colors.white,size: 18,),
                  ),
                ],
              ),
            ),
          ),
        ],
      ) : const Center(child: CircularProgressIndicator()),
    );
  }
}
