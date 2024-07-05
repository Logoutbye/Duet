// import 'package:duet/src/features/duet/pick_video.dart';
// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       darkTheme: ThemeData.dark(),
//       debugShowCheckedModeBanner: false,
//       home: const PickVideoScreen(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc_observer.dart';
import 'src/container_injector.dart';
import 'src/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initApp();
  Bloc.observer = MyBlocObserver();
  runApp(const MyApp());
}

// import 'dart:convert';
// import 'dart:io';

// import 'package:duet/src/config/routes_manager.dart';
// import 'package:duet/src/core/helpers/dir_helper.dart';
// import 'package:duet/src/core/helpers/permissions_helper.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';

// import 'src/features/tiktok_downloader/presentation/screens/downloads_screen.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: Text('Instagram Video Downloader')),
//         body: VideoDownloader(),
//       ),
//     );
//   }
// }

// class VideoDownloader extends StatefulWidget {
//   @override
//   _VideoDownloaderState createState() => _VideoDownloaderState();
// }

// class _VideoDownloaderState extends State<VideoDownloader> {
//   String _status = "Enter the Instagram video link to download";
//   TextEditingController _controller = TextEditingController();
//   bool _downloading = false;
//   String _downloadStatus = '';
//   String _videoUrl = '';
//   String _thumbnailUrl = '';

//   Future<void> _downloadInstagramVideo(String videoUrl) async {
//     final url = Uri.parse(
//         'https://instagram-downloader-download-instagram-videos-stories1.p.rapidapi.com/?url=${Uri.encodeComponent(videoUrl)}');
//     final headers = {
//       'x-rapidapi-key': '652fc95660msh4825c876ba3276bp12a6b1jsnd1d5785bdd60',
//       'x-rapidapi-host':
//           'instagram-downloader-download-instagram-videos-stories1.p.rapidapi.com',
//     };

//     setState(() {
//       _downloading = true;
//       _downloadStatus = 'Downloading video...';
//     });

//     try {
//       PermissionsHelper.checkPermission();
//       final response = await http.get(url, headers: headers);
//       print('::: ${response.body}');
//       print('::: ${response.statusCode}');
//       if (response.statusCode == 200) {
//         final responseData = json.decode(response.body);
//         if (responseData is List && responseData.isNotEmpty) {
//           final videoData = responseData[0];
//           setState(() {
//             _videoUrl = videoData['url'];
//             _thumbnailUrl = videoData['thumb'];
//             _downloadStatus = 'Video downloaded successfully';
//           });

//           // Optionally, save the video file to local storage
//           await _downloadFile(videoData['url'], 'video.mp4');

//           // Show video details bottom sheet
//           _showVideoDetailsBottomSheet();
//         } else {
//           setState(() {
//             _downloadStatus = 'Failed to get video URL from response';
//           });
//         }
//       } else {
//         setState(() {
//           _downloadStatus = 'Failed to download video: ${response.statusCode}';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _downloadStatus = 'Error downloading video: $e';
//       });
//     } finally {
//       setState(() {
//         _downloading = false;
//       });
//     }
//   }

//   Future<String> _getPathById(String id) async {
//     final appPath = await DirHelper.getAppPath();
//     return "$appPath/$id.mp4";
//   }

//   Future<void> _downloadFile(String url, String filename) async {
//     final response = await http.get(Uri.parse(url));
//     print(':::_downloadFile ${response.body}');
//     print('::: _downloadFile${response.statusCode}');
//     if (response.statusCode == 200) {
//       // final directory = await getExternalStorageDirectory();
//       // final filePath = '${directory?.path}/$filename';
//       final filePath = await _getPathById(filename);
//       final file = File(filePath);
//       await file.writeAsBytes(response.bodyBytes);
//       print('Video saved to $filePath');
//     } else {
//       print('Failed to download file');
//     }
//   }

//   void _showVideoDetailsBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return Container(
//           padding: EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               Text(
//                 'Video Details',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 10),
//               if (_thumbnailUrl.isNotEmpty)
//                 Image.network(
//                   _thumbnailUrl,
//                   height: 150,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                 ),
//               // SizedBox(height: 10),
//               // Text('Video URL: $_videoUrl'),
//               SizedBox(height: 10),
//               _downloading
//                   ? CircularProgressIndicator()
//                   : ElevatedButton(
//                       onPressed: () {
//                         // Perform download action if needed
//                       MaterialPageRoute(
//           builder: (context) => const DownloadsScreen(),
//         );
//                       },
//                       child: Text('See'),
//                     ),
//               SizedBox(height: 10),
//               Text(
//                 _downloadStatus,
//                 style: TextStyle(color: Colors.red),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           Text(_status),
//           SizedBox(height: 20),
//           TextField(
//             controller: _controller,
//             decoration: InputDecoration(
//               border: OutlineInputBorder(),
//               labelText: 'Instagram Video URL',
//             ),
//           ),
//           SizedBox(height: 20),
//           _downloading
//               ? CircularProgressIndicator()
//               : ElevatedButton(
//                   onPressed: () {
//                     final videoUrl = _controller.text;
//                     if (videoUrl.isNotEmpty) {
//                       _downloadInstagramVideo(videoUrl);
//                     } else {
//                       setState(() {
//                         _status = "Please enter a valid URL";
//                       });
//                     }
//                   },
//                   child: Text('Download Video'),
//                 ),
//         ],
//       ),
//     );
//   }
// }
