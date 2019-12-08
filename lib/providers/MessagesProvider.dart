///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-08 10:52
///
import 'package:flutter/material.dart';

import 'package:OpenJMU/constants/Constants.dart';

class MessagesProvider with ChangeNotifier {
  Map<int, List> _appsMessages;
//  Map<int, List> _personalMessages;

  Map<int, List> get appsMessages => _appsMessages;
//  Map<int, List> get personalMessages => _personalMessages;

  int get unreadCount => appsMessages.values.fold(
      0,
      (initialValue, list) =>
          initialValue +
          list
              .cast<AppMessage>()
              .fold(0, (init, message) => init + (message.read ? 0 : 1)));

  bool get hasMessages => _appsMessages.isNotEmpty
//          || _personalMessages[currentUser.uid].isNotEmpty
      ;

  void initMessages() {
    final appBox = HiveBoxes.appMessagesBox;
//    final personalBox = HiveBoxes.personalMessagesBox;

    if (!appBox.containsKey(currentUser.uid)) {
      appBox.put(currentUser.uid, Map<int, List>());
    }
//    if (!personalBox.containsKey(currentUser.uid)) {
//      personalBox.put(currentUser.uid, Map<int, List>());
//    }

    var _tempAppsMessages = appBox.get(currentUser.uid);
    _appsMessages = _tempAppsMessages.cast<int, List>();
//    var _tempPersonalMessages = personalBox.get(currentUser.uid);
//    _personalMessages = _tempPersonalMessages.cast<int, List>();
  }

  void logout() {
    _appsMessages = null;
//    _personalMessages = null;
  }

  void initListener() {
    MessageUtils.messageListeners.add(incomingMessage);
  }

  void incomingMessage(MessageReceivedEvent event) {
    if (event.senderUid == 0) {
      _incomingAppsMessage(event);
    } else {
      _incomingPersonalMessage(event);
    }
  }

  void _incomingAppsMessage(MessageReceivedEvent event) {
    final message = AppMessage.fromEvent(event);
    if (!_appsMessages.containsKey(message.appId)) {
      _appsMessages[message.appId] = <AppMessage>[];
    }
    _appsMessages[message.appId].insert(0, message);
    final tempMessages = List.from(_appsMessages[message.appId]);
    _appsMessages.remove(message.appId);
    _appsMessages[message.appId] = List.from(tempMessages);
    saveAppsMessages();
    notifyListeners();
  }

  void _incomingPersonalMessage(MessageReceivedEvent event) {
//    final message = Message.fromEvent(event);
//    if (!_personalMessages.containsKey(event.senderUid)) {
//      _personalMessages[event.senderUid] = <Message>[];
//    }
//    if (message.content['content'] != Messages.inputting) {
//      _personalMessages[event.senderUid].insert(0, message);
//      HiveBoxes.personalMessagesBox.put(currentUser.uid, _personalMessages);
//      notifyListeners();
//    }
  }

//  void reduceUnreadMessageCount(int appId) {
//    int count = appMessagesUnreadCount[appId];
//    if (count != null) {
//      if (count > 0) {
//        count--;
//      }
//    } else {
//      count = 0;
//    }
//  }

  void deleteFromAppsMessages(int appId) {
    _appsMessages.remove(appId);
    saveAppsMessages();
    notifyListeners();
  }

  void saveAppsMessages() {
    HiveBoxes.appMessagesBox.put(currentUser.uid, Map.from(_appsMessages));
  }

//  void savePersonalMessage() {
//    HiveBoxes.personalMessagesBox.put(currentUser.uid, _personalMessages);
//  }
}
