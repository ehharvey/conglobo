class ServiceStatus {
  final bool status;

  ServiceStatus({
    required this.status,
  });

  factory ServiceStatus.fromJson(Map<String, dynamic> json) {
    return ServiceStatus(
      status: json['status'] as bool,
    );
  }
}

class ServiceStatuses {
  final Map<String, ServiceStatus> services;

  ServiceStatuses({
    required this.services,
  });

  factory ServiceStatuses.fromJson(Map<String, dynamic> json) {
    final services = <String, ServiceStatus>{};
    json.forEach((key, value) {
      services[key] = ServiceStatus.fromJson(value as Map<String, dynamic>);
    });
    return ServiceStatuses(services: services);
  }
}
