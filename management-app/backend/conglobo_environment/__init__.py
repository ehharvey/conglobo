import os
from pathlib import Path
from typing import Any, Optional
from pydantic import BaseModel, PositiveInt


class CongloboEnvironment(BaseModel):
    config_directory: Path = "/config"
    port: PositiveInt = 8000
    ingress_name: str = "nginx"
    namespace_name: str = "default"
    ingress_hostname: str = "desktop-ubuntu.tail6d37c.ts.net"
    kube_config_path: Optional[Path] = "~/.kube/config.yaml"

    class Config:
        allow_mutation = False


def getOsConfig() -> CongloboEnvironment:
    return CongloboEnvironment(**os.environ)
