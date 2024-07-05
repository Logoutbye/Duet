// // ignore_for_file: use_build_context_synchronously

// import 'dart:io';
// import 'package:camera/camera.dart';
// import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
// import 'package:ffmpeg_kit_flutter/return_code.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:gallery_saver/gallery_saver.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:video_player/video_player.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return  MaterialApp(
//       darkTheme: ThemeData.dark(),
//       debugShowCheckedModeBanner: false,
//       home: FirstScreen(),
//     );
//   }
// }

// class FirstScreen extends StatefulWidget {
//   const FirstScreen({super.key});

//   @override
//   State<FirstScreen> createState() => _FirstScreenState();
// }

// class _FirstScreenState extends State<FirstScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Video Player Example'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () async {
//             FilePickerResult? result = await FilePicker.platform.pickFiles(
//               type: FileType.video,
//             );

//             if (result != null) {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => CameraPage(
//                     filePath: result.files.single.path!,
//                   ),
//                 ),
//               );
//             }
//           },
//           child: const Text('Pick Video from Local Storage'),
//         ),
//       ),
//     );
//   }
// }

// class CameraPage extends StatefulWidget {
//   final String filePath;

//   CameraPage({Key? key, required this.filePath}) : super(key: key);

//   @override
//   _CameraPageState createState() => _CameraPageState();
// }

// class _CameraPageState extends State<CameraPage> {
//   bool _isLoading = true;
//   bool _isRecording = false;
//   late CameraController _cameraController;
//   late VideoPlayerController _videoPlayerController;

//   String? isRecordedVideo;

//   @override
//   void initState() {
//     _initCamera();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _cameraController.dispose();
//     _videoPlayerController.dispose();

//     super.dispose();
//   }

//   _initCamera() async {
//     final cameras = await availableCameras();
//     final front = cameras.firstWhere(
//         (camera) => camera.lensDirection == CameraLensDirection.front);
//     _cameraController = CameraController(front, ResolutionPreset.ultraHigh);

//     await _cameraController.initialize();
//     setState(() => _isLoading = false);
//   }

//   _recordVideo() async {
//     if (_isRecording) {
//       final file = await _cameraController.stopVideoRecording();
//       setState(() => _isRecording = false);
//       // final route = MaterialPageRoute(
//       //   fullscreenDialog: true,
//       //   builder: (_) => VideoPage(filePath: file.path),
//       // );
//       // Navigator.push(context, route);
//       isRecordedVideo = file.path;
//     } else {
//       await _cameraController.prepareForVideoRecording();
//       await _cameraController.startVideoRecording();
//       setState(() => _isRecording = true);
//     }
//   }
// void showLoadingDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         content: Row(
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(width: 20),
//             Text("Merging videos..."),
//           ],
//         ),
//       );
//     },
//   );
// }

//   Future<void> mergeVideos(
//       String outputPath, String recordedPath, String pickedPath) async {
//     const filter =
//         "[0:v]scale=480:640,setsar=1[l];[1:v]scale=480:640,setsar=1[r];[l][r]hstack=inputs=2[v]";

//     final command =
//         '-y -i $pickedPath -i $recordedPath -filter_complex "$filter" -map "[v]" $outputPath';
//   showLoadingDialog(context); // Show the loading dialog

//     await FFmpegKit.execute(command).then((session) async {
//       final returnCode = await session.getReturnCode();

//       if (ReturnCode.isSuccess(returnCode)) {
//         await GallerySaver.saveVideo(outputPath);
//         print("Merge successful");
//         const snackBar = SnackBar(
//           content: Text('Yay! Merge successful!'),
//         );
//         Navigator.pop(context);
//         ScaffoldMessenger.of(context).showSnackBar(snackBar);
//       } else {
//         print("Merge failed");
//       }
//     });
//   }

