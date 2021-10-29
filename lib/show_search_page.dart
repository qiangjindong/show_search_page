import 'dart:async';

import 'package:flutter/material.dart';

const searchBarHeroTag = "search_bar_hero_tag";

Future<T?> showSearchPage<T>(BuildContext context, SearchPage searchPage) {
  final child = Scaffold(
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          Hero(
            tag: searchBarHeroTag,
            child: Material(
              child: _SearchBar(
                controller: searchPage.textEditingController,
                focusNode: searchPage.focusNode,
                hintText: searchPage.hintText,
                onChanged: searchPage.textChange,
                onSeached: searchPage.search,
                // 设置true，和动画时间有冲突
                autofocus: false,
              ),
            ),
          ),
          Expanded(child: searchPage.build(context)),
        ],
      ),
    ),
  );

  // 直接用设置 autofocus 和动画时间有冲突， 之所以设置350毫秒是因为动画时间是300毫秒。
  // 系统的处理方式是将动画传给widget，设置动画Listener，动画结束再requestFocus
  if (searchPage.autofocus) {
    Future.delayed(
      const Duration(milliseconds: 350),
      () => searchPage.focusNode.requestFocus(),
    );
  }

  return Navigator.push(context, _SearchPageRoute<T>(child));
}

abstract class SearchPage extends StatelessWidget {
  SearchPage({Key? key, this.autofocus = false}) : super(key: key);

  final TextEditingController textEditingController = TextEditingController();

  final FocusNode focusNode = FocusNode();

  final bool autofocus;

  String? get hintText;

  void search(String text);

  void textChange(String text);

  @override
  Widget build(BuildContext context);
}

class _SearchPageRoute<T> extends PageRoute<T> {
  final Widget body;

  _SearchPageRoute(this.body);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return body;
  }

  @override
  bool get maintainState => false;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  @override
  Animation<double> createAnimation() {
    final Animation<double> animation = super.createAnimation();
    return animation;
  }
}

class _SearchBar extends StatelessWidget {
  _SearchBar({
    Key? key,
    this.autofocus = false,
    this.hintText,
    this.onSeached,
    this.onChanged,
    this.text,
    required this.controller,
    required this.focusNode,
  }) : super(key: key);

  final String? text;
  final bool autofocus;
  final String? hintText;
  final void Function(String)? onSeached;
  final void Function(String)? onChanged;
  final TextEditingController controller;
  final FocusNode focusNode;

  final StreamController streamController =
      StreamController<String>.broadcast();

  void _seach(String text) {
    if (onSeached != null) {
      onSeached!(text);
    }
  }

  void _change(String text) {
    streamController.sink.add(text);
    if (onChanged != null) {
      onChanged!(text);
    }
  }

  void _clear() {
    focusNode.requestFocus();
    controller.clear();
    _change("");
  }

  void _close(BuildContext context) {
    focusNode.unfocus();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    var prefixIcon = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Icon(
        Icons.search_rounded,
        color: Colors.grey.shade600,
      ),
    );

    var textFiled = Expanded(
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          hintText: hintText,
          isDense: true,
          contentPadding: const EdgeInsets.all(0),
          border: InputBorder.none,
        ),
        autofocus: autofocus,
        textInputAction: TextInputAction.search,
        onSubmitted: _seach,
        onChanged: _change,
      ),
    );

    final clearButton = StreamBuilder(
        stream: streamController.stream,
        builder: (_, __) {
          final button = GestureDetector(
            onTap: _clear,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Icons.close_rounded,
                color: Colors.grey.shade600,
              ),
            ),
          );

          return controller.text.isEmpty ? const SizedBox() : button;
        });

    final textFieldWrap = Expanded(
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: const BorderRadius.all(Radius.circular(80)),
        ),
        child: Row(
          children: [
            prefixIcon,
            textFiled,
            clearButton,
          ],
        ),
      ),
    );

    return Row(
      children: [
        const SizedBox(width: 16),
        textFieldWrap,
        TextButton(
          onPressed: () => _close(context),
          child: const Text("取消"),
        ),
      ],
    );
  }
}
