from conglobo_environment import CongloboEnvironment
from app_management.app_manager_config import AppManagerConfig
from app_management.app import App

from kubernetes import client, config


class AppAlreadyExists(Exception):
    """Exception thrown when App already exists"""


class AppDoesNotExist(Exception):
    """Exception thrown when App does not exist"""


class AppManager:
    def __init__(self, conglobo_environment: CongloboEnvironment):
        if conglobo_environment.kube_config_path:
            config.load_kube_config(conglobo_environment.kube_config_path)
        else:
            config.load_config()

        network_api = client.NetworkingV1Api()
        apps_api = client.AppsV1Api()
        core_api = client.CoreV1Api()

        self.config = AppManagerConfig(
            config=conglobo_environment,
            network_api=network_api,
            apps_api=apps_api,
            core_api=core_api,
        )

    def add_app(self, app: App):
        if app.name in self.config.apps:
            raise AppAlreadyExists

        # Get deployment
        deployment = app.deployment

        # Get service
        service = app.service

        # Get ingress path
        ingress_path = app.http_ingress_path

        # Add deployment and service
        self.config.core_api.create_namespaced_service(
            namespace=self.config.config.namespace_name, body=service
        )

        self.config.apps_api.create_namespaced_deployment(
            namespace=self.config.config.namespace_name, body=deployment
        )

        # Patch ingress to to include service in path
        existing_ingress = self.config.ingress

        new_paths = self.config.current_paths + [ingress_path]

        existing_ingress.spec.rules[0].http.paths = new_paths

        self.config.network_api.replace_namespaced_ingress(
            name=existing_ingress.metadata.name,
            namespace=self.config.config.namespace_name,
            body=existing_ingress,
        )

    def delete_app(self, name: str):
        current_apps_dict = self.config.apps_dict

        if name not in current_apps_dict:
            raise AppDoesNotExist

        app = current_apps_dict[name]

        # Remove path from Ingress
        ingress = self.config.ingress

        current_paths_dict = self.config.current_paths_dict
        current_paths_dict.pop(app.name)
        new_paths = list(current_paths_dict.values())

        ingress.spec.rules[0].http.paths = new_paths

        self.config.network_api.replace_namespaced_ingress(
            name=ingress.metadata.name,
            namespace=self.config.config.namespace_name,
            body=ingress,
        )

        # Remove Service
        self.config.core_api.delete_namespaced_service(
            name=app.name, namespace=self.config.config.namespace_name
        )

        # Remove Deployment
        self.config.apps_api.delete_namespaced_deployment(
            name=app.name, namespace=self.config.config.namespace_name
        )
