import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firetest/model/course.dart';
import 'package:flutter_firetest/ui/course_screen.dart';
import 'package:flutter_firetest/ui/course_information.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class ListViewCourse extends StatefulWidget{
  @override
  _ListViewCourseState createState()  => new _ListViewCourseState();

}
final courseReference = FirebaseDatabase.instance.reference().child('course');

class _ListViewCourseState extends State<ListViewCourse>{

  List<Course> items;
  StreamSubscription<Event> _onCourseAddedSubscription;
  StreamSubscription<Event> _onCourseChangedSubscription;
  var mymap = {};
  var title = "";
  var body = {};
  var mytoken = '';

  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  new FlutterLocalNotificationsPlugin();
  @override
  void initState(){
    super.initState();
    items = new List();
    _onCourseAddedSubscription = courseReference.onChildAdded.listen(_onCourseAdded);
    _onCourseChangedSubscription = courseReference.onChildChanged.listen(_onCourseUpdated);
    var android = new AndroidInitializationSettings('mipmap/ic_launcher');
    var ios = new IOSInitializationSettings();
    var platform = new InitializationSettings(android, ios);
    flutterLocalNotificationsPlugin.initialize(platform);

    firebaseMessaging.configure(
      onLaunch: (Map<String , dynamic> msg){
        print( "onLaunch called : ${(msg)}");
      },
      onResume: (Map<String , dynamic> msg){
        print( "onResume called : ${(msg)}");
      },
      onMessage:  (Map<String , dynamic> msg){
        print( "onMessage called : ${(msg)}");
        mymap = msg;
        showNotification(msg);
      },
    );


    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true , alert: true , badge:  true));
    firebaseMessaging.onIosSettingsRegistered
        .listen(( IosNotificationSettings setting ){
      print( "Ios Settings Registered");
    });


    firebaseMessaging.getToken().then((token){
      update(token);
    });


  }

  showNotification(Map<String , dynamic> msg) async{
    var android = new AndroidNotificationDetails(
        "1", "channelName", "channelDescription");
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);

    msg.forEach((k,v){
      print('$k , $v');
      title = k;
      body = v;
      setState(() {

      });
    });

    await flutterLocalNotificationsPlugin.show(0, "mytitle ${body.keys}", "body : ${body.values}", platform);
  }

  update(String token){
    print(token);
    DatabaseReference databaseReference = new FirebaseDatabase().reference();
    databaseReference.child('fcm-token/$token').set({"token": token});
    mytoken = token;
    setState(() {

    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _onCourseAddedSubscription.cancel();
    _onCourseChangedSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Course DB',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Prof Dashboard'),
          centerTitle: true,
          backgroundColor: Colors.green,
        ),
        body:

        Center(
          child: ListView.builder(
              itemCount: items.length,
              padding: EdgeInsets.only(top: 12.0),
              itemBuilder: (context , position){
                return Column(
                  children: <Widget>[
                    Divider(height: 6.0,),
                   /* Container(
                      child: Center(
                        child: '${items[position].courseImage}' == ''
                            ? Text('No Image')
                            : Image.network(
                          '${items[position].courseImage}'+'?alt=media',
                          height: 300.0,
                          width: 400.0,
                        ),
                      ),
                    ),*/
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)
                      ),
                      child:   Row(
                        children: <Widget>[
                          Expanded(child:   ListTile(
                              title: Text(
                                '${items[position].name}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 22.0,
                            ),
                              ),
                              subtitle:  Text(
                                '${items[position].description}',
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 14.0,
                                ),
                              ),
                              leading: Column(
                                children: <Widget>[
                                  CircleAvatar(
                                    backgroundColor: Colors.amberAccent,
                                    radius: 18.0,
                                    child: Text('${position + 1}' ,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15.0,
                                      ),),
                                  ),

                                ],
                              ),
                              onTap:  () => _navigateToCourseInformation(context, items[position] )
                          ),),

                          IconButton(
                              icon: Icon(Icons.delete,color: Colors.red,)
                              , onPressed: () => _deleteCourse(context, items[position],position)
                          ),
                          IconButton(
                              icon: Icon(Icons.edit,color: Colors.blue,)
                              , onPressed: () => _navigateToCourse(context, items[position])
                          )

                        ],
                      ),
                    ),



                  ],

                );

              }
          ),
        ),


        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add,color: Colors.white,),
            backgroundColor: Colors.green,
            onPressed: () => _createNewCourse(context)),

          backgroundColor: Colors.greenAccent,
      ),

    );
  }




  void _onCourseAdded(Event event){
    setState((){
      items.add(new Course.fromSnapShot(event.snapshot));
    });
  }

  void _onCourseUpdated(Event event){
    var oldCourseValue = items.singleWhere((course) => course.id == event.snapshot.key);
    setState((){
      items[items.indexOf(oldCourseValue)] = new Course.fromSnapShot(event.snapshot);
    });
  }

  void _deleteCourse(BuildContext context, Course course,int position)async{
    await courseReference.child(course.id).remove().then((_){
      setState(() {
        items.removeAt(position);
      });
    });
  }

  void _navigateToCourse(BuildContext context,Course course)async{
    await Navigator.push(context,
      MaterialPageRoute(builder: (context) => CourseScreen(course)),
    );

  }


  void _navigateToCourseInformation(BuildContext context,Course course)async{
    await Navigator.push(context,
      MaterialPageRoute(builder: (context) => CourseInformation(course)),
    );

  }


  void _createNewCourse(BuildContext context)async{
    await Navigator.push(context,
      MaterialPageRoute(builder: (context) => CourseScreen(Course(null,'', '', '', '', '',null))),
    );
  }

}
