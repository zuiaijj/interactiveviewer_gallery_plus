import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'dart:math' as math;

// https://quandaoimages.fixtime.com/caf69670-8584-11ef-b197-f5d39dc8e39e.MOV
// https://quandaoimages.fixtime.com/d1993230-8584-11ef-b197-f5d39dc8e39e.jpg
class LivePhotoWrapper extends StatefulWidget {
  final double? width;
  final double? height;
  final String liveUrl;
  final File? localLiveFile;
  final bool canVideoAutoPlay;
  final bool canPressPlay;
  final Widget? coverPic;
  final Function? onTap;
  final Size markSize;
  final AlignmentGeometry markAlign;
  final EdgeInsetsGeometry markPadding;
  final EdgeInsetsGeometry? markMargin;

  const LivePhotoWrapper({
    super.key,
    this.width,
    this.height,
    this.canVideoAutoPlay = false,
    this.coverPic,
    this.onTap,
    required this.liveUrl,
    this.localLiveFile,
    this.canPressPlay = true,
    required this.markSize,
    this.markAlign = Alignment.bottomLeft,
    this.markPadding = const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
    this.markMargin,
  });
  @override
  _LivePhotoWrapperState createState() => _LivePhotoWrapperState();
}

enum LivePlayType {
  init,
  isBuffering,
  isPlaying,
  playEnd,
}

class _LivePhotoWrapperState extends State<LivePhotoWrapper> {
  VideoPlayerController? _livePlayController;
  double? get width => widget.width;
  double? get height => widget.height;
  String get liveSourceStr => widget.liveUrl;
  EdgeInsetsGeometry get markMargin =>
      widget.markMargin ??
      EdgeInsets.symmetric(
          horizontal: widget.markSize.width / 3.5,
          vertical: widget.markSize.height / 1.5);
  RxBool isShowLoading = false.obs;
  RxInt rotationCorrection = 0.obs;

  VideoPlayerController? get currentController {
    return _livePlayController;
  }

  Rx<LivePlayType> livePlayStatus = (LivePlayType.init).obs;

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    if (liveSourceStr.isEmpty && widget.localLiveFile == null) return;
    if (widget.localLiveFile != null) {
      _livePlayController = VideoPlayerController.file(widget.localLiveFile!,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
    } else {
      _livePlayController = VideoPlayerController.networkUrl(
          Uri.parse(liveSourceStr),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
    }
    await _livePlayController?.initialize();
    _livePlayController!
      ..setVolume(0)
      ..setLooping(false)
      ..addListener(() {
        _onVideoPlayerControllerChange();
        if (mounted) {
          setState(() {});
        }
      });
    if (widget.canVideoAutoPlay == true) {
      _onLivePlay(false);
    }
  }

  @override
  void didUpdateWidget(covariant LivePhotoWrapper oldWidget) {
    if (widget.canVideoAutoPlay) {
      _onLivePlay(false);
    } else {
      _onLivePhotoStop();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _onLivePlay(bool byHand) async {
    // if (byHand) {
    //   _onClearLiveRemind();
    // }
    if (livePlayStatus.value == LivePlayType.isPlaying) return;
    if (currentController?.value.isInitialized == true) {
      // if (byHand) {
      // HapticFeedback.lightImpact();
      // }
      // hapticFeedback();
      currentController?.play();
    }
  }

  _onVideoPlayerControllerChange() async {
    rotationCorrection.value = currentController!.value.rotationCorrection;
    if (currentController!.value.isBuffering) {
      livePlayStatus.value = LivePlayType.isBuffering;
      if (isShowLoading.value) {
        return;
      }
      isShowLoading.value = true;
      return;
    } else {
      if (isShowLoading.value) {
        isShowLoading.value = false;
      }
    }

    if (currentController!.value.isPlaying) {
      livePlayStatus.value = LivePlayType.isPlaying;
    }

    Duration position = currentController!.value.position;
    if (currentController!.value.isPlaying == false &&
        (position == currentController!.value.duration ||
            position == Duration.zero)) {
      livePlayStatus.value = LivePlayType.playEnd;
      return;
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _onLivePhotoStop() async {
    if (livePlayStatus.value == LivePlayType.playEnd) return;
    await currentController?.pause();
    await currentController?.seekTo(Duration.zero);
  }

  Widget _buildLivePhotosWrapper() {
    return Stack(
      children: <Widget>[
        Positioned.fill(child: widget.coverPic ?? Container()),
        if (currentController?.value.isInitialized == true)
          Container(
            width: widget.width,
            height: widget.height,
            child: ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: currentController!,
              builder: (_, VideoPlayerValue value, Widget? child) {
                return Opacity(
                  opacity: value.isPlaying ? 1 : 0,
                  child: child,
                );
              },
              child: Obx(() {
                Widget child = VideoPlayer(currentController!);
                if (rotationCorrection.value != 0) {
                  return Transform.rotate(
                    angle: -rotationCorrection.value * math.pi / 180,
                    child: child,
                  );
                }
                return child;
              }),
            ),
          ),
        Positioned.fill(child: Obx(() {
          if (isShowLoading.value) {
            return Center(
              child: Container(
                  color: null, child: CupertinoActivityIndicator(radius: 10)),
            );
          } else {
            return Container(
              width: 0,
              height: 0,
            );
          }
        })),
        if (currentController != null)
          Positioned.fill(
            child: ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: currentController!,
              builder: (_, VideoPlayerValue value, Widget? child) {
                return Opacity(
                  opacity: value.isPlaying ? 0 : 1,
                  child: child,
                );
              },
              child: widget.coverPic ?? Container(),
            ),
          ),
        Align(
          alignment: widget.markAlign,
          child: _buildLivePhotoMark(),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // behavior: HitTestBehavior.opaque,
      onTap: () {
        widget.onTap?.call();
      },
      onLongPress: widget.canPressPlay == true ? () => _onLivePlay(true) : null,
      onLongPressEnd:
          widget.canPressPlay == true ? (_) => _onLivePhotoStop() : null,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                  color: null, child: CupertinoActivityIndicator(radius: 16)),
            ),
          ),
          Container(
              width: widget.width,
              height: widget.height,
              child: Center(child: _buildLivePhotosWrapper())),
        ],
      ),
    );
  }

