import 'dart:async';
import 'dart:convert' show jsonDecode, utf8;
//import 'dart:ffi';
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
  int strength = 0;
  double temperature = 0.0;
  double distance = 0.0;
  String text = 'booting...';
  double volume = .5; // Range: 0-1
  double rate = .9; // Range: 0-2
  double pitch = .8; // Range: 0-2
  String? language;
  String? languageCode;
  List<String> languages = <String>[];
  List<String> languageCodes = <String>[];
  String? voice;
  Map<String,double> playTime = <String,double>{};
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
        setState(() {
          text = "frazoj por hooman konverti";
        });
        var l = phrases.length;
        for(var i = 0; i < l; i++){
          setState(() {
            text = "frazoj por hooman konverti $i / $l";
          });
          print("kaŝmemoro " + phrases[i]);
          var speak = Uri.http('localhost:8080', 'cache');
          var x = await http.post(speak, body: phrases[i]);
          if(x.statusCode != 200){
            print("invalid return");
            continue;
          }
          var content = x.body;
          playTime[phrases[i]] = double.parse(content);
    }
        setState(() {
          text = "kaŝmemoro kompleta";
        });

  }

  Future<String?> getVoiceByLang(String lang) async {
  }

  startListener() async {
    while(true){
      var url = Uri.http('localhost:8080', 'events');
      try {
        var qqq = await http.get(url);
//        var response = await http.read(url);
        if(qqq.statusCode == 200 && qqq.body.isNotEmpty) {
          // python, bah

          print(qqq.headers);
          if(qqq.headers['x-strength'] != null){
            print(qqq.headers['x-strength']);
            strength = int.parse(qqq.headers['x-strength']!);
          }
          if(qqq.headers['x-temperature'] != null){
            print(qqq.headers['x-temperature']);
            temperature = double.parse(qqq.headers['x-temperature']!);
          }
          if(qqq.headers['x-distance'] != null){
            print(qqq.headers['x-distance']);
            distance = double.parse(qqq.headers['x-distance']!);
          }
          Map<String, dynamic> user = jsonDecode(qqq.body.replaceFirst("b'", "").replaceFirst("'", ""));
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
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Kitsune Viandmonda Etendo 2023.1'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(

              child: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Image.asset('assets/kitsune.png', height: 500),
                      CustomPaint(
                        painter: OpenPainter(),
                      ),
                      Column(children: [
                        Text("hoomanoj/${hoomans}", style: TextStyle(fontFamily: "vt"),),
                        Text("bufrigita/${hoomansv2}", style: TextStyle(fontFamily: "vt"),),
                        Text("X/${globalWidth}", style: TextStyle(fontFamily: "vt"),),
                        Text("Y/${globalHeight}", style: TextStyle(fontFamily: "vt"),),
                        Text("distanco/${distance}", style: TextStyle(fontFamily: "vt"),),
                        Text("amplitudo/${strength}", style: TextStyle(fontFamily: "vt"),),
                        Text("temperaturo/${temperature} c", style: TextStyle(fontFamily: "vt"),),
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
                          style: TextStyle(fontSize: 30, color: Colors.green, fontFamily: "vt"),
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
                                primary: Colors.black87,
                                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                                textStyle: const TextStyle(
                                    fontSize: 30,
                                    fontFamily: 'vt',
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
    var animateTime = 2.0;
    if(playTime.containsKey(thisString)){
      animateTime = playTime[thisString]!;
    }
    print("start animation");
      animate(animateTime);
    var x = await http.post(speak, body: thisString);
    print(x);
    print("stop animation");
  }

  void animate(double speak) async {
//    Timer _timer;
    int _start = (speak * 10).toInt();
    const oneSec = const Duration(milliseconds: 100);
    Timer _timer = new Timer.periodic(
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
    Rect myRect = Offset(globalWidth/5.2, globalHeight/4.30) & Size(20.0, mouth);
    canvas.drawOval(myRect, paint1);
//    canvas.drawCircle(Offset(400, 200), 50, paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}