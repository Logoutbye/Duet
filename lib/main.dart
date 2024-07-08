// // import 'package:duet/src/features/duet/pick_video.dart';
// // import 'package:flutter/material.dart';

// // void main() {
// //   runApp(const MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       darkTheme: ThemeData.dark(),
// //       debugShowCheckedModeBanner: false,
// //       home: const PickVideoScreen(),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import 'bloc_observer.dart';
// import 'src/container_injector.dart';
// import 'src/my_app.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   initApp();
//   Bloc.observer = MyBlocObserver();
//   runApp(const MyApp());
// }

// // import 'dart:convert';
// // import 'dart:io';

// // import 'package:duet/src/config/routes_manager.dart';
// // import 'package:duet/src/core/helpers/dir_helper.dart';
// // import 'package:duet/src/core/helpers/permissions_helper.dart';
// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:path_provider/path_provider.dart';

// // import 'src/features/tiktok_downloader/presentation/screens/downloads_screen.dart';

// // void main() {
// //   runApp(MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       home: Scaffold(
// //         appBar: AppBar(title: Text('Instagram Video Downloader')),
// //         body: VideoDownloader(),
// //       ),
// //     );
// //   }
// // }

// // class VideoDownloader extends StatefulWidget {
// //   @override
// //   _VideoDownloaderState createState() => _VideoDownloaderState();
// // }

// // class _VideoDownloaderState extends State<VideoDownloader> {
// //   String _status = "Enter the Instagram video link to download";
// //   TextEditingController _controller = TextEditingController();
// //   bool _downloading = false;
// //   String _downloadStatus = '';
// //   String _videoUrl = '';
// //   String _thumbnailUrl = '';

// //   Future<void> _downloadInstagramVideo(String videoUrl) async {
// //     final url = Uri.parse(
// //         'https://instagram-downloader-download-instagram-videos-stories1.p.rapidapi.com/?url=${Uri.encodeComponent(videoUrl)}');
// //     final headers = {
// //       'x-rapidapi-key': '652fc95660msh4825c876ba3276bp12a6b1jsnd1d5785bdd60',
// //       'x-rapidapi-host':
// //           'instagram-downloader-download-instagram-videos-stories1.p.rapidapi.com',
// //     };

// //     setState(() {
// //       _downloading = true;
// //       _downloadStatus = 'Downloading video...';
// //     });

// //     try {
// //       PermissionsHelper.checkPermission();
// //       final response = await http.get(url, headers: headers);
// //       print('::: ${response.body}');
// //       print('::: ${response.statusCode}');
// //       if (response.statusCode == 200) {
// //         final responseData = json.decode(response.body);
// //         if (responseData is List && responseData.isNotEmpty) {
// //           final videoData = responseData[0];
// //           setState(() {
// //             _videoUrl = videoData['url'];
// //             _thumbnailUrl = videoData['thumb'];
// //             _downloadStatus = 'Video downloaded successfully';
// //           });

// //           // Optionally, save the video file to local storage
// //           await _downloadFile(videoData['url'], 'video.mp4');

// //           // Show video details bottom sheet
// //           _showVideoDetailsBottomSheet();
// //         } else {
// //           setState(() {
// //             _downloadStatus = 'Failed to get video URL from response';
// //           });
// //         }
// //       } else {
// //         setState(() {
// //           _downloadStatus = 'Failed to download video: ${response.statusCode}';
// //         });
// //       }
// //     } catch (e) {
// //       setState(() {
// //         _downloadStatus = 'Error downloading video: $e';
// //       });
// //     } finally {
// //       setState(() {
// //         _downloading = false;
// //       });
// //     }
// //   }

// //   Future<String> _getPathById(String id) async {
// //     final appPath = await DirHelper.getAppPath();
// //     return "$appPath/$id.mp4";
// //   }

// //   Future<void> _downloadFile(String url, String filename) async {
// //     final response = await http.get(Uri.parse(url));
// //     print(':::_downloadFile ${response.body}');
// //     print('::: _downloadFile${response.statusCode}');
// //     if (response.statusCode == 200) {
// //       // final directory = await getExternalStorageDirectory();
// //       // final filePath = '${directory?.path}/$filename';
// //       final filePath = await _getPathById(filename);
// //       final file = File(filePath);
// //       await file.writeAsBytes(response.bodyBytes);
// //       print('Video saved to $filePath');
// //     } else {
// //       print('Failed to download file');
// //     }
// //   }

