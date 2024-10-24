# interactiveviewer_gallery_plus
[![pub package](https://img.shields.io/pub/v/interactiveviewer_gallery.svg)](https://pub.dartlang.org/packages/interactiveviewer_gallery)

[中文文档](./README_CH.md)
fork from [interactiveviewer_gallery](https://pub.dev/packages/interactiveviewer_gallery/versions)
A flutter library to show picture and video preview gallery
support
1. two-finger gesture zoom
2. double-click to zoom
3. switch left and right
4. gesture back: scale, transfer, opacity of background
5. video auto paused when miss focus
6. Pull-down gesture supports left and right movement
7. Smoother gesture zooming experience

## Preview
The picture browsing effect achieved by using this plug-in is as follows in QuanDao【犬岛】 App。
[youtube](https://youtu.be/GWtGYJc-1-Y)

[犬岛 download in appstore](https://apps.apple.com/se/app/id6450510581)
[犬岛 download in qq market](https://a.app.qq.com/o/simple.jsp?pkgname=com.fixtime.quandao)

## Setup

because the library is base on InteractiveViewer so require flutter verion above or equal 1.20.0
```dart
interactiveviewer_gallery: ${last_version}
```

## How to use

1. Wrap Hero in your image gridview item:
```dart
Hero(
    tag: source.url,
    child: ${gridview item}
)
 ```

2. gridview item's GestureDetector add jumping to interactiveviewer_gallery:
```dart
// DemoSourceEntity is your data model
// itemBuilder is gallery page item
void _openGallery(DemoSourceEntity source) {
  Navigator.of(context).push(
    HeroDialogRoute<void>(
      // DisplayGesture is just debug, please remove it when use
      builder: (BuildContext context) => InteractiveviewerGallery<DemoSourceEntity>(
          sources: sourceList,
          initIndex: sourceList.indexOf(source),
          itemBuilder: itemBuilder,
          onPageChanged: (int pageIndex) {
            print("nell-pageIndex:$pageIndex");
          },
      ),
    ),
  );
}
```

3. edit itemBuilder: you can reference the [example/lib/main.dart](https://github.com/qq326646683/interactiveviewer_gallery/blob/main/example/lib/main.dart) then customize

```dart
Widget itemBuilder(BuildContext context, int index, bool isFocus) {
  DemoSourceEntity sourceEntity = sourceList[index];
  if (sourceEntity.type == 'video') {
    return DemoVideoItem(
      sourceEntity,
      isFocus: isFocus,
    );
  } else {
    return DemoImageItem(sourceEntity);
  }
}
```

## Other
Comments and pr are welcome
