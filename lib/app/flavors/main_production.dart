import '../app_config.dart';

void main() async {
  print("main_production app running");
  await FlutterAppConfig(
    environment: AppEnvironment.production
  ).run();
}