// //   void _showVideoDetailsBottomSheet() {
// //     showModalBottomSheet(
// //       context: context,
// //       builder: (BuildContext context) {
// //         return Container(
// //           padding: EdgeInsets.all(16.0),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             mainAxisSize: MainAxisSize.min,
// //             children: <Widget>[
// //               Text(
// //                 'Video Details',
// //                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
// //               ),
// //               SizedBox(height: 10),
// //               if (_thumbnailUrl.isNotEmpty)
// //                 Image.network(
// //                   _thumbnailUrl,
// //                   height: 150,
// //                   width: double.infinity,
// //                   fit: BoxFit.cover,
// //                 ),
// //               // SizedBox(height: 10),
// //               // Text('Video URL: $_videoUrl'),
// //               SizedBox(height: 10),
// //               _downloading
// //                   ? CircularProgressIndicator()
// //                   : ElevatedButton(
// //                       onPressed: () {
// //                         // Perform download action if needed
// //                       MaterialPageRoute(
// //           builder: (context) => const DownloadsScreen(),
// //         );
// //                       },
// //                       child: Text('See'),
// //                     ),
// //               SizedBox(height: 10),
// //               Text(
// //                 _downloadStatus,
// //                 style: TextStyle(color: Colors.red),
// //               ),
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Padding(
// //       padding: const EdgeInsets.all(16.0),
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: <Widget>[
// //           Text(_status),
// //           SizedBox(height: 20),
// //           TextField(
// //             controller: _controller,
// //             decoration: InputDecoration(
// //               border: OutlineInputBorder(),
// //               labelText: 'Instagram Video URL',
// //             ),
// //           ),
// //           SizedBox(height: 20),
// //           _downloading
// //               ? CircularProgressIndicator()
// //               : ElevatedButton(
// //                   onPressed: () {
// //                     final videoUrl = _controller.text;
// //                     if (videoUrl.isNotEmpty) {
// //                       _downloadInstagramVideo(videoUrl);
// //                     } else {
// //                       setState(() {
// //                         _status = "Please enter a valid URL";
// //                       });
// //                     }
// //                   },
// //                   child: Text('Download Video'),
// //                 ),
// //         ],
// //       ),
// //     );
// //   }
// // }




import 'dart:async';
import 'dart:io';


import 'package:duet/page_arcloud.dart';
import 'package:duet/page_camera.dart';
import 'package:duet/page_image.dart';
import 'package:duet/page_touchup.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

const banubaToken = "Qk5CIPgcrV+G/OnXaR6L4EOqDdtvOE50pEwyM9pC5ImYD3uhJkIWuRk7XnRuzD4GF3ph7B2iq28mMPeXkEfqonPd+kehHL0Gm5C/ttMcK0HhjeT01+2t+R4wOTVUxy8ehTN/M1kF6yRIhzoMIZxl3asu3C52QYrNHYX8l+9FHQnpK98wI3B3izPWUOTWAf2+y8njm6ZZgs/yNRJHpBNJktwgpntFCR9m+Jcq8tjNcewMQhdqfwsRSs98A7qwgaCaY4peQ2RmaUcnbtB2+Fh5rmWPWalvSfk1kND7M6RBwkyLgBKvbDDl0JyEoFynTz2omMf5b4yaNpLPcZNjtxsM46OcAAnec2HKH25U86Kt84d6XgMf9bClKVf1jsOcTxPxXlzy3rIqwHqKXfpG+tCtVQ+XBaSu8GcudWW7owTemDPhyHa0c7U9vTgroKeH3hDAmWj4JIDCo/IzCuzoKjFOGhmxw00vY7uZf2vGqrcNnV2kZwadu9MCFaCKuI4a3332LNoyY6CdutxQKbO+aQ+7VhVHZY79c/fCOhqLOxEWR0n100QpYFyINyNQzHDCN3Zj+5wdMlmf6V2BR3joj2hGeIcOFp849ru4ay5N+1UYFNaH1DLCaQXPH/ulhuHZH/+auCZQFjw0lrYj7+3D+NjlOw==";

enum EntryPage { camera, image, touchUp, arCloud }

void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      shape: const StadiumBorder(),
      fixedSize: Size(MediaQuery.of(context).size.width / 2.0, 50),
    );
    Text textWidget(String text) {
      return Text(
        text.toUpperCase(),
        style: const TextStyle(fontSize: 13.0),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Face AR Flutter Sample'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            style: buttonStyle,
            onPressed: () => _navigateToPage(EntryPage.camera),
            child: textWidget('Open Camera'),
          ),
          SizedBox.fromSize(size: const Size.fromHeight(20.0)),
          ElevatedButton(
            style: buttonStyle,
            onPressed: () => _navigateToPage(EntryPage.image),
            child: textWidget('Image processing'),
          ),
          SizedBox.fromSize(size: const Size.fromHeight(20.0)),
          ElevatedButton(
            style: buttonStyle,
            onPressed: () => _navigateToPage(EntryPage.touchUp),
            child: textWidget('Touch Up features'),
          ),
          SizedBox.fromSize(size: const Size.fromHeight(20.0)),
          ElevatedButton(
            style: buttonStyle,
            onPressed: () => _navigateToPage(EntryPage.arCloud),
            child: textWidget('Load from AR Cloud'),
          ),
        ],
      ),
    );
  }

  void _navigateToPage(EntryPage entryPage) {
    switch (entryPage) {
      case EntryPage.camera:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CameraPage()),
        );
        return;

      case EntryPage.image:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ImagePage()),
        );
        return;

      case EntryPage.touchUp:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TouchUpPage()),
        );
        return;

      case EntryPage.arCloud:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ARCloudPage()),
        );
        return;
    }
  }
}

Future<String> generateFilePath(String prefix, String fileExt) async {
  final directory = await getTemporaryDirectory();
  final filename = '$prefix${DateTime.now().millisecondsSinceEpoch}$fileExt';
  return '${directory.path}${Platform.pathSeparator}$filename';
}

// This is a sample implementation of requesting permissions.
// It is expected that the user grants all permissions. This solution does not handle the case
// when the user denies access or navigating the user to Settings for granting access.
// Please implement better permissions handling in your project.
Future<bool> requestPermissions() async {
  final requiredPermissions = _getPlatformPermissions();
  for (var permission in requiredPermissions) {
    var ps = await permission.status;
    if (!ps.isGranted) {
      ps = await permission.request();
      if (!ps.isGranted) {
        return false;
      }
    }
  }
  return true;
}

List<Permission> _getPlatformPermissions() {
  return [Permission.camera, Permission.microphone];
}

void showToastMessage(String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      textColor: Colors.white,
      fontSize: 14.0);
}
