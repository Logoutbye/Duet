import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/routes_manager.dart';
import 'config/theme_manager.dart';
import 'container_injector.dart';
import 'features/tiktok_downloader/presentation/bloc/downloader_bloc/downloader_bloc.dart';

import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:banuba_sdk/banuba_sdk.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _banubaSdkManager = BanubaSdkManager();
  final _epWidget = EffectPlayerWidget(key: null);

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    await _banubaSdkManager.initialize([],
        "Qk5CIPgcrV+G/OnXaR6L4EOqDdtvOE50pEwyM9pC5ImYD3uhJkIWuRk7XnRuzD4GF3ph7B2iq28mMPeXkEfqonPd+kehHL0Gm5C/ttMcK0HhjeT01+2t+R4wOTVUxy8ehTN/M1kF6yRIhzoMIZxl3asu3C52QYrNHYX8l+9FHQnpK98wI3B3izPWUOTWAf2+y8njm6ZZgs/yNRJHpBNJktwgpntFCR9m+Jcq8tjNcewMQhdqfwsRSs98A7qwgaCaY4peQ2RmaUcnbtB2+Fh5rmWPWalvSfk1kND7M6RBwkyLgBKvbDDl0JyEoFynTz2omMf5b4yaNpLPcZNjtxsM46OcAAnec2HKH25U86Kt84d6XgMf9bClKVf1jsOcTxPxXlzy3rIqwHqKXfpG+tCtVQ+XBaSu8GcudWW7owTemDPhyHa0c7U9vTgroKeH3hDAmWj4JIDCo/IzCuzoKjFOGhmxw00vY7uZf2vGqrcNnV2kZwadu9MCFaCKuI4a3332LNoyY6CdutxQKbO+aQ+7VhVHZY79c/fCOhqLOxEWR0n100QpYFyINyNQzHDCN3Zj+5wdMlmf6V2BR3joj2hGeIcOFp849ru4ay5N+1UYFNaH1DLCaQXPH/ulhuHZH/+auCZQFjw0lrYj7+3D+NjlOw==",
        SeverityLevel.info);

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {});

    // It is required to grant all permissions for the plugin: Camera, Micro, Storage
    requestPermissions().then((granted) {
      if (granted) {
        debugPrint('CameraPage: Thanks! All permissions are granted!');
        openCamera();
      } else {
        debugPrint(
            'CameraPage: WARNING! Not all required permissions are granted!');
        // Plugin cannot be used. Handle this state on your app side
        SystemNavigator.pop();
      }
    }).onError((error, stackTrace) {
      debugPrint('CameraPage: ERROR! Plugin cannot be used : $error');
      // Plugin cannot be used. Handle this state on your app side
      SystemNavigator.pop();
    });
  }

  Future<void> openCamera() async {
    await _banubaSdkManager.openCamera();
    await _banubaSdkManager.attachWidget(_epWidget.banubaId);

    await _banubaSdkManager.startPlayer();
    await _banubaSdkManager.loadEffect("effects/TrollGrandma", false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DownloaderBloc>(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        // initialRoute: Routes.splash,
        // onGenerateRoute: AppRouter.getRoute,
        home: _epWidget,

        theme: getAppTheme(),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _banubaSdkManager.startPlayer();
    } else {
      _banubaSdkManager.stopPlayer();
    }
  }
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
  if (Platform.isAndroid) {
    return [Permission.camera, Permission.microphone, Permission.storage];
  } else if (Platform.isIOS) {
    return [Permission.camera, Permission.microphone];
  } else {
    throw Exception('Platform is not supported!');
  }
}
