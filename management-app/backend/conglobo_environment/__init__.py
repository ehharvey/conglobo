import os
from pathlib import Path
from typing import Any, List, Optional
from app_management.app_definition import AppDefinition
from pydantic import BaseModel, PositiveInt, ValidationError
import yaml


class CongloboEnvironment(BaseModel):
    persistent_storage: Path = Path("/persistent-storage")
    config_directory: Path = Path("/config")
    port: PositiveInt = 80
    ingress_name: str = "nginx"
    namespace_name: str = "default"
    kube_config_path: Optional[Path] = None

    @property
    def app_configs(self) -> List[AppDefinition]:
        config = yaml.safe_load(
            self.config_directory.joinpath("app_configs.yaml").read_text()
        )
        try:
            return [AppDefinition(**y) for y in config["apps"]]
        except ValidationError as e:
            raise Exception(f"Could not load app configs: {e}")
        except:
            raise Exception(f"Could not load app configs: {config}")

    class Config:
        allow_mutation = False


def getOsConfig() -> CongloboEnvironment:
    return CongloboEnvironment(**os.environ)
