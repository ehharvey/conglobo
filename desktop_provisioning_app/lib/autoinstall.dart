

import 'dart:convert';

const baseConfig = {
    "autoinstall": {
      "version": 1,
      "update": "yes",
      "keyboard": {
        "layout": "us",
        "toggle": null,
        "variant": ""
      },
      "locale": "en_US.UTF-8",
      "identity": {
        "hostname": "node0",
        // password is "password"
        "password": r"$6$rounds=4096$saltsaltlettuce$Lp/FV.2oOgew7GbM6Nr8KMGMBn7iFM0x9ZwLqtx9Y4QJmKvfcnS.2zx4MKmymCPQGpHS7gqYOiqWjvdCIV2uN.",
        "username": "maintenance"
      },
      "ssh": {
        "allow-pw": true,
        "install-server": true
      },
      "snaps": [
        {
          "name": "microk8s",
          "channel": "1.26/stable",
          "classic": true
        }
      ],
      "user-data": {
        "disable_root": true,
        "users": [
          {
            "name": "maintenance",
            "groups": "users, admin, docker, sudo",
            "sudo": "ALL=(ALL) NOPASSWD:ALL",
            "shell": "/bin/bash",
            "lock_passwd": true,
            "passwd": r"$6$rounds=4096$saltsaltlettuce$Lp/FV.2oOgew7GbM6Nr8KMGMBn7iFM0x9ZwLqtx9Y4QJmKvfcnS.2zx4MKmymCPQGpHS7gqYOiqWjvdCIV2uN."
          }
        ]
      }
    }
  };

class AutoInstallConfig {
  String getConfig(
    List<String> packages,

    ) {
    var config = Map<String, Object>.from(baseConfig);



    return 
'''
#cloud-config
$jsonEncode(config)
''';
  }
}