///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-03-09 19:26
///
import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

class SignProvider extends ChangeNotifier {
  bool _isSigning = false;

  bool get isSigning => _isSigning;

  set isSigning(bool value) {
    assert(value != null);
    if (value == _isSigning) {
      return;
    }
    _isSigning = value;
    notifyListeners();
  }

  bool _hasSigned = false;

  bool get hasSigned => _hasSigned;

  set hasSigned(bool value) {
    assert(value != null);
    if (value == _hasSigned) {
      return;
    }
    _hasSigned = value;
    notifyListeners();
  }

  int _signedCount = 0;

  int get signedCount => _signedCount;

  set signedCount(int value) {
    assert(value != null);
    if (value == _signedCount) {
      return;
    }
    _signedCount = value;
    notifyListeners();
  }

  /// 获取签到状态
  Future<void> getSignStatus() async {
    try {
      final bool signed = ((await SignAPI.getTodayStatus()).data
              as Map<String, dynamic>)['status'] ==
          1;
      final int count = ((await SignAPI.getSignList()).data
                  as Map<String, dynamic>)['signdata']
              ?.length ??
          0;
      _hasSigned = signed;
      _signedCount = count;
    } catch (e) {
      trueDebugPrint('Failed when fetching sign status: $e');
    } finally {
      notifyListeners();
    }
  }

  /// 请求签到
  Future<void> requestSign() async {
    isSigning = true;
    try {
      await SignAPI.requestSign();
      _hasSigned = true;
      _signedCount++;
    } catch (e) {
      trueDebugPrint('Failed when requesting sign: $e');
    } finally {
      _isSigning = false;
      notifyListeners();
    }
  }

  /// 重置签到状态
  void resetSignStatus() {
    _isSigning = false;
    _hasSigned = false;
    _signedCount = 0;
    notifyListeners();
  }
}
