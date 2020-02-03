import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firetest/model/course.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firetest/ui/messaging.dart';
import 'package:flutter_firetest/ui/message.dart';



class CourseInformation extends StatefulWidget{
  final Course course ;
  CourseInformation(this.course);
  @override
  State<StatefulWidget> createState() => new _CourseInformationState();

}


final courseReference = FirebaseDatabase.instance.reference().child('course');


class _CourseInformationState extends State<CourseInformation>{
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
   TextEditingController titleController =
  TextEditingController(text: ' ');
   TextEditingController bodyController =
  TextEditingController(text: ' ');
   List<Message> messages = [];
  File image;

  TextEditingController _nameController;

  //String courseImage;


  picker()async{
    File img = await ImagePicker.pickImage(source: ImageSource.gallery);
    // File img = await ImagePicker.pickImage(source: ImageSource.camera);
    if(img != null){
      image = img;
      setState(() {

      });
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nameController =new TextEditingController(text: widget.course.name);

    _firebaseMessaging.onTokenRefresh.listen(sendTokenToServer);
    _firebaseMessaging.getToken();

    _firebaseMessaging.subscribeToTopic('all');

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        final notification = message['notification'];
        setState(() {
          messages.add(Message(
              title: notification['title'], body: notification['body']));
        });
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");

        final notification = message['data'];
        setState(() {
          messages.add(Message(
            title: '${notification['title']}',
            body: '${notification['body']}',
          ));
        });
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
   /* courseImage = widget.course.courseImage;
    print(courseImage);*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Course Information'),backgroundColor: Colors.green,),

      body: ListView(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 10.0),

            child: Column(
              children: <Widget>[

                /* Container(
              child:
                child: courseImage == ''
                    ? Text('No Image')
                    : Image.network(courseImage+'?alt=media'),
              ),
            ,*/


                Text( " Course Name : " +
                    widget.course.name,
                  style: TextStyle(fontSize: 20.0,color: Colors.black),
                ),
                Padding(padding: EdgeInsets.only(top: 8.0),),
                Text( " Course Hours : " +
                    widget.course.hours,
                  style: TextStyle(fontSize: 16.0,color: Colors.black),
                ),
                Padding(padding: EdgeInsets.all(15.0),),
                Text( " Number of Student : " +
                    widget.course.numofstud,
                  style: TextStyle(fontSize: 16.0,color: Colors.black),
                ),
                Padding(padding: EdgeInsets.only(top: 8.0),),
                Text( " The Major : " +
                    widget.course.department,
                  style: TextStyle(fontSize: 16.0,color: Colors.black),
                ),
                Padding(padding: EdgeInsets.only(top: 8.0),),
                Text( " Description : " +
                    widget.course.description,
                  maxLines: 5,
                  style: TextStyle(

                      fontSize: 16.0,color: Colors.black),
                ),
                Padding(padding: EdgeInsets.only(top: 30.0),),

                Container(
                    child: Center(
                      child: image == null ? Text('') : Image.file(image),
                    )),

                FlatButton(
                  child: Text('upload'),
                  color: Colors.green,
                  onPressed: (){

                    if(true){
                      var now = new DateTime.now() ;
                      //List<String> fullImageName =  'images/${_nameController.text}-$now'+'.jpg';
                      var fullImageName =  'images/${_nameController.text}-$now'+'.jpg';
                      var fullImageName2 =  'images%2F${_nameController.text}-$now'+'.jpg';
                      final StorageReference ref = FirebaseStorage.instance.ref()
                          .child(fullImageName);
                      final StorageUploadTask task = ref.putFile(image);
                      //final String serverToken = 'AAAAMF2P81Y:APA91bF2YnaXiOWZVtFFlMbnO1SE9qtBG7c6vopK7CuIof8oMFuM_uoxwJUMiJ2nhQV3AXmjjdwjOllGITV5GautjIVIICqnWLmAfsQgsxYSYK_aBzE6oft2RHWmwYGrV-y8cTMWxaqY';
                      final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
                      var part1 = 'https://firebasestorage.googleapis.com/v0/b/testt-1589b.appspot.com/o/';
                      var fullPathImage = part1 +  fullImageName2;
                      sendNotification(_nameController.text);
                      if(widget.course.material != null){
                        courseReference.child(widget.course.id).update({
                              'material': widget.course.material+'+'+ fullPathImage,
                                  }
                              );
                      }else{
                        courseReference.child(widget.course.id).update({
                          'material': fullPathImage,
                        }
                        );
                        }
                      Navigator.pop(context);
                    }

                  },
                ),
              ],


            ),
          ),
        ],
      ),

        backgroundColor: Colors.greenAccent,

        floatingActionButton: FloatingActionButton(

          onPressed: picker,
          child: Icon(Icons.attach_file),


        )
    );
  }
  Future sendNotification(String x) async {
    final response = await Messaging.sendToAll(
      title: titleController.text+"Prof",
      body: bodyController.text+'add new matirial to Course:'+x,
      // fcmToken: fcmToken,
    );

    if (response.statusCode != 200) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content:
        Text('[${response.statusCode}] Error message: ${response.body}'),
      ));
    }
  }

  void sendTokenToServer(String fcmToken) {
    print('Token: $fcmToken');
    // send key to your server to allow server to use
    // this token to send push notifications
  }

}