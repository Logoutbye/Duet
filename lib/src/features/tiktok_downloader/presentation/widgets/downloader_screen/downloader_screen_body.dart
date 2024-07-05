// import 'dart:convert';
// import 'dart:io';

// import 'package:duet/src/core/helpers/dir_helper.dart';
// import 'package:duet/src/core/helpers/permissions_helper.dart';
// import 'package:duet/src/features/tiktok_downloader/presentation/screens/downloads_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../../../../../config/routes_manager.dart';
// import '../../../../../core/utils/app_enums.dart';
// import '../../../../../core/utils/app_strings.dart';
// import '../../../../../core/widgets/build_toast.dart';
// import '../../../../../core/widgets/center_indicator.dart';
// import '../../../../../core/widgets/custom_elevated_btn.dart';
// import '../../bloc/downloader_bloc/downloader_bloc.dart';
// import '../download_bottom_sheet.dart';
// import 'downloader_body_input_field.dart';
// import 'package:http/http.dart' as http;

// class DownloaderScreenBody extends StatefulWidget {
//   const DownloaderScreenBody({Key? key}) : super(key: key);

//   @override
//   State<DownloaderScreenBody> createState() => _DownloaderScreenBodyState();
// }

// class _DownloaderScreenBodyState extends State<DownloaderScreenBody> {
//   TextEditingController _tiktokVideoLinkController = TextEditingController();
//   TextEditingController _instaVideoLinkController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();

//   @override
//   void dispose() {
//     _tiktokVideoLinkController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<DownloaderBloc, DownloaderState>(
//       listener: (context, state) {
//         if (state is DownloaderSaveVideoLoading) {
//           Navigator.of(context).popAndPushNamed(Routes.downloads);
//         }
//         if (state is DownloaderGetVideoFailure) {
//           buildToast(msg: state.message, type: ToastType.error);
//         }
//         if (state is DownloaderGetVideoSuccess &&
//             state.tikTokVideo.videoData == null) {
//           buildToast(msg: state.tikTokVideo.msg, type: ToastType.error);
//         }
//         if (state is DownloaderGetVideoSuccess &&
//             state.tikTokVideo.videoData != null) {
//           buildDownloadBottomSheet(context, state.tikTokVideo);
//         }
//         if (state is DownloaderSaveVideoSuccess) {
//           // DirHelper.saveVideoToGallery(state.path);
//           // DirHelper.removeFileFromDownloadsDir(state.path);
//           buildToast(msg: state.message, type: ToastType.success);
//         }
//         if (state is DownloaderSaveVideoFailure) {
//           buildToast(msg: state.message, type: ToastType.error);
//         }
//       },
//       builder: (context, state) {
//         return Container(
//           padding: const EdgeInsets.all(20),
//           alignment: AlignmentDirectional.center,
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // const DownloaderBodyLogo(),
//                 const SizedBox(height: 40),
//                 DownloaderBodyInputField(
//                   videoLinkController: _tiktokVideoLinkController,
//                   formKey: _formKey,
//                 ),
//                 const SizedBox(height: 20),
//                 state is DownloaderGetVideoLoading
//                     ? const CenterProgressIndicator()
//                     : _buildBodyDownloadBtnTiktok(context),
//                 Divider(),
//                 Text(_status),
//                 SizedBox(height: 20),
//                 TextField(
//                   controller: _controller,
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(),
//                     labelText: 'Instagram Video URL',
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 _downloading
//                     ? CircularProgressIndicator()
//                     : ElevatedButton(
//                         onPressed: () {
//                           final videoUrl = _controller.text;
//                           if (videoUrl.isNotEmpty) {
//                             _downloadInstagramVideo(videoUrl);
//                           } else {
//                             setState(() {
//                               _status = "Please enter a valid URL";
//                             });
//                           }
//                         },
//                         child: Text('Download Video'),
//                       ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildBodyDownloadBtnTiktok(BuildContext context) {
//     return CustomElevatedBtn(
//       label: AppStrings.tiktok,
//       onPressed: () {
//         // if (_formKey.currentState!.validate()) {
//         context.read<DownloaderBloc>().add(
//               DownloaderGetVideo(_tiktokVideoLinkController.text),
//             );
//         // }
//       },
//     );
//   }

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
//       'x-rapidapi-key': '3297f196e6msha861d4907c79366p16c044jsnbfd4786c6006',
//       'x-rapidapi-host':
//           'instagram-downloader-download-instagram-videos-stories1.p.rapidapi.com',
//     };

//     setState(() {
//       _downloading = true;
//       _downloadStatus = 'Downloading video...';
//     });

//     try {
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

//   Future<void> _downloadFile(String url, String filename) async {
//     final response = await http.get(Uri.parse(url));
//     print(':::_downloadFile ${response.body}');
//     print('::: _downloadFile${response.statusCode}');
//     if (response.statusCode == 200) {
//       final appPath = await DirHelper.getAppPath();
//       final filePath = '$appPath/$filename';
//       final file = File(filePath);
//       await file.writeAsBytes(response.bodyBytes);
//       print('Video saved to $filePath');

