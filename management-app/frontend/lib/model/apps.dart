class AppInfo {
  final String displayName;
  final String name;
  final String displayUrlPath;
  final String description;
  final bool active;

  AppInfo(
      {required this.displayName,
      required this.name,
      required this.displayUrlPath,
      required this.description,
      required this.active});

  factory AppInfo.fromJson(Map<String, dynamic> json) {
    return AppInfo(
      displayName: json['displayName'],
      displayUrlPath: json['displayUrlPath'],
      name: json['name'],
      description: json['description'],
      active: json['active'],
    );
  }
}

class Apps {
  final Map<String, AppInfo> services;

  Apps({required this.services});

  factory Apps.fromJson(List<dynamic> json) {
    print(json);
    final services = Map<String, AppInfo>.fromEntries(
        json.map((entry) => MapEntry(entry['name'], AppInfo.fromJson(entry))));
    return Apps(services: services);
  }
}
