import re
from pydantic import BaseModel
from kubernetes import client
from pathlib import Path


class AppVolume(BaseModel):
    mount_path: Path
    storage: str

    @property
    def pvc_name(self) -> str:
        return re.sub("[^0-9a-zA-Z]+", "-", str(self.mount_path)).strip("-")

    @property
    def persistent_volume_claim(self) -> client.V1PersistentVolumeClaim:
        return client.V1PersistentVolumeClaim(
            api_version="V1",
            kind="PersistentVolumeClaim",
            metadata=client.V1ObjectMeta(name=self.pvc_name),
            spec=client.V1PersistentVolumeClaimSpec(
                access_modes=["ReadWriteOnce"],
                resources=client.V1ResourceRequirements(
                    requests={"storage": self.storage}
                ),
            ),
        )

    @property
    def volume(self) -> client.V1Volume:
        return client.V1Volume(
            name=self.pvc_name,
            persistent_volume_claim=client.V1PersistentVolumeClaimVolumeSource(
                claim_name=self.pvc_name
            ),
        )

    @property
    def volume_mount(self) -> client.V1VolumeMount:
        return client.V1VolumeMount(name=self.pvc_name, mount_path=str(self.mount_path))
