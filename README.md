# vexana

Vexana is easy to use network proccess with dio. You can do dynamic model parsing, base error model, timeout and many utility functions.

![Vexana-Game](https://thumbs.gfycat.com/RightSoupyCrow-size_restricted.gif)

## Getting Started 🔥

Let's talk about usage details.

### **Network Manager** 😎

Have a lot of options: baseurl, logger, interceptors, base model etc.

> If you want to manage your error model, you just declare your model so it's way getting the error model everywhere.

```dart
INetworkManager  networkManager = NetworkManage<Null or UserErrorModel>(isEnableLogger: true, errorModel: UserErrorModel(),
 options: BaseOptions(baseUrl: "https://jsonplaceholder.typicode.com/"));
```

### **Model Parse** ⚔️

First, you have to provide the parse model, then the result model. (Result model could be a list, model or primitive)

```dart
final response =
await networkManager.send<Todo, List<Todo>>("/todos", parseModel: Todo(), method: RequestType.GET);
```

### **Base Headers** 📍

You could be add key values to your every request directly.(add authhentication key)

```dart

networkManager.addBaseHeader(MapEntry(HttpHeaders.authorizationHeader, response.data?.first.title ?? ''));
// Clear singlhe header
networkManager.removeHeader('\${response.data?.first.id}');
// Clear all hader
networkManager.clearHeader();
```

### **Download File** 📍

You can download any file format like pdf, png or etc with progress indicator.

```dart
final response = await networkManager.downloadFileSimple('http://www.africau.edu/images/default/sample.pdf', (count, total) {
      print('${count}');
});

//Example: Image.memory(response.data)
```

### **HTTP Post Request with Request Body** 🚀

The model found in the request body must extend the abstract class INetworkModel, as follows.

```dart
class TodoPostRequestData extends INetworkModel<TodoPostRequestData>
```

Then, since the model will have toJson and fromJson properties, you can create the object and pass it directly to the send method.

> So, it is sufficient to send only the request body object into the send method. You don't need to use toJson.

```dart
final todoPostRequestBody = TodoPostRequestData();
final response =
await networkManager.send<Todo, List<Todo>>("/todosPost", parseModel: Todo(), method: RequestType.POST, data: todoPostRequestBody);
```

### **Cancel Request** ❌

You can implement cancel token when need to invoke your request during to complete.

```dart
  final cancelToken = CancelToken();
    networkManager
        .send<ReqResModel, ReqResModel>('/users?delay=5',
            parseModel: ReqResModel(), method: RequestType.GET, canceltoken: cancelToken)
        .catchError((err) {
      if (CancelToken.isCancel(err)) {
        print('Request canceled! ' + err.message);
      }
    });

    cancelToken.cancel('canceled');

    await Future.delayed(const Duration(seconds: 8));
```

### **Primitive Request** 🌼

Sometimes we need to parse only primitive types for instance List<String>, String, int etc. You can use this method.

```dart
//
[
  "en",
  "tr",
  "fr"
]
//
networkManager.sendPrimitive<List>("languages");
```

### **Network Model** 🛒

You must wrap your model with INetworkModel so that, we understand model has toJson and fromJson methods.

```dart
class Todo extends INetworkModel<Todo>
```

### **Refresh Token** ♻️

Many projects use authentication structure for mobile security (like a jwt). It could need to renew an older token when the token expires. This time provided a refresh token option, we can lock all requests until the token refresh process is complete.

> Since i locked all requests, I am giving a new service instance.

```dart
INetworkManager  networkManager = NetworkManager(isEnableLogger: true, options: BaseOptions(baseUrl: "https://jsonplaceholder.typicode.com/"),
onRefreshFail: () {  //Navigate to login },
 onRefreshToken: (error, newService) async {
    <!-- Write your refresh token business -->
    <!-- Then update error.req.headers to new token -->
    return error;
});
```

### **Caching** 🧲

You need to write a response model in the mobile device cache sometimes. It's here now. You can say expiration date and lay back 🙏

```dart
    await networkManager.send<Todo, List<Todo>>("/todos",
        parseModel: Todo(),
        expiration: Duration(seconds: 3),
        method: RequestType.GET);
```

> You must declare a caching type. It has FileCache and SharedCache options now. `NetworkManager(fileManager: LocalFile());`
> If you want more implementation details about the cache, you should read [this article](https://medium.com/flutter-community/cache-manager-with-flutter-5a5db0d3a3e6)

### **Without Network connection** 🧲

Especially, mobile device many times lost connection for many reasons so if you want to retry your request, you need to add this code and that's it. Your app user can be show bottom sheet dialog and they will be use this features only tree times because i added this rule.

```dart
    // First you must be initialize your context with NoNetwork class
    networkManager = NetworkManager(
      isEnableLogger: true,
      noNetwork: NoNetwork(context),
      options: BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com'),

      errorModelFromData: _errorModelFromData, //This is optional.
    );

    // If you want to create custom widget, you can add in no network class with callback function.
      networkManager = NetworkManager(
      isEnableLogger: true,
      noNetwork: NoNetwork(
        context,
        customNoNetwork: (onRetry) {
          // You have to call this retry method your custom widget
          return NoNetworkSample(onPressed: onRetry);
        },
      ),
      options: BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com'),

      //Example request
       final response = await networkManager.send<Post, List<Post>>('/posts',
        parseModel: Post(), method: RequestType.GET, isErrorDialog: true);
```

**And result!!**

![alt](https://github.com/VB10/vexana/blob/master/github/Simulator%20Screen%20Recording%20-%20iPhone%2011%20-%202022-07-21%20at%2012.00.41.gif?raw=true)

### **Error model handle** ❎

This point so important for many apps. Some business operation want to show any message or logic when user did a mistake like wrong password etc. You can manage very easily to error model for whole project with this usage.

```dart
INetworkManager  networkManager = NetworkManage<UserErrorModel>(isEnableLogger: true, errorModel: UserErrorModel(),
 options: BaseOptions(baseUrl: "https://jsonplaceholder.typicode.com/"));

 IResponseModel<List<Post>?, BaseErrorModel?> response =  networkManager.send<Post, List<Post>>('/posts',
        parseModel: Post(), method: RequestType.GET);
      <!-- Error.model came from your backend with your declaration -->
      showDialog(response.error?.model?.message)

    response
```

### Tasks

---

- [x] Example project
- [x] Unit Test with json place holder
- [x] Unit Test with custom api
- [x] Handle network problem
- [ ] Make a unit test all layers.
- [x] Cache Option
  - [ ] SQlite Support
  - [ ] Web Cache Support
- [x] Refresh Token Architecture
- [ ] Usage Utility

## License

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](/LICENSE)

2020 created for @VB10

## Youtube Channel

---

[![Youtube](https://yt3.ggpht.com/a/AATXAJyul3hpzl86GIjF-EZxBzy6T62PJxpvzRwz9AbUOw=s288-c-k-c0xffffffff-no-rj-mo)](https://www.youtube.com/c/HardwareAndro)