//       setState(() {
//         _downloadStatus = 'Video downloaded successfully';
//       });
//   // Navigate to DownloadCompleteScreen
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => DownloadsScreen(),
//         ),
//       );
//       // Show snackbar for completion
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Download completed: $filename'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//     } else {
//       setState(() {
//         _downloadStatus = 'Failed to download file';
//       });
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
//               if (_thumbnailUrl != null && _thumbnailUrl.isNotEmpty)
//                 Image.network(
//                   _thumbnailUrl,
//                   height: 150,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                 ),
//               SizedBox(height: 10),
//               _downloading
//                   ? CircularProgressIndicator()
//                   : ElevatedButton(
//                       onPressed: () {
//                         Navigator.pop(context); // Close the bottom sheet
//                       },
//                       child: Text('Close'),
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
// }

import 'dart:convert';
import 'dart:io';

import 'package:duet/helpler.dart';
import 'package:duet/src/core/utils/app_enums.dart';
import 'package:duet/src/features/duet/create_duet.dart';
import 'package:duet/src/features/tiktok_downloader/presentation/screens/downloads_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../../../../config/routes_manager.dart';
import '../../../../../core/utils/app_strings.dart';
import '../../../../../core/widgets/build_toast.dart';
import '../../../../../core/widgets/center_indicator.dart';
import '../../../../../core/widgets/custom_elevated_btn.dart';
import '../../bloc/downloader_bloc/downloader_bloc.dart';
import '../download_bottom_sheet.dart';
import 'downloader_body_input_field.dart';
import 'downloader_body_logo.dart';

class DownloaderScreenBody extends StatefulWidget {
  const DownloaderScreenBody({Key? key}) : super(key: key);

  @override
  State<DownloaderScreenBody> createState() => _DownloaderScreenBodyState();
}

class _DownloaderScreenBodyState extends State<DownloaderScreenBody> {
  TextEditingController _tiktokVideoLinkController = TextEditingController();
  TextEditingController _instaVideoLinkController = TextEditingController();
  TextEditingController _genericVideoLinkController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();
  bool _downloading = false;
  bool _downloadingtiktok = false;
  String _downloadStatus = '';
  String _videoUrl = '';
  String _thumbnailUrl = '';

