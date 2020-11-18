import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

void main() {
  NetworkManager manager;
  String tempResponse = "";

  setUp(() {
    var config = NetworkConfig(
        baseUrl: "https://jsonplaceholder.typicode.com/",
        fileManager: LocalFile());
    var learning = PlaceHolderLearning();
    manager = NetworkManager(
      config: config,
      learning: learning,
    );
    PathProviderPlatform.instance = MockPathProviderPlatform();
  });

  test('get users', () async {
    SharedPreferences.setMockInitialValues({}); //set values here
    SharedPreferences pref = await SharedPreferences.getInstance();

    final response = await manager.get<User>("users",
        responseType: User(), duration: Duration(minutes: 1));
    Logger().i(pref.getString(
        "https://jsonplaceholder.typicode.com/users-MethodType.GET"));
    await Future.delayed(Duration(seconds: 2));
    final response2 = await manager.get("users", responseType: User());

    expect(response != null, true);
  });
}
