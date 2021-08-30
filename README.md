# vexana

Vexana is easy to use network proccess with dio. You can do dynamic model parsing, base error model, timeout and many utility functions.

![Vexana-Game](https://thumbs.gfycat.com/RightSoupyCrow-size_restricted.gif)

## Getting Started 🔥

Let's talk about usage details.

### **Network Manager** 😎

Have a lot of options: baseurl, logger, interceptors, base model etc.

```dart
INetworkManager  networkManager = NetworkManager(isEnableLogger: true, errorModel: UserErrorModel(),
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

### **Network Model** 🛒

You must wrap your model with INetworkModel so that, we understand model has toJson and fromJson methods.

```dart
class Todo extends INetworkModel<Todo>
```

### **Refresh Token** ♻️

Many projects use authentication structure for mobile security (like a jwt). It could need to renew an older token when the token expires. This time provided a refresh token option, we can lock all requests until the token refresh process is complete.

> Since i locked all requests, I am giving a new service instance.

```dart
INetworkManager  networkManager = NetworkManager(isEnableLogger: true, options: BaseOptions(baseUrl: "https://jsonplaceholder.typicode.com/",
onRefreshFail: () {  //Navigate to login },
 onRefreshToken: (error, newService) async {
    <!-- Write your refresh token business -->
    <!-- Then update error.req.headers to new token -->
    return error;
}));
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

### Tasks

---

- [x] Example project
- [x] Unit Test with json place holder
- [x] Unit Test with custom api
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

[![Youtube](https://yt3.ggpht.com/a/AATXAJyul3hpzl86GIjF-EZxBzy6T62PJxpvzRwz9AbUOw=s288-c-k-c0xffffffff-no-rj-mo)](https://www.youtube.com/watch?v=UCdUaAKTLJrPZFStzEJnpQAg)