//   Future<String> getOutputPath() async {
//     final directory = await getExternalStorageDirectory();
//     return '${directory!.path}/combined_video.mp4';
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return Scaffold(
//         backgroundColor: Colors.white,
//         body: Container(
//           color: Colors.white,
//           child: const Center(
//             child: CircularProgressIndicator(),
//           ),
//         ),
//       );
//     } else {
//       return Scaffold(
//         backgroundColor: Colors.black,
//         appBar: AppBar(
//           actions: [
//             IconButton(
//                 onPressed: () async {
//                   // final String outputPath =
//                   //     '/storage/emulated/0/Download/combined_video.mp4';
//                   final outputPath = await getOutputPath();

//                   await mergeVideos(
//                       outputPath, isRecordedVideo!, widget.filePath);
//                 },
//                 icon: const Icon(Icons.abc))
//           ],
//         ),
//         body: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Container(
//               height: MediaQuery.of(context).size.height / 1,
//               width: MediaQuery.of(context).size.width / 2,
//               color: Colors.black,
//               child: LocalVideoPlayer(filePath: widget.filePath),
//             ),
//             isRecordedVideo == null
//                 ? Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         CameraPreview(
//                           _cameraController,
//                         ),
//                         FloatingActionButton(
//                           backgroundColor: Colors.red,
//                           child: Icon(_isRecording ? Icons.stop : Icons.circle),
//                           onPressed: () => _recordVideo(),
//                         ),
//                       ],
//                     ),
//                   )
//                 : Expanded(
//                     child: FutureBuilder(
//                       future: _initVideoPlayer(),
//                       builder: (context, state) {
//                         if (state.connectionState == ConnectionState.waiting) {
//                           return const Center(
//                               child: CircularProgressIndicator());
//                         } else {
//                           return Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Center(
//                                 child: AspectRatio(
//                                     aspectRatio: _videoPlayerController
//                                         .value.aspectRatio,
//                                     child: VideoPlayer(
//                                       _videoPlayerController,
//                                     )),
//                               ),
//                               FloatingActionButton(
//                                 onPressed: () {
//                                   setState(() {
//                                     _videoPlayerController.value.isPlaying
//                                         ? _videoPlayerController.pause()
//                                         : _videoPlayerController.play();
//                                   });
//                                 },
//                                 child: Icon(
//                                   _videoPlayerController.value.isPlaying
//                                       ? Icons.pause
//                                       : Icons.play_arrow,
//                                 ),
//                               ),
//                             ],
//                           );
//                         }
//                       },
//                     ),
//                   ),
//           ],
//         ),
//       );
//     }
//   }

//   Future _initVideoPlayer() async {
//     _videoPlayerController = VideoPlayerController.file(File(isRecordedVideo!));
//     await _videoPlayerController.initialize();
//     await _videoPlayerController.setLooping(true);
//     await _videoPlayerController.play();
//   }
// }

// class LocalVideoPlayer extends StatefulWidget {
//   final String filePath;

//   LocalVideoPlayer({required this.filePath});

//   @override
//   _LocalVideoPlayerState createState() => _LocalVideoPlayerState();
// }

// class _LocalVideoPlayerState extends State<LocalVideoPlayer> {
//   late VideoPlayerController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.file(File(widget.filePath))
//       ..addListener(() {
//         setState(() {});
//       })
//       ..setLooping(true)
//       ..initialize().then((_) {
//         setState(() {});
//         _controller.play();
//       });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//        body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Center(
//             child: _controller.value.isInitialized
//                 ? AspectRatio(
//                     aspectRatio: _controller.value.aspectRatio,
//                     child: VideoPlayer(_controller),
//                   )
//                 : const CircularProgressIndicator(),
//           ),
//           FloatingActionButton(
//             onPressed: () {
//               setState(() {
//                 _controller.value.isPlaying
//                     ? _controller.pause()
//                     : _controller.play();
//               });
//             },
//             child: Icon(
//               _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:duet/src/features/duet/create_duet.dart';
import 'package:duet/src/features/duet/merged_video_screen.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';

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
      appBar: AppBar(actions: [IconButton(onPressed: ()async{
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






class DirHelper {
  static Future<String> getAppPath() async {
    String mainPath = await _getMainPath();
    String appPath = "$mainPath/TikTokVideos";
    _createPathIfNotExist(appPath);
    return appPath;
  }

  static Future<String> _getMainPath() async {
    final directory = await getExternalStorageDirectory();
    return directory!.path;
  }

  static void _createPathIfNotExist(String path) {
    Directory(path).createSync(recursive: true);
  }
}
