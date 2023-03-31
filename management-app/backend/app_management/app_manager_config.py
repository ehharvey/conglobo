from dataclasses import dataclass
from typing import Dict, List

from app_management.app_volume import AppVolume
from app_management.app_container import AppContainer

from app_management.app import App
from conglobo_environment import CongloboEnvironment
from kubernetes import client


@dataclass
class AppManagerConfig:
    config: CongloboEnvironment
    network_api: client.NetworkingV1Api
    apps_api: client.AppsV1Api
    core_api: client.CoreV1Api

    @property
    def ingress(self) -> client.V1Ingress:
        return self.network_api.read_namespaced_ingress(
            name=self.config.ingress_name,
            namespace=self.config.namespace_name,
        )

    @property
    def current_paths(self) -> List[client.V1HTTPIngressPath]:
        spec: client.V1IngressSpec = self.ingress.spec
        rules: List[client.V1IngressRule] = spec.rules

        rule_result: client.V1IngressRule = rules[0]
        http_result: client.V1HTTPIngressRuleValue = rule_result.http
        paths_result: List[client.V1HTTPIngressPath] = http_result.paths

        return paths_result

    @property
    def current_paths_dict(self) -> Dict[str, client.V1HTTPIngressPath]:
        return {cp.backend.service.name: cp for cp in self.current_paths}

    @property
    def active_apps(self) -> List[App]:
        result = []

        for hip in self.current_paths:
            url_path = hip.path
            name = hip.backend.service.name
            port = hip.backend.service.port.number

            deployment: client.V1Deployment = self.apps_api.read_namespaced_deployment(
                name=name, namespace=self.config.namespace_name
            )

            replicas = deployment.spec.replicas

            pvcs: Dict[str, client.V1PersistentVolumeClaim] = (
                {
                    v.name: self.core_api.read_namespaced_persistent_volume_claim(
                        name=v.name, namespace=self.config.namespace_name
                    )
                    for v in deployment.spec.template.spec.volumes
                    if v.persistent_volume_claim
                }
                if deployment.spec.template.spec.volumes
                else {}
            )

            v1_containers: List[client.V1Container] = [
                c for c in deployment.spec.template.spec.containers
            ]

            if len(v1_containers) != 1 or "conglobo" in name:
                continue

            app_container = AppContainer(
                image=v1_containers[0].image,
                volumes=[
                    AppVolume(
                        mount_path=vm.mount_path,
                        storage=pvcs[vm.name].spec.resources.requests["storage"],
                    )
                    for vm in v1_containers[0].volume_mounts
                    if vm.name in pvcs
                ]
                if pvcs
                else [],
                port=port,
            )

            result.append(
                App(
                    name=name,
                    url_path=url_path,
                    container=app_container,
                    replicas=replicas,
                    active=True,
                )
            )

        return result

    @property
    def active_apps_dict(self) -> Dict[str, App]:
        return {a.name: a for a in self.active_apps}
