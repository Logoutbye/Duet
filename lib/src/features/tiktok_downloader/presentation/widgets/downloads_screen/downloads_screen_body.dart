import 'package:duet/src/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'new_downloads_section.dart';
import 'old_downloads_section.dart';

class DownloadsScreenBody extends StatelessWidget {
  const DownloadsScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          NewDownloadsSection(),
          OldDownloadsSection(),
        ],
      ),
    );
  }
}
