import 'package:flutter/material.dart';
// import 'package:flutter_text_to_speech_tutorial/consts.dart';
import 'package:flutter_tts/flutter_tts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final key = GlobalKey<FormState>();
  FlutterTts _flutterTts = FlutterTts();
  String spech = "";
  final _textController = TextEditingController();
  List<Map> _voices = [];
  Map? _currentVoice;
  int? _currentWordStart, _currentWordEnd;

  @override
  void initState() {
    super.initState();
    initTTS();
  }

  void initTTS() async {
    //function to audio
    await _flutterTts.setSharedInstance(true);
    await _flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          IosTextToSpeechAudioCategoryOptions.defaultToSpeaker
        ],
        IosTextToSpeechAudioMode.defaultMode);

    _flutterTts.setProgressHandler((text, start, end, word) {
      setState(() {
        _currentWordStart = start;
        _currentWordEnd = end;
      });
    });
    _flutterTts.getVoices.then((data) {
      try {
        List<Map> voices = List<Map>.from(data);
        setState(() {
          _voices =
              voices.where((voice) => voice["name"].contains("en")).toList();
          _currentVoice = _voices.first;
          setVoice(_currentVoice!);
        });
      } catch (e) {
        print(e);
      }
    });
  }

  //set voice for
  void setVoice(Map voice) {
    _flutterTts.setVoice({"name": voice["name"], "locale": voice["locale"]});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: key,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _speakerSelector(),
                TextFormField(
                  controller: _textController,
                  validator: (v) {
                    if (v == null || v == "") {
                      return "Enter required values";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                      hintText: 'Enter text e.g Hi\' how are you ?',
                      labelText: 'Enter text',
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(),
                      errorBorder: OutlineInputBorder()),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  height: MediaQuery.sizeOf(context).height * 0.7,
                  width: double.maxFinite,
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.topLeft,
                  decoration: BoxDecoration(
                      //  color: Colors.amber,
                      border: Border.all(color: Colors.black)),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: _textController.text.isEmpty
                              ? 'Enter text in above field and press floating button in the bottom right corner'
                              : spech.substring(0, _currentWordStart),
                        ),
                        if (_currentWordStart != null)
                          TextSpan(
                            text: spech.substring(
                                _currentWordStart!, _currentWordEnd),
                            style: const TextStyle(
                              color: Colors.white,
                              backgroundColor: Colors.purpleAccent,
                            ),
                          ),
                        if (_currentWordEnd != null)
                          TextSpan(
                            text: spech.substring(_currentWordEnd!),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!key.currentState!.validate()) {
            return;
          }
          _flutterTts.speak(_textController.text);
          setState(() {
            spech = _textController.text;
          });

          // if (_textController.text.isEmpty) {
          //   spech = "";
          // }
        },
        child: const Icon(
          Icons.speaker_phone,
        ),
      ),
    );
  }

  Widget _speakerSelector() {
    return DropdownButton(
      value: _currentVoice,
      items: _voices
          .map(
            (_voice) => DropdownMenuItem(
              value: _voice,
              child: Text(
                _voice["name"],
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          _currentVoice = value;
        });
      },
    );
  }
}
