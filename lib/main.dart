import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kittybuddyflutter/phrases.dart';
import 'package:text_to_speech/text_to_speech.dart';

var globalWidth = 300.0;
var globalHeight = 300.0;
var mouth = 5.0;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
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
  TextToSpeech tts = TextToSpeech();
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
    });
  }

  Future<void> initLanguages() async {
    languageCodes = await tts.getLanguages();
    final List<String>? displayLanguages = await tts.getDisplayLanguages();
    if (displayLanguages == null) {
      return;
    }

    languages.clear();
    for (final dynamic lang in displayLanguages) {
      languages.add(lang as String);
    }

    final String? defaultLangCode = await tts.getDefaultLanguage();
    if (defaultLangCode != null && languageCodes.contains(defaultLangCode)) {
      languageCode = defaultLangCode;
    } else {
      languageCode = defaultLanguage;
    }
    language = await tts.getDisplayLanguageByCode(languageCode!);

    /// get voice
    voice = await getVoiceByLang(languageCode!);

    if (mounted) {
      setState(() {});
    }
  }

  Future<String?> getVoiceByLang(String lang) async {
    final List<String>? voices = await tts.getVoiceByLang(languageCode!);

    if (voices != null && voices.isNotEmpty) {
      if( voices.contains('en-GB') ){
          return 'en-GB';
      }
      return voices.first;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
                      Image.asset('assets/kitsune.png'),
                      CustomPaint(
                        painter: OpenPainter(),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                  Row(
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
                            child: const Text('Say Something'),
                            onPressed: () {
                              setState(() {
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

  void speak() {
    tts.setVolume(volume);
    tts.setRate(rate);
    if (languageCode != null) {
      tts.setLanguage(languageCode!);
    }
    tts.setPitch(pitch);
    tts.speak(text);
  }
  void sayThis(String thisString ) {
    print("start animation");
    tts.setVolume(volume);
    tts.setRate(rate);
    if (languageCode != null) {
      tts.setLanguage(languageCode!);
    }
    tts.setPitch(pitch);
    animate(thisString);
    tts.speak(thisString);
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
    Rect myRect = Offset(globalWidth/2.9, globalHeight/4.27) & Size(20.0, mouth);
    canvas.drawOval(myRect, paint1);
//    canvas.drawCircle(Offset(400, 200), 50, paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}