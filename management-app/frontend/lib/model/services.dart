class ServiceInfo {
  final String description;
  final String github;
  final bool status;

  ServiceInfo(
      {required this.description, required this.github, required this.status});

  factory ServiceInfo.fromJson(Map<String, dynamic> json) {
    return ServiceInfo(
      description: json['description'],
      github: json['github'],
      status: json['status'],
    );
  }
}

class Services {
  final Map<String, ServiceInfo> services;

  Services({required this.services});

  factory Services.fromJson(Map<String, dynamic> json) {
    final services = Map<String, ServiceInfo>.fromEntries(json.entries.map(
        (entry) => MapEntry(entry.key,
            ServiceInfo.fromJson(Map<String, dynamic>.from(entry.value)))));
    return Services(services: services);
  }
}
