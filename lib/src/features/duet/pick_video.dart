import 'package:duet/src/features/duet/create_duet.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class PickVideoScreen extends StatefulWidget {
  const PickVideoScreen({super.key});

  @override
  State<PickVideoScreen> createState() => _PickVideoScreenState();
}

class _PickVideoScreenState extends State<PickVideoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
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
      ),
    );
  }
}
