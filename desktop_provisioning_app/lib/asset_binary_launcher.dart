
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart' show rootBundle;

class AssetBinaryLauncher {
    final File binary_path;

    AssetBinaryLauncher(
      Directory dir,
      String exec,
      String assetPath
      )
      : binary_path = File(path.join(dir.path, exec)) {
      
      binary_path.createSync(recursive: true);
      // Check if 
    }


}