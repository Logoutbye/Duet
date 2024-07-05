import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:duet/helpler.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class CreateDuet extends StatefulWidget {
  final String filePath;

  const CreateDuet({super.key, required this.filePath});

  @override
  _CreateDuetState createState() => _CreateDuetState();
}

class _CreateDuetState extends State<CreateDuet> {
  bool _isLoading = true;
  bool _isRecording = false;

  late CameraController _cameraController;
  late VideoPlayerController _videoPlayerController;
  late VideoPlayerController _selectedVideoPlayerController;

  String? isRecordedVideo;

  @override
  void initState() {
    print(':::: This is local video thing ${widget.filePath}');
    _initCamera();
    _selectedVideoPlayerController =
        VideoPlayerController.file(File(widget.filePath))
          ..addListener(() {
            setState(() {});
          })
          ..setLooping(true)
          ..initialize().then((_) {
            setState(() {});
            // _selectedVideoPlayerController.pause();
          });
    super.initState();
  }

  Future _initVideoPlayer() async {
    _videoPlayerController = VideoPlayerController.file(File(isRecordedVideo!));
    await _videoPlayerController.initialize();
    await _videoPlayerController.setLooping(true);
    await _videoPlayerController.play();
  }

  _initCamera() async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front);
    _cameraController = CameraController(front, ResolutionPreset.ultraHigh);

    await _cameraController.initialize();
    setState(() => _isLoading = false);
  }

  _recordVideo() async {
    if (_isRecording) {
      final file = await _cameraController.stopVideoRecording();
      setState(() => _isRecording = false);
      isRecordedVideo = file.path;
    } else {
      await _cameraController.prepareForVideoRecording();
      await _cameraController.startVideoRecording();
      setState(() => _isRecording = true);
    }
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Merging videos..."),
            ],
          ),
        );
      },
    );
  }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// good but resoultion is low

  Future<void> mergeVideos(
      String outputPath, String recordedPath, String pickedPath) async {
    // Normalize both videos to the same resolution
    const filter =
        "[0:v]scale=480:640,setsar=1[l];[1:v]scale=480:640,setsar=1[r];[l][r]hstack=inputs=2[v]";
    // Normalize both videos to a higher resolution while maintaining aspect ratio
    // const filter =
    //     "[0:v]scale=1080:1920,setsar=1[l];[1:v]scale=1080:1920,setsar=1[r];[l][r]hstack=inputs=2[v]";

    final command =
        '-y -i $pickedPath -i $recordedPath -filter_complex "$filter" -map "[v]" $outputPath';
    showLoadingDialog(context); // Show the loading dialog

    await FFmpegKit.execute(command).then((session) async {
      final returnCode = await session.getReturnCode();
      final failStackTrace = await session.getFailStackTrace();
      final output = await session.getOutput();

      Navigator.pop(context); // Remove the loading dialog

      if (ReturnCode.isSuccess(returnCode)) {
        await GallerySaver.saveVideo(outputPath);
        print("Merge successful");
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyPost1(outputPath: outputPath),
            ),
          );
        }
      } else {
        // if (mounted) {
        //   Navigator.pop(context);
        // }
        print("Merge failed");
        print("Return code: ${returnCode?.getValue()}");
        print("Output: $output");
        print("Error: $failStackTrace");

        // Retry with adjusted parameters if the initial attempt fails
        await retryMergeWithAdjustedParameters(
            recordedPath, pickedPath, outputPath);
      }
    });
  }

  Future<void> retryMergeWithAdjustedParameters(
      String recordedPath, String pickedPath, String outputPath) async {
    // Convert both videos to MP4 format and retry merging
    String convertedRecordedPath = await convertToMp4(recordedPath);
    String convertedPickedPath = await convertToMp4(pickedPath);

    // const filter =
    //     "[0:v]scale=480:640,setsar=1[l];[1:v]scale=480:640,setsar=1[r];[l][r]hstack=inputs=2[v]";

    const filter =
        "[0:v]scale=1080:1920,setsar=1[l];[1:v]scale=1080:1920,setsar=1[r];[l][r]hstack=inputs=2[v]"; // use this for higher resoultion

    final command =
        '-y -i $convertedPickedPath -i $convertedRecordedPath -filter_complex "$filter" -map "[v]" $outputPath';

    if (mounted) {
      showLoadingDialog(context);
    }

    await FFmpegKit.execute(command).then((session) async {
      final returnCode = await session.getReturnCode();
      final failStackTrace = await session.getFailStackTrace();
      final output = await session.getOutput();
      if (mounted) {
        Navigator.pop(context); // Remove the loading dialog
      }

      if (ReturnCode.isSuccess(returnCode)) {
        await GallerySaver.saveVideo(outputPath);
        print("::: Retry merge successful");
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyPost1(outputPath: outputPath),
            ),
          );
        }
      } else {
        print("::: Retry merge failed");
        print("::: Return code: ${returnCode?.getValue()}");
        print("::: Output: $output");
        print("::: Error: $failStackTrace");

        const snackBar = SnackBar(
          content: Text('Merge failed after retries. Check logs for details.'),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
    });
  }

  Future<String> convertToMp4(String inputPath) async {
    String outputPath =
        '${inputPath.substring(0, inputPath.lastIndexOf('.'))}.mp4';
    final command = '-y -i $inputPath $outputPath';

    await FFmpegKit.execute(command).then((session) async {
      final returnCode = await session.getReturnCode();
      if (!ReturnCode.isSuccess(returnCode)) {
        print("::: Conversion to MP4 failed for $inputPath");
        outputPath = inputPath; // Use original file if conversion fails
      }
    });

    return outputPath;
  }

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

  // good but some times merge fail
  // Future<void> mergeVideos(
  //     String outputPath, String recordedPath, String pickedPath) async {
  //   const filter =
  //       "[0:v]scale=iw/2:ih/2,setsar=1[l];[1:v]scale=iw/2:ih/2,setsar=1[r];[l][r]hstack=inputs=2[v]";

  //   final command =
  //       '-y -i $pickedPath -i $recordedPath -filter_complex "$filter" -map "[v]" $outputPath';
  //   showLoadingDialog(context); // Show the loading dialog

  //   await FFmpegKit.execute(command).then((session) async {
  //     final returnCode = await session.getReturnCode();

  //     Navigator.pop(context); // Remove the loading dialog

  //     if (ReturnCode.isSuccess(returnCode)) {
  //       await GallerySaver.saveVideo(outputPath);
  //       print("Merge successful");
  //       if (mounted) {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => MyPost1(outputPath: outputPath),
  //           ),
  //         );
  //       }
  //     } else {
  //       Navigator.pop(context);
  //       print("Merge failed");
  //       const snackBar = SnackBar(
  //         content: Text('Merge failed'),
  //       );
  //       ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //     }
  //   });
  // }

  Future<String> getOutputPath() async {
    final directory = await getExternalStorageDirectory();
    return '${directory!.path}/combined_video.mp4';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 1,
                  width: MediaQuery.of(context).size.width / 2,
                  color: Colors.black,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: _selectedVideoPlayerController
                                .value.isInitialized
                            ? AspectRatio(
                                aspectRatio: _selectedVideoPlayerController
                                    .value.aspectRatio,
                                child:
                                    VideoPlayer(_selectedVideoPlayerController),
                              )
                            : const CircularProgressIndicator(),
                      ),
                    ],
                  ),
                ),
                isRecordedVideo == null
                    ? Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CameraPreview(
                              _cameraController,
                            ),
                          ],
                        ),
                      )
                    : Expanded(
                        child: FutureBuilder(
                          future: _initVideoPlayer(),
                          builder: (context, state) {
                            if (state.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Center(
                                    child: AspectRatio(
                                        aspectRatio: _videoPlayerController
                                            .value.aspectRatio,
                                        child: VideoPlayer(
                                          _videoPlayerController,
                                        )),
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ),
              ],
            ),
      bottomSheet: Container(
        // color: Colors.amber,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                // IconButton(
                //   onPressed: () {
                //     if (isRecordedVideo == null) {
                //       _recordVideo();
                //       _selectedVideoPlayerController.value.isPlaying
                //           ? _selectedVideoPlayerController.play()
                //           : _selectedVideoPlayerController.play();
                //     } else {
                //       _videoPlayerController.value.isPlaying
                //           ? _videoPlayerController.pause()
                //           : _videoPlayerController.play();

                //       _selectedVideoPlayerController.value.isPlaying
                //           ? _selectedVideoPlayerController.play()
                //           : _selectedVideoPlayerController.play();
                //     }
                //   },
                //   icon: Icon(
                //     _isRecording ? Icons.stop : Icons.circle,
                //     size: 52,
                //   ),
                // ),

                // child: Icon(_isRecording ? Icons.stop : Icons.circle),
                Container(
                  padding: EdgeInsets.all(12),
                  width: 100,
                  height: 100,
                  child: AnimatedPlayButton(
                    onPressed: () {
                      if (isRecordedVideo == null) {
                        _recordVideo();
                        _selectedVideoPlayerController.value.isPlaying
                            ? _selectedVideoPlayerController.play()
                            : _selectedVideoPlayerController.play();
                      } else {
                        _videoPlayerController.value.isPlaying
                            ? _videoPlayerController.pause()
                            : _videoPlayerController.play();

                        _selectedVideoPlayerController.value.isPlaying
                            ? _selectedVideoPlayerController.play()
                            : _selectedVideoPlayerController.play();
                      }
                    },
                  ),
                ),
                isRecordedVideo != null
                    ? IconButton(
                        onPressed: () async {
                          final outputPath = await getOutputPath();
                          await mergeVideos(
                              outputPath, isRecordedVideo!, widget.filePath);
                        },
                        icon: Icon(Icons.done))
                    : SizedBox(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _videoPlayerController.dispose();
    _selectedVideoPlayerController.dispose();

    super.dispose();
  }
}

class AnimatedPlayButton extends StatefulWidget {
  final bool initialIsPlaying;
  final Icon playIcon;
  final Icon pauseIcon;
  final VoidCallback onPressed;

  const AnimatedPlayButton({
    super.key,
    required this.onPressed,
    this.initialIsPlaying = false,
    this.playIcon = const Icon(Icons.play_arrow),
    this.pauseIcon = const Icon(Icons.pause),
  });

  @override
  _AnimatedPlayButtonState createState() => _AnimatedPlayButtonState();
}

class _AnimatedPlayButtonState extends State<AnimatedPlayButton>
    with TickerProviderStateMixin {
  static const _kToggleDuration = Duration(milliseconds: 300);
  static const _kRotationDuration = Duration(seconds: 5);

  late bool isPlaying;

  late AnimationController _rotationController;
  late AnimationController _scaleController;
  double _rotation = 0;
  double _scale = 0.85;

  bool get _showWaves => !_scaleController.isDismissed;

  void _updateRotation() => _rotation = _rotationController.value * 2 * pi;
  void _updateScale() => _scale = (_scaleController.value * 0.2) + 0.85;

  @override
  void initState() {
    isPlaying = widget.initialIsPlaying;
    _rotationController =
        AnimationController(vsync: this, duration: _kRotationDuration)
          ..addListener(() => setState(_updateRotation))
          ..repeat();

    _scaleController =
        AnimationController(vsync: this, duration: _kToggleDuration)
          ..addListener(() => setState(_updateScale));

    super.initState();
  }

  void _onToggle() {
    setState(() => isPlaying = !isPlaying);

    if (_scaleController.isCompleted) {
      _scaleController.reverse();
    } else {
      _scaleController.forward();
    }

    widget.onPressed();
  }

  Widget _buildIcon(bool isPlaying) {
    return SizedBox.expand(
      key: ValueKey<bool>(isPlaying),
      child: IconButton(
        icon: isPlaying ? widget.pauseIcon : widget.playIcon,
        onPressed: _onToggle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_showWaves) ...[
            Blob(
                color: const Color(0xff0092ff),
                scale: _scale,
                rotation: _rotation),
            Blob(
                color: const Color(0xff4ac7b7),
                scale: _scale,
                rotation: _rotation * 2 - 30),
            Blob(
                color: const Color(0xffa4a6f6),
                scale: _scale,
                rotation: _rotation * 3 - 45),
          ],
          Container(
            constraints: const BoxConstraints.expand(),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: AnimatedSwitcher(
              duration: _kToggleDuration,
              child: _buildIcon(isPlaying),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }
}

class Blob extends StatelessWidget {
  final double rotation;
  final double scale;
  final Color color;

  const Blob(
      {super.key, required this.color, this.rotation = 0, this.scale = 1});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Transform.rotate(
        angle: rotation,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(150),
              topRight: Radius.circular(240),
              bottomLeft: Radius.circular(220),
              bottomRight: Radius.circular(180),
            ),
          ),
        ),
      ),
    );
  }
}