  @override
  void dispose() {
    _tiktokVideoLinkController.dispose();
    _instaVideoLinkController.dispose();
    _genericVideoLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DownloaderBloc, DownloaderState>(
      listener: (context, state) {
        if (state is DownloaderSaveVideoLoading) {
          Navigator.of(context).popAndPushNamed(Routes.downloads);
        }
        if (state is DownloaderGetVideoFailure) {
          buildToast(msg: state.message, type: ToastType.error);
        }
        if (state is DownloaderGetVideoSuccess &&
            state.tikTokVideo.videoData == null) {
          buildToast(msg: state.tikTokVideo.msg, type: ToastType.error);
        }
        if (state is DownloaderGetVideoSuccess &&
            state.tikTokVideo.videoData != null) {
          buildDownloadBottomSheet(context, state.tikTokVideo);
          context
              .read<DownloaderBloc>()
              .add(DownloaderSaveVideo(tikTokVideo: state.tikTokVideo));
        }
        if (state is DownloaderSaveVideoSuccess) {
          buildToast(msg: state.message, type: ToastType.success);
        }
        if (state is DownloaderSaveVideoFailure) {
          buildToast(msg: state.message, type: ToastType.error);
        }
      },
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(20),
          alignment: AlignmentDirectional.center,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const DownloaderBodyLogo(),
                const SizedBox(height: 40),
                // state is DownloaderGetVideoLoading
                //     ? const CenterProgressIndicator()
                //     :

                _downloadingtiktok
                    ? const CenterProgressIndicator()
                    : Column(
                        children: [
                          CustomElevatedBtn(
                            label: AppStrings.tiktok,
                            onPressed: () {
                              _showDownloadBottomSheet(context, "tiktok");
                            },
                          ),
                          Divider(),
                          const InstaLogo(),
                          const SizedBox(height: 40),
                          _downloading
                              ? const CenterProgressIndicator()
                              : CustomElevatedBtn(
                                  label: 'Download Instagram Video',
                                  onPressed: () {
                                    _showDownloadBottomSheet(
                                        context, "instagram");
                                  },
                                ),
                        ],
                      ),
                const SizedBox(height: 20),

                Divider(),
                Container(
                  width: 100,
                  height: 100,
                  child: Icon(Icons.memory, size: 52,),
                ),
                ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.video,
                    );

                    if (result != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateDuet(
                            filePath: result.files.single.path!,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Pick Video from Local Storage'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _downloadInstagramVideo(String videoUrl) async {
    final url = Uri.parse(
        'https://instagram-downloader-download-instagram-videos-stories1.p.rapidapi.com/?url=${Uri.encodeComponent(videoUrl)}');
    final headers = {
      'x-rapidapi-key': 'f73af0d298mshffd49671f08dbf3p1e74f9jsnfc39709e2678',
      // 'x-rapidapi-key': '3297f196e6msha861d4907c79366p16c044jsnbfd4786c6006',
      'x-rapidapi-host':
          'instagram-downloader-download-instagram-videos-stories1.p.rapidapi.com',
    };

    setState(() {
      _downloading = true;
      _downloadStatus = 'Downloading video...';
    });

    try {
      final response = await http.get(url, headers: headers);
      print('::: ${response.body}');
      print('::: ${response.statusCode}');
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData is List && responseData.isNotEmpty) {
          final videoData = responseData[0];
          setState(() {
            _videoUrl = videoData['url'];
            _thumbnailUrl = videoData['thumb'];
            _downloadStatus = 'Video downloaded successfully';
          });

          // Optionally, save the video file to local storage
          await _downloadFile(videoData['url'], 'video.mp4');
        } else {
          setState(() {
            _downloadStatus = 'Failed to get video URL from response';
          });
        }
      } else {
        setState(() {
          _downloadStatus = 'Failed to download video: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _downloadStatus = 'Error downloading video: $e';
      });
    } finally {
      setState(() {
        _downloading = false;
      });
    }
  }

//   Future<void> _downloadTikTokVideo(String videoUrl) async {
//     final url = Uri.parse('https://tiktok-video-no-watermark2.p.rapidapi.com/');
//     final headers = {
//       'x-rapidapi-key': '652fc95660msh4825c876ba3276bp12a6b1jsnd1d5785bdd60',
//       'x-rapidapi-host': 'tiktok-video-no-watermark2.p.rapidapi.com',
//       'Content-Type':
//           'multipart/form-data; boundary=---011000010111000001101001',
//     };

//     final body = '''
// -----011000010111000001101001
// Content-Disposition: form-data; name="url"

// $videoUrl
// -----011000010111000001101001
// Content-Disposition: form-data; name="hd"

// 1
// -----011000010111000001101001--
// ''';

//     setState(() {
//       _downloadingtiktok = true;
//       _downloadStatus = 'Downloading video...';
//     });

//     try {
//       final response = await http.post(url, headers: headers, body: body);
//       print(':::_downloadTikTokVideo ${response.body}');
//       print(':::_downloadTikTokVideo ${response.statusCode}');
//       if (response.statusCode == 200) {
//         final responseData = json.decode(response.body);
//         if (responseData['videoUrl'] != null) {
//           setState(() {
//             _videoUrl = responseData['videoUrl'];
//             _downloadStatus = 'Video downloaded successfully';
//           });

//           // Optionally, save the video file to local storage
//           await _downloadFile(responseData['videoUrl'], 'video.mp4');
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
//         _downloadingtiktok = false;
//       });
//     }
//   }

  Future<void> _downloadFile(String url, String filename) async {
    final response = await http.get(Uri.parse(url));
    print(':::_downloadFile ${response.body}');
    print('::: _downloadFile${response.statusCode}');
    if (response.statusCode == 200) {
      final appPath = await DirHelper.getAppPath();
      final filePath = '$appPath/$filename';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      print('Video saved to $filePath');

      setState(() {
        _downloadingtiktok = false;
        _downloadStatus = 'Video downloaded successfully';
      });
      // Navigate to DownloadCompleteScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateDuet(
            filePath: filePath,
          ),
        ),
      );
      // Show snackbar for completion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download completed: $filename'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      setState(() {
        _downloadStatus = 'Failed to download file';
      });
      print('Failed to download file');
    }
  }

  void _showDownloadBottomSheet(BuildContext context, String platform) {
    showModalBottomSheet(
      isScrollControlled:
          true, // This makes the bottom sheet full-screen when keyboard is shown
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                platform == "tiktok" ? DownloaderBodyLogo() : InstaLogo(),
                SizedBox(height: 20),
                TextField(
                  controller: _genericVideoLinkController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: platform == "tiktok"
                        ? 'TikTok Video URL'
                        : 'Instagram Video URL',
                  ),
                ),
                SizedBox(height: 20),
                _downloading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          final videoUrl = _genericVideoLinkController.text;
                          if (videoUrl.isNotEmpty) {
                            if (platform == "tiktok") {
                              context.read<DownloaderBloc>().add(
                                    DownloaderGetVideo(videoUrl),
                                  );
                              // _downloadTikTokVideo(videoUrl);
                            } else {
                              _downloadInstagramVideo(videoUrl);
                            }
                            Navigator.pop(context); // Close the bottom sheet
                          } else {
                            setState(() {
                              _downloadStatus = "Please enter a valid URL";
                            });
                          }
                        },
                        child: Text('Download Video'),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
