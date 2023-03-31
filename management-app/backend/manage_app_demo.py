from app_management import AppManager, AppVolume, App, AppContainer
from conglobo_environment import CongloboEnvironment


test_app = App(
    name="testapp",
    # URL is messy right now because it includes regex
    # that nginx can use to rewrite the route strings
    # TODO: Perform this on app-side?
    url_path=r"/testapp(.*)",
    container=AppContainer(image="strm/helloworld-http", volumes=[], port=80),
)

# Initialize an Appmanager
app_manager = AppManager(CongloboEnvironment())

# Add app, deploy
app_manager.activate_app(test_app)

# Print current apps
print(app_manager.config.active_apps)

# Apps can also be retrieved as a Dict[app-name: str, app]
app_dict = app_manager.config.active_apps_dict

# Delete app
app_manager.deactivate_app(name=test_app.name)
