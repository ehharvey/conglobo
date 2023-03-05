import 'dart:io';
import 'package:path/path.dart' as path;

class UbuntuIsoRemote {
  static const urlHost = 'releases.ubuntu.com';
  final Uri isoUri;
  final String name;

  UbuntuIsoRemote({String version = '22.04.2'})
  : isoUri = Uri(
    scheme: 'https',
    host: UbuntuIsoRemote.urlHost,
    path: '$version/ubuntu-$version-live-server-amd64.iso'
  ), name = 'ubuntu-$version.iso';
}

class IsoDownloader {
  final Directory storageRoot; 
  final UbuntuIsoRemote remote;
  final File isoPath;

  IsoDownloader(this.storageRoot, this.remote)
  : isoPath = File(path.join(storageRoot.path, 'isos', remote.name));

  // Downloads the ISO if not already saved
  var content_length = 1;
  Future<void> getIso() async {
    var creation = isoPath.create(recursive: true);

    var httpClient = HttpClient();

    await creation;
    var openedIso = isoPath.openWrite();
    await httpClient.getUrl(remote.isoUri)
      .then((HttpClientRequest request) {
        return request.close();
      })
      .then((response) {
        int progress = 0;

        response.listen((contents) {
          progress += contents.length;

          var percentage = progress / response.contentLength;

          print("Progress = $percentage");

          openedIso.write(contents);
         });
      });
    
    print("Download done");
    httpClient.close();
  }
    

  bool validateUserDataYaml() {
    return true;
  }
}
