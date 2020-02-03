import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firetest/model/course.dart';


import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:date_format/date_format.dart';

class CourseScreen extends StatefulWidget{
  final Course course ;
  CourseScreen(this.course);
  @override
  State<StatefulWidget> createState() => new CourseScreenState();

}

final courseReference = FirebaseDatabase.instance.reference().child('course');


class CourseScreenState extends State<CourseScreen>{

 // File image;


  //Development, Design, and Business
  List<String> Departments = ["Development", "Design", "Business"];
  String selectedDept ;
  TextEditingController _nameController;
  TextEditingController _hoursController;
  TextEditingController _numofstudController;
  //TextEditingController _departmentController;
  TextEditingController _descriptionController;


 /* picker()async{
    File img = await ImagePicker.pickImage(source: ImageSource.gallery);
    // File img = await ImagePicker.pickImage(source: ImageSource.camera);
    if(img != null){
      image = img;
      setState(() {

      });
    }
  }*/

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nameController =new TextEditingController(text: widget.course.name);
    _hoursController =new TextEditingController(text: widget.course.hours);
    _numofstudController= new TextEditingController(text: widget.course.numofstud);
   // _departmentController= new TextEditingController(text: widget.course.department);
    _descriptionController =new TextEditingController(text: widget.course.description);
    String department = widget.course.department;
    selectedDept = Departments[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,

      appBar: AppBar(title: Text('Course Details'),backgroundColor: Colors.green,),

      body: Container(
        //margin: EdgeInsets.only(top: 15.0),
        margin: EdgeInsets.all(12.0),
//        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            TextField(
              style: TextStyle(fontSize: 16.0,color: Colors.deepPurpleAccent),
              controller: _nameController,
              decoration: InputDecoration(icon: Icon(Icons.person),labelText: 'Name'),
            ),
//            Padding(padding: EdgeInsets.only(top: 8.0),),

            TextField(
              style: TextStyle(fontSize: 16.0,color: Colors.deepPurpleAccent),
              controller: _hoursController,
              decoration: InputDecoration(icon: Icon(Icons.access_time),labelText: 'Hours'),
            ),
//            Padding(padding: EdgeInsets.only(top: 8.0),),

            TextField(
              style: TextStyle(fontSize: 16.0,color: Colors.deepPurpleAccent),
              controller: _numofstudController,
              decoration: InputDecoration(icon: Icon(Icons.accessibility),labelText: 'No. Student'),
            ),
//            Padding(padding: EdgeInsets.only(top: 8.0),),

            TextField(
              style: TextStyle(fontSize: 16.0,color: Colors.deepPurpleAccent),
              controller: _descriptionController,
              decoration: InputDecoration(icon: Icon(Icons.textsms),labelText: 'Description'),
            ),

           /* TextField(
              style: TextStyle(fontSize: 16.0,color: Colors.deepPurpleAccent),
              controller: _departmentController,
              decoration: InputDecoration(icon: Icon(Icons.desktop_windows),labelText: 'Major'),
            ),*/
           Padding(padding: EdgeInsets.only(top: 20.0),),
            DropdownButton<String>(
              value: selectedDept,
              isExpanded: true,
              icon: Icon(Icons.arrow_downward),
              iconSize: 25,
              elevation: 16,
              style: TextStyle(fontSize: 16.0,color: Colors.grey),
              underline: Container(
                height: 3,
                color: Colors.green,
              ),
              items: Departments.map((department) {
                return DropdownMenuItem<String>(
                  value: department,
                  child: Text(department),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  selectedDept = val;
                });
              },
            ),



//            Padding(padding: EdgeInsets.only(top: 8.0),),

           /* Container(
              child: Center(
                child: image == null ? Text('No Image') : Image.file(image),
              ),
            ),*/
            Padding(padding: EdgeInsets.only(top: 35.0)),

            FlatButton(
              child: (widget.course.id != null) ? Text('Update') :Text('Add'),
              color: Colors.green,
              onPressed: (){

                if(widget.course.id != null){
                  courseReference.child(widget.course.id).set({
                    'name' : _nameController.text,
                    'hours' : _hoursController.text,
                    'numofstud' : _numofstudController.text,
                   // 'department' : _departmentController.text,
                    'department' : selectedDept,
                    'description' : _descriptionController.text
                  }).then((_){
                    Navigator.pop(context);
                  });
                }else {


                  var now = formatDate(new DateTime.now(), [yyyy,'-', mm ,'-',dd]);
                  //var fullImageName =  'images/${_nameController.text}-$now'+'.jpg';
                 // var fullImageName2 =  'images%2F${_nameController.text}-$now'+'.jpg';

                /*  final StorageReference ref = FirebaseStorage.instance.ref()
                      .child(fullImageName);
                  final StorageUploadTask task = ref.putFile(image);
                  var part1 = 'https://firebasestorage.googleapis.com/v0/b/student-b1333.appspot.com/o/';*/

                //  var fullPathImage = part1 +  fullImageName2;
                  courseReference.push().set({
                    'name': _nameController.text,
                    'hours': _hoursController.text,
                    'numofstud': _numofstudController.text,
                    //'department': _departmentController.text,
                    'department': selectedDept,
                    'description': _descriptionController.text,
                    //'courseImage' : '$fullPathImage'
                  }).then((_) {
                    Navigator.pop(context);
                  });
                }

              },
            ),
          ],
        ),
      ),

     /* floatingActionButton: FloatingActionButton(
        onPressed: picker,child: Icon(Icons.camera_alt),
      ),*/


    );
  }

}