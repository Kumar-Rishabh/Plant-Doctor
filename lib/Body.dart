import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {

  bool _isloading=false;
  File _image;
  List _outputs;

  LoadModel() async{
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
      numThreads: 1,
    );
  }

  RunModelonImage(File image) async{
    var output=await Tflite.runModelOnImage(
        path: image.path,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 2,
        threshold: 0.2,
        asynch: true
    );
    setState(() {
      _isloading=false;
      _outputs=output;

    });
  }



  @override
  void initState() {
    super.initState();
    _isloading=true;
    LoadModel().then((val) {
      setState(() {
        _isloading = false;
      });
    });
  }



  final ImagePicker _picker = ImagePicker();
  Future getImage() async {
    final pickedFile = await _picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _isloading=true;
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
    RunModelonImage(_image);
  }

  Future getImageCamera() async {
    final pickedFile = await _picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _isloading=true;
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
    RunModelonImage(_image);
  }

  @override
  void dispose() {
    super.dispose();
    Tflite.close();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _isloading ? Container(
            height: 200,
            width: 200,

          ):
          Container(
            margin: EdgeInsets.only(bottom: 20.0,left: 20.0,right: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _image == null ? Container(child:Column(
                  children: [
                    Text("Pick an Image",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 40.0,
                      ),
                    ),
                    Icon(Icons.camera_alt_sharp,size: 50.0,color: Colors.grey,),
                  ],
                ),) : Container(
                    width: 400.0,
                    height: 400.0,
                    child:Image.file(_image)
                ),

                SizedBox(
                  height: 20,
                ),
                _image == null ? Container() : _outputs != null ?
                Text(_outputs[0]["label"],style: TextStyle(color: Colors.black,fontSize: 20),
                ) : Container(child: Text("")),
                SizedBox(
                  height: 20,
                ),

                _image == null ? Container():enableUpload(),

              ],
            ),
          ),
          SizedBox(
            height: 30.0,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                child: Text('CAMERA'),
                style: TextButton.styleFrom(
                  primary: Colors.black,
                  backgroundColor: Colors.green,
                  onSurface: Colors.grey,
                  textStyle: TextStyle(
                    fontSize: 25,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  getImageCamera();
                },
              ),
              TextButton(
                child: Text('GALLERY'),
                style: TextButton.styleFrom(
                  primary: Colors.black,
                  backgroundColor: Colors.green,
                  onSurface: Colors.grey,
                  textStyle: TextStyle(
                    fontSize: 25,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  getImage();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget enableUpload(){
    return Container(
      child: Column(
        children: [
          TextButton(
            child: Text('UPLOAD'),
            style: TextButton.styleFrom(
              primary: Colors.black,
              backgroundColor: Colors.green,
              onSurface: Colors.grey,
              textStyle: TextStyle(
                fontSize: 25,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
                  .ref()
                  .child("myImage");
              firebase_storage.UploadTask uploadTask=ref.putFile(_image);

            },
          ),
        ],

      ),
    );
  }
}
