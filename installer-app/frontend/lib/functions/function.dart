import 'dart:io';

void modifyGrub(String path) {
  final configFile = File('$path/boot/grub/grub.cfg');

  if (!configFile.existsSync()) {
    configFile.createSync(recursive: true);
  }

  configFile.writeAsStringSync('set timeout=30\n\n'
      'loadfont unicode\n\n'
      'set menu_color_normal=white/black\n'
      'set menu_color_highlight=black/light-gray\n'
      'menuentry "Autoinstall Ubuntu Server" {\n'
      '   set gfxpayload=keep\n'
      '   linux	/casper/vmlinuz	autoinstall	ds=nocloud\\;s=/cdrom/nocloud/	---\n'
      '   initrd	/casper/initrd\n'
      '}\n');
}
