import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kittybuddyflutter/phrases.dart';


var hoomans = 0;
var hoomansv2 = 0;
var globalWidth = 300.0;
var globalHeight = 300.0;
var mouth = 5.0;


class Hooman {
  final String eventtype;
  final String hooman_id;
  final String hooman_name;
  final String hooman_likes;

  Hooman(this.eventtype, this.hooman_id, this.hooman_name, this.hooman_likes) {

  }

  Hooman.fromJson(Map<String, dynamic> json)
      : eventtype = json['eventtype'],
  hooman_name = json['hooman_name'],
        hooman_likes = json['hooman_likes'],
        hooman_id = json['hooman_id'];

  Map<String, dynamic> toJson() => {
    'eventtype': eventtype,
    'hooman_id': hooman_id,
    'hooman_name': hooman_name,
    'hooman_likes': hooman_likes,
  };
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key}){

  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MeatSpace',
      theme: ThemeData(
        fontFamily: 'Robot',
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String defaultLanguage = 'en-GB';
  final _random = Random();
  String text = '';
  double volume = .5; // Range: 0-1
  double rate = .9; // Range: 0-2
  double pitch = .8; // Range: 0-2
  String? language;
  String? languageCode;
  List<String> languages = <String>[];
  List<String> languageCodes = <String>[];
  String? voice;
  TextEditingController textEditingController = TextEditingController(text: "i am a cat");

  @override
  void initState() {
    super.initState();
    textEditingController.text = text;
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initLanguages();
      startListener();
    });
  }

  Future<void> initLanguages() async {
  }

  Future<String?> getVoiceByLang(String lang) async {
  }

  startListener() async {
    while(true){
      var url = Uri.http('localhost:8080', 'events');
      try {
        var response = await http.read(url);
        if(response.isNotEmpty) {
          // python, bah
          response = response.replaceFirst("b'", "").replaceFirst("'", "");
          print('Response status: ${response}');

          Map<String, dynamic> user = jsonDecode(response);
          var hooman = Hooman.fromJson(user);
          // {"eventtype":"hooman","hooman_id":"", "hooman_name":"", "hooman_likes":""}
          if(hooman.eventtype == "hooman"){
            setState(() {
              hoomans = hoomans + 1;
              text = phrases[_random.nextInt(phrases.length)];
            });
            sayThis(text);
          }
          if(hooman.eventtype == "tap"){
            setState(() {
              text = greet[_random.nextInt(greet.length)] + " Hooman ${hooman.hooman_name}." + vip[_random.nextInt(vip.length)];
            });
            sayThis(text);
          }
        }
      } catch(e){
        print(e);
      }
      print('listener zzz');
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black38,

        appBar: AppBar(
          title: const Text('Kitsune Meat World Extension 2023.1'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(

              child: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Image.asset('assets/kitsune.png', height: 600),
                      CustomPaint(
                        painter: OpenPainter(),
                      ),
                      Column(children: [
                        Text("Hoomans : ${hoomans}"),
                        Text("Carriers: ${hoomansv2}"),
                        Text("X       : ${globalWidth}"),
                        Text("Y       : ${globalHeight}"),
                      ],)
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[

                      SizedBox(
                        width: MediaQuery.of(context).size.width * .9,
                        child: AutoSizeText(
                          text,
                          style: TextStyle(fontSize: 30),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(right: 10),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.grey,
                                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                                textStyle: const TextStyle(
                                    fontSize: 30,
                                    fontFamily: 'Robot',
                                    fontWeight: FontWeight.bold)),
                            child: const Text(''),
                            onPressed: () {
                              setState(() {
                                hoomans = hoomans + 1;
                                text = phrases[_random.nextInt(phrases.length)];
                              });

                              sayThis(text);
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );

  }

  bool get supportPause => defaultTargetPlatform != TargetPlatform.android;
  bool get supportResume => defaultTargetPlatform != TargetPlatform.android;

  void speak() async {
  }

  Future<void> sayThis(String thisString ) async {
    var speak = Uri.http('localhost:8080', 'say');

    print("start animation");
    Future.delayed(const Duration(milliseconds: 2400), () {
      animate(thisString);

    });
    var x = await http.post(speak, body: thisString);
    print(x);
    print("stop animation");
  }

  void animate(String thisString) async {
    var seconds = 50;
    var x = 0;
    Timer _timer;
    int _start = 50;
    const oneSec = const Duration(milliseconds: 100);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            mouth = 5.00;
          });
        } else {
          _start = _start - 1;
          setState(() {
            mouth = (sin(DateTime
                .now()
                .millisecondsSinceEpoch)).abs() * 20.0;
          });
        }
      },
    );
  }
}

class OpenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    globalWidth = window.physicalSize.width as double;
    globalHeight = window.physicalSize.height as double;
    var paint1 = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    Rect myRect = Offset(globalWidth/4.6, globalHeight/3.60) & Size(20.0, mouth);
    canvas.drawOval(myRect, paint1);
//    canvas.drawCircle(Offset(400, 200), 50, paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}