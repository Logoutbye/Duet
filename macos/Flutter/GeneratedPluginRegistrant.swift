//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import ffmpeg_kit_flutter
import file_selector_macos
import package_info_plus
import path_provider_foundation
import sqflite
import video_player_avfoundation
import wakelock_plus

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  FFmpegKitFlutterPlugin.register(with: registry.registrar(forPlugin: "FFmpegKitFlutterPlugin"))
  FileSelectorPlugin.register(with: registry.registrar(forPlugin: "FileSelectorPlugin"))
  FPPPackageInfoPlusPlugin.register(with: registry.registrar(forPlugin: "FPPPackageInfoPlusPlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  SqflitePlugin.register(with: registry.registrar(forPlugin: "SqflitePlugin"))
  FVPVideoPlayerPlugin.register(with: registry.registrar(forPlugin: "FVPVideoPlayerPlugin"))
  WakelockPlusMacosPlugin.register(with: registry.registrar(forPlugin: "WakelockPlusMacosPlugin"))
}
