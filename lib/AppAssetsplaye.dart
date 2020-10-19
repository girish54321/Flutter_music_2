import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class MyAssersPlayer extends StatefulWidget {
  MyAssersPlayer({Key key}) : super(key: key);

  @override
  _MyAssersPlayerState createState() => _MyAssersPlayerState();
}

class _MyAssersPlayerState extends State<MyAssersPlayer> {
  final BehaviorSubject<double> _dragPositionSubject =
      BehaviorSubject.seeded(null);

  final assetsAudioPlayer = AssetsAudioPlayer();
  final audio = Audio.network(
    "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
    metas: Metas(
      title: "SoundHelix Song",
      artist: "Florent Champigny",
      album: "T. Schürger",
      image: MetasImage.network(
          "https://i.cbc.ca/1.4574015.1520953045!/fileImage/httpImage/daniel-caesar.jpg"),
    ),
  );
  @override
  void initState() {
    super.initState();
    setupPlayer();
  }

  Future<void> setupPlayer() async {
    try {
      await assetsAudioPlayer.open(
        audio,
        showNotification: true,
        playInBackground: PlayInBackground.enabled,
      );
    } catch (t) {
      //mp3 unreachable
    }
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Widget isPlaying() {
    assetsAudioPlayer.current; //ValueObservable<PlayingAudio>

    final Playing playing = assetsAudioPlayer.current.value;
    Duration songDuration;

    assetsAudioPlayer.current.listen((playingAudio) {
      songDuration = playingAudio.audio.duration;
    });
    return StreamBuilder(
        stream: assetsAudioPlayer.currentPosition,
        builder: (context, asyncSnapshot) {
          final Duration duration = asyncSnapshot.data;
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      _printDuration(duration),
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _printDuration(songDuration),
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Slider(
                min: 0.0,
                max: songDuration != null
                    ? songDuration.inMilliseconds.toDouble()
                    : 2.0,
                value:
                    duration != null ? duration.inMilliseconds.toDouble() : 1.0,
                onChanged: (value) {
                  // _dragPositionSubject.add(value);
                },
                onChangeEnd: (value) {
                  assetsAudioPlayer.seek(Duration(milliseconds: value.toInt()));
                },
                activeColor: Colors.red,
                inactiveColor: Colors.grey.shade300,
              ),
              SizedBox(
                height: 40,
              ),
            ],
          );
        });
  }

  Widget coverArt() {
    return StreamBuilder(
        stream: assetsAudioPlayer.current,
        builder: (context, asyncSnapshot) {
          print(asyncSnapshot.data);
          final Playing playing = asyncSnapshot.data;
          print("I need Image");
          final MetasImage coverImage = playing.audio.audio.metas.image;
          print(coverImage);
          return Column(
            children: <Widget>[
              Center(
                child: Container(
                  height: 260,
                  width: 260,
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(200)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(200),
                    child: Image.network(
                      coverImage.path,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              singerName(playing),
            ],
          );
        });
  }

  Widget singerName(Playing playing) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 30,
        ),
        Center(
          child: Text(
            playing.audio.audio.metas.title,
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Center(
          child: Text(
            playing.audio.audio.metas.artist,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 50, bottom: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                Text(
                  "Playing Now",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 12,
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 24),
                      child: Icon(
                        Icons.favorite,
                        color: Colors.pinkAccent,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 19,
                  ),
                  StreamBuilder(
                      stream: assetsAudioPlayer.isPlaying,
                      builder: (context, asyncSnapshot) {
                        final bool playing = asyncSnapshot.data;
                        return playing
                            ? Column(
                                children: <Widget>[
                                  coverArt(),
                                  isPlaying(),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 30, right: 30),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Icon(
                                          Icons.repeat,
                                          size: 36,
                                        ),
                                        Icon(
                                          Icons.skip_previous,
                                          size: 36,
                                        ),
                                        Container(
                                          height: 60,
                                          width: 60,
                                          child: FloatingActionButton(
                                            onPressed: () {
                                              assetsAudioPlayer.pause();
                                            },
                                            backgroundColor: Colors.deepPurple,
                                            child: Icon(
                                              playing
                                                  ? Icons.pause
                                                  : Icons.play_arrow,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.skip_next,
                                          size: 36,
                                        ),
                                        Icon(
                                          Icons.shuffle,
                                          size: 36,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Center(
                                child: Container(
                                  height: 60,
                                  width: 60,
                                  child: FloatingActionButton(
                                    onPressed: () {
                                      assetsAudioPlayer.play();
                                    },
                                    backgroundColor: Colors.deepPurple,
                                    child: Icon(
                                      playing ? Icons.pause : Icons.play_arrow,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              );
                      }),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
