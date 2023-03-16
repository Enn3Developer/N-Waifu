import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:http/http.dart' as http;

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
  TextEditingController text = TextEditingController();
  TextEditingController textJa = TextEditingController();
  GoogleTranslator translator = GoogleTranslator();
  AudioPlayer player = AudioPlayer();
  Future<String> voiceData = Future(() => "");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView(
          children: [
            TextField(
              controller: text,
            ),
            TextField(
              controller: textJa,
            ),
            ElevatedButton(
              child: const Text("Play"),
              onPressed: () async {
                String translated;
                if (textJa.value.text.isEmpty) {
                  translated = (await translator.translate(text.value.text, to: "ja")).text;
                } else {
                  translated = textJa.value.text;
                }
                if (kDebugMode) {
                  print(translated);
                }
                var data = await http.post(Uri.parse("http://129.152.30.223:5123/audio_query?speaker=2&text=${Uri.encodeFull(translated)}"));
                if (data.statusCode == 200) {
                  var audio = await http.post(Uri.parse("http://129.152.30.223:5123/synthesis?speaker=2"), headers: <String, String>{
                    'Content-Type': 'application/json',
                  }, body: data.body);
                  if (audio.statusCode == 200) {
                    player.play(BytesSource(audio.bodyBytes));
                  } else {
                    text.text = "ERR No Audio Connection";
                  }
                } else {
                  text.text = "ERR No Connection";
                  if (kDebugMode) {
                    print(data.body);
                  }
                }
              },
            )
          ],
        ),
      )
    );
  }
}
