# interactiveviewer_gallery_plus
[![pub package](https://img.shields.io/pub/v/interactiveviewer_gallery.svg)](https://pub.dartlang.org/packages/interactiveviewer_gallery)
从 插件 [interactiveviewer_gallery](https://pub.dev/packages/interactiveviewer_gallery/versions) fork
图片预览&视频预览&图片视频混合预览的容器UI
1. 支持双指缩放
2. 支持双击放大
3. 支持左右切换图片
4. 支持下拉手势返回, 伴随缩小、移动、透明度变化
5. 支持视频失去焦点自动暂停
6. 下拉返回手势支持左右移动
7. 更顺滑的手势放大体验

## 预览
在犬岛APP上，使用该插件实现的图片浏览效果如下：
[youtube](https://youtu.be/GWtGYJc-1-Y)

[在Appstore下载犬岛](https://apps.apple.com/se/app/id6450510581)
[在应用宝下载犬岛](https://a.app.qq.com/o/simple.jsp?pkgname=com.fixtime.quandao)

## 安装

因为该库是在InteractiveViewer基础上实现的, 所以flutter版本不低于1.20.0
```dart
interactiveviewer_gallery: ${last_version}
```

## 如何使用
1. 九宫格图片页面中图片组件包裹Hero(用来跳转的承接动画)
```dart
Hero(
    tag: source.url,
    child: ${gridview item}
)
 ```

2. 点击九宫格图片跳转到图片预览页面
```dart
Navigator.of(context).push(
    HeroDialogRoute<void>(
      builder: (BuildContext context) => InteractiveviewerGallery<DemoSourceEntity>(
          sources: sourceList,
          initIndex: sourceList.indexOf(source),
          // 定义自己的item
          itemBuilder: itemBuilder,
          onPageChanged: (int pageIndex) {
            print("nell-pageIndex:$pageIndex");
          },
      ),
    ),
  );
```

3. 定义自己的item (因为每个人的UI设计不一样, 所以这里需要自己实现item, 该库只是一个UI容器), 可以参考预览视频中的实现: [example/lib/main.dart](https://github.com/qq326646683/interactiveviewer_gallery/blob/main/example/lib/main.dart)

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

## 其他
欢迎pr和讨论
