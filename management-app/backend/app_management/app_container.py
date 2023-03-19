from typing import List
from pydantic import BaseModel
from app_management.app_volume import AppVolume

from kubernetes import client


class AppContainer(BaseModel):
    image: str
    volumes: List[AppVolume]
    port: int = 80
