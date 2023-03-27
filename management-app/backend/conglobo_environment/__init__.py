import os
from pathlib import Path
from typing import Any, Optional
from pydantic import BaseModel, PositiveInt


class CongloboEnvironment(BaseModel):
    persistent_storage: Path = Path("/persistent-storage")
    config_directory: Path = Path("/config")
    port: PositiveInt = 80
    ingress_name: str = "nginx"
    namespace_name: str = "default"
    kube_config_path: Optional[Path] = None

    class Config:
        allow_mutation = False


def getOsConfig() -> CongloboEnvironment:
    return CongloboEnvironment(**os.environ)
