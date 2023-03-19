from typing import List
from pydantic import BaseModel
from pathlib import Path

from kubernetes import client
from app_management.app_volume import AppVolume
from app_management.app_container import AppContainer


class App(BaseModel):
    name: str
    url_path: Path
    container: AppContainer
    replicas: int = 1

    @property
    def http_ingress_path(self) -> client.V1HTTPIngressPath:
        return client.V1HTTPIngressPath(
            path_type="Prefix",
            path=str(self.url_path),
            backend=client.V1IngressBackend(
                service=client.V1IngressServiceBackend(
                    name=self.name,
                    port=client.V1ServiceBackendPort(number=self.container.port),
                )
            ),
        )

    @property
    def deployment(self) -> client.V1Deployment:
        return client.V1Deployment(
            api_version="apps/v1",
            kind="Deployment",
            metadata=client.V1ObjectMeta(labels={"app": self.name}, name=self.name),
            spec=client.V1DeploymentSpec(
                selector=client.V1LabelSelector(match_labels={"app": self.name}),
                replicas=self.replicas,
                template=client.V1PodTemplateSpec(
                    metadata=client.V1ObjectMeta(labels={"app": self.name}),
                    spec=client.V1PodSpec(
                        volumes=[v.volume for v in self.container.volumes],
                        containers=[
                            client.V1Container(
                                image=self.container.image,
                                image_pull_policy="Always",
                                name=self.name,
                                volume_mounts=[
                                    v.volume_mount for v in self.container.volumes
                                ],
                            )
                        ],
                    ),
                ),
            ),
        )

    @property
    def service(self) -> client.V1Service:
        return (
            client.V1Service(
                api_version="v1",
                kind="Service",
                metadata=client.V1ObjectMeta(name=self.name),
                spec=client.V1ServiceSpec(
                    ports=[
                        client.V1ServicePort(port=80, target_port=self.container.port)
                    ],
                    selector={"app": self.name},
                ),
            ),
        )[0]
