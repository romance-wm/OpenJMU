///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-07 11:14
///
import 'dart:math' as math;

import 'package:OpenJMU/pages/SearchPage.dart';
import 'package:OpenJMU/pages/user/UserPage.dart';
import 'package:OpenJMU/widgets/CommonWebPage.dart';
import 'package:extended_text/extended_text.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:OpenJMU/constants/Constants.dart';

class ChatPersonPage extends StatefulWidget {
  @override
  _ChatPersonPageState createState() => _ChatPersonPageState();
}

class _ChatPersonPageState extends State<ChatPersonPage> {
  final _textEditingController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  final topBarHeight = Constants.suSetSp(100.0);
  final color = ThemeUtils.currentThemeColor;

  List<Message> messages = [];
  bool shrinkWrap = true;
  bool emoticonPadActive = false;
  int uid = 164466;
  double _keyboardHeight = EmotionPadState.emoticonPadDefaultHeight;
  String pendingMessage = "";

  @override
  void initState() {
    Instances.eventBus
      ..on<MessageReceivedEvent>().listen((event) {
        if (event.senderUid == uid ||
            event.senderUid == UserAPI.currentUser.uid) {
          final message = Message.fromEvent(event);
          if (message.content['content'] != Messages.inputting) {
            messages.insert(0, Message.fromEvent(event));
            if (mounted) setState(() {});
          }
        }
      });
    _textEditingController.addListener(() {
      pendingMessage = _textEditingController.text;
      if (mounted) setState(() {});
    });
    super.initState();
  }

