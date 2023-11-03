import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:vexana/src/feature/path/io_path_provider.dart'
    if (dart.library.html) '../../feature/path/html_path_provider.dart' as customPath;
import 'package:vexana/src/interface/i_file_manager.dart';
import 'package:vexana/src/model/local_data.dart';

part 'sembast.dart';

class LocalSembast extends IFileManager {
  final _SembastManager _sembastManager = _SembastManager.instance;

  @override
  Future<String?> getUserRequestDataOnString(String key) {
    return _sembastManager.readOnlyKeyData(key);
  }

  @override
  Future<bool> writeUserRequestDataWithTime(String key, String model, Duration? time) async {
    if (time == null) {
      return false;
    } else {
      final localModel = LocalModel(model: model, time: DateTime.now().add(time));
      await _sembastManager.writeLocalModelInStore(key, localModel);
      return true;
    }
  }

  @override
  Future<bool> removeUserRequestCache(String key) async {
    await _sembastManager.clearAllStoreItems();
    return true;
  }

  @override
  Future<bool> removeUserRequestSingleCache(String key) async {
    await _sembastManager.removeSingleItem(key);
    return true;
  }
}
