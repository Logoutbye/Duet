
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';


import 'package:video_player/video_player.dart';

class MergedVideoScreen extends StatefulWidget {
  final String videoPath;

  const MergedVideoScreen({super.key, required this.videoPath});

  @override
  _MergedVideoScreenState createState() => _MergedVideoScreenState();
}

class _MergedVideoScreenState extends State<MergedVideoScreen> {
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
        _videoPlayerController.play();
      });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _videoPlayerController.value.isInitialized
          ? AspectRatio(
              aspectRatio: _videoPlayerController.value.aspectRatio,
              child: VideoPlayer(_videoPlayerController),
            )
          : const CircularProgressIndicator(),
    );
  }
}



class PostTemplate extends StatelessWidget {
  final String username;
  final String videoDescription;
  final String numberOfLikes;
  final String numberOfComments;
  final String numberOfShares;
  final userPost;
  final outputPath;

  PostTemplate({
    required this.username,
    required this.videoDescription,
    required this.numberOfLikes,
    required this.numberOfComments,
    required this.numberOfShares,
    required this.userPost,
    required this.outputPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.arrow_back),
        foregroundColor: Colors.transparent,
        actions: [IconButton(onPressed: ()async{
        await GallerySaver.saveVideo(outputPath);
      }, icon: Icon(Icons.save))],),
      // appBar: PreferredSize(preferredSize: Size.fromHeight(0),
      // child: AppBar()),
      body: Stack(
        children: [
          // user post (at the very back)
          userPost,
          MergedVideoScreen(videoPath: outputPath),
          // user name and caption
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              alignment: Alignment(-1, 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('@' + username,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white)),
                  SizedBox(
                    height: 10,
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: videoDescription,
                            style: TextStyle(color: Colors.white)),
                        TextSpan(
                            text: ' #fyp #flutter',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),

          // buttons
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              alignment: Alignment(1, 1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyButton(
                    icon: Icons.favorite,
                    number: numberOfLikes,
                  ),
                  MyButton(
                    icon: Icons.chat_bubble_outlined,
                    number: numberOfComments,
                  ),
                  MyButton(
                    icon: Icons.send,
                    number: numberOfShares,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class MyPost1 extends StatelessWidget {
  var outputPath;
  MyPost1({super.key, required this.outputPath});

  @override
  Widget build(BuildContext context) {
    return PostTemplate(
      username: 'createdbykoko',
      videoDescription: 'tiktok ui tutorial',
      numberOfLikes: '1.2M',
      numberOfComments: '1232',
      numberOfShares: '122',
      userPost: Container(
        color: Colors.black,
      ),
      outputPath: outputPath,
    );
  }
}

class MyButton extends StatelessWidget {
  final icon;
  final String number;

  MyButton({this.icon, required this.number});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Column(
        children: [
          Icon(
            icon,
            size: 40,
            color: Colors.white,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            number,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