  Widget get topBar => Container(
        height: Screen.topSafeHeight + topBarHeight,
        padding: EdgeInsets.only(
          top: Screen.topSafeHeight + Constants.suSetSp(4.0),
          bottom: Constants.suSetSp(4.0),
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).canvasColor,
              width: Constants.suSetSp(1.5),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            BackButton(),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                UserAPI.getAvatar(size: 50.0, uid: 164466),
                Text(
                  "陈嘉旺",
                  style: Theme.of(context).textTheme.body1.copyWith(
                        fontSize: Constants.suSetSp(19.0),
                        fontWeight: FontWeight.w500,
                      ),
                )
              ],
            ),
            BackButton(color: Colors.transparent),
          ],
        ),
      );

  Widget get emoticonPadButton => MaterialButton(
        padding: EdgeInsets.zero,
        elevation: 0.0,
        highlightElevation: 2.0,
        minWidth: Constants.suSetSp(68.0),
        height: Constants.suSetSp(52.0),
        color: emoticonPadActive ? color : Colors.grey[400],
        child: Center(
          child: Image.asset(
            "assets/emotionIcons/憨笑.png",
            width: Constants.suSetSp(32.0),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Constants.suSetSp(30.0)),
        ),
        onPressed: updatePadStatus,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );

  Widget get sendButton => MaterialButton(
        padding: EdgeInsets.zero,
        elevation: 0.0,
        highlightElevation: 2.0,
        minWidth: Constants.suSetSp(68.0),
        height: Constants.suSetSp(52.0),
        color: color,
        disabledColor: Colors.grey[400],
        child: Center(
          child: Icon(
            Icons.send,
            color: Colors.white,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Constants.suSetSp(30.0)),
        ),
        onPressed: pendingMessage.trim().isNotEmpty ? sendMessage : null,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );

  Widget get messageTextField => Expanded(
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: Constants.suSetSp(8.0),
          ),
          constraints: BoxConstraints(
            minHeight: Constants.suSetSp(52.0),
            maxHeight: Constants.suSetSp(140.0),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              Constants.suSetSp(30.0),
            ),
            color: Theme.of(context).primaryColor,
          ),
          padding: EdgeInsets.all(Constants.suSetSp(14.0)),
          child: ExtendedTextField(
            specialTextSpanBuilder: StackSpecialTextFieldSpanBuilder(),
            controller: _textEditingController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: "Say something...",
              hintStyle: TextStyle(
                textBaseline: TextBaseline.alphabetic,
                fontStyle: FontStyle.italic,
              ),
            ),
            style: Theme.of(context).textTheme.body1.copyWith(
                  fontSize: Constants.suSetSp(20.0),
                  textBaseline: TextBaseline.alphabetic,
                ),
            maxLines: null,
            textInputAction: TextInputAction.unspecified,
          ),
        ),
      );

  Widget get bottomBar => Theme(
        data: Theme.of(context).copyWith(
          splashFactory: InkSplash.splashFactory,
        ),
        child: Container(
          padding: EdgeInsets.only(
            bottom: !emoticonPadActive
                ? MediaQuery.of(context).padding.bottom
                : 0.0,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
          ),
          child: Padding(
            padding: EdgeInsets.all(Constants.suSetSp(10.0)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                emoticonPadButton,
                messageTextField,
                sendButton,
              ],
            ),
          ),
        ),
      );

  Widget get messageList => Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Flexible(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                controller: _scrollController,
                shrinkWrap: shrinkWrap,
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (_, i) => messageWidget(messages[i]),
              ),
            ),
          ],
        ),
      );

  Widget messageWidget(Message message) {
    final end = (message.content['content'] as String).indexOf('&<img>');
    return Container(
      margin: EdgeInsets.only(
        left: message.isSelf ? 60.0 : 8.0,
        right: message.isSelf ? 8.0 : 60.0,
        top: 8.0,
        bottom: 8.0,
      ),
      width: Screen.width,
      child: Align(
        alignment:
            message.isSelf ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Constants.suSetSp(16.0),
            vertical: Constants.suSetSp(10.0),
          ),
          constraints: BoxConstraints(
            minHeight: Constants.suSetSp(30.0),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: message.isSelf
                ? color.withOpacity(0.5)
                : Theme.of(context).canvasColor,
          ),
          child: ExtendedText(
            end == -1
                ? "${(message.content['content'] as String)}"
                : "${(message.content['content'] as String).substring(
              0,
              (message.content['content'] as String).indexOf('&<img>'),
            )}",
            style: TextStyle(
              fontSize: Constants.suSetSp(19.0),
            ),
            onSpecialTextTap: (dynamic data) {
              String text = data['content'];
              if (text.startsWith("#")) {
                SearchPage.search(context, text.substring(1, text.length - 1));
              } else if (text.startsWith("@")) {
                UserPage.jump(data['uid']);
              } else if (text.startsWith(API.wbHost)) {
                CommonWebPage.jump(text, "网页链接");
              }
            },
            specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
          ),
        ),
      ),
    );
  }

  Widget get emoticonPad => Visibility(
        visible: emoticonPadActive,
        child: EmotionPad(
          route: "message",
          height: _keyboardHeight,
          controller: _textEditingController,
        ),
      );

  void judgeShrink(context) {
    if (_scrollController.hasClients) {
      final maxExtent = _scrollController.position.maxScrollExtent;
      final limitExtent = 50.0;
      if (maxExtent > limitExtent && shrinkWrap) {
        shrinkWrap = false;
      } else if (maxExtent <= limitExtent && !shrinkWrap) {
        shrinkWrap = true;
      }
    }
  }

  void sendMessage() {
    MessageUtils.sendTextMessage(pendingMessage, uid);
    _textEditingController.clear();
    pendingMessage = "";
    if (mounted) setState(() {});
  }

  void updatePadStatus() {
    final change = () {
      emoticonPadActive = !emoticonPadActive;
      if (mounted) setState(() {});
    };
    if (emoticonPadActive) {
      change();
    } else {
      if (MediaQuery.of(context).viewInsets.bottom != 0.0) {
        SystemChannels.textInput.invokeMethod('TextInput.hide').whenComplete(
          () async {
            Future.delayed(const Duration(milliseconds: 300), () {})
                .whenComplete(change);
          },
        );
      } else {
        change();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    judgeShrink(context);
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    if (keyboardHeight > 0) {
      emoticonPadActive = false;
    }
    _keyboardHeight = math.max(_keyboardHeight, keyboardHeight);

    return Scaffold(
      body: Column(
        children: <Widget>[
          topBar,
          messageList,
          bottomBar,
          emoticonPad,
        ],
      ),
    );
  }
}