  _buildLivePhotoMark() {
    return LivePhotoMask(
      onlyIcon: false,
      markMargin: markMargin,
      markSize: widget.markSize,
      markPadding: widget.markPadding,
      frontColor: Theme.of(context).colorScheme.background,
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }

  @override
  dispose() {
    currentController?.dispose();
    super.dispose();
  }
}

class LivePhotoMask extends StatelessWidget {
  final EdgeInsetsGeometry markMargin;
  final EdgeInsetsGeometry markPadding;
  final Size markSize;
  final bool onlyIcon;
  final Color frontColor;
  final Color backgroundColor;
  final bool displayBackGround;

  const LivePhotoMask(
      {super.key,
      required this.markMargin,
      required this.markSize,
      required this.markPadding,
      this.onlyIcon = false,
      this.frontColor = Colors.white,
      this.backgroundColor = Colors.black,
      this.displayBackGround = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: markMargin,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            // padding: EdgeInsets.symmetric(vertical: 5),
            decoration: displayBackGround
                ? BoxDecoration(
                    color: backgroundColor.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(
                        markSize.height / 2 + markPadding.vertical))
                : null,
            width: markSize.width,
            height: markSize.height,
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!onlyIcon)
                  Visibility(
                    visible: markSize.width > 50,
                    child: Text(
                      "实况",
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: frontColor,
                          fontWeight: FontWeight.normal,
                          letterSpacing: 0),
                    ),
                  ),
                if (!onlyIcon)
                  Visibility(
                      visible: markSize.width > 50,
                      child: SizedBox(
                        width: markSize.width / 50,
                      )),
                Image.asset(
                  "assets/live_photo.png",
                  width: markSize.height * 17 / 24,
                  height: markSize.height * 17 / 24,
                  color: frontColor,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LivePhotoConfigController extends GetxController {
  RxBool remindClickSelectLiveContent = false.obs;

  // int? get myUid => AccountManager.instance.getLocalSelfUser().id;

  @override
  void onInit() {
    super.onInit();
    _initConfig();
  }

  @override
  void onClose() {
    super.onClose();
  }

  _initConfig() async {
    // if (Platform.isAndroid) {
    //   remindClickSelectLiveContent.value = true;
    // } else {
    //   remindClickSelectLiveContent.value =
    //       await getPrefs("$myUid-${StorageConstants.spHasClickSelectLiveKey}") ?? false;
    // }
  }

  clickLiveSelectRemind() {
    // remindClickSelectLiveContent.value = true;
    // setPrefsBool("$myUid-${StorageConstants.spHasClickSelectLiveKey}", true);
  }
}
