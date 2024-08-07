import 'package:duet/src/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/downloader_bloc/downloader_bloc.dart';
import 'custom_downloads_item.dart';

class NewDownloadsSection extends StatelessWidget {
  const NewDownloadsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloaderBloc, DownloaderState>(
      builder: (context, state) {
        final newDownloads = context.read<DownloaderBloc>().newDownloads;

        return newDownloads.length <= 0
            ? SizedBox()
            : Column(
                children: [
                  Text("New Video"),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Column(
                      children: List.generate(
                        newDownloads.length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: CustomDownloadsItem(
                            item: newDownloads[index],
                          ),
                        ),
                      ).toList(),
                    ),
                  ),
                  const Divider(
                      color: AppColors.black, thickness: 1, height: 10),
                ],
              );
      },
    );
  }
}
