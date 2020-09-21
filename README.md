# vexana

Vexana is easy use network proccess with dio. You can do dynamic model parse, base error model, timeout and many utitliy functions.

![Vexana-Game](https://thumbs.gfycat.com/RightSoupyCrow-size_restricted.gif)

## Getting Started 🔥

Let's talk use detail.

### **Network Manager** 😎

Have a a lot options: baseurl, logger, interceptors, base model etc.

```dart
    INetworkManager  networkManager = NetworkManager(isEnableLogger: true, options: BaseOptions(baseUrl: "https://jsonplaceholder.typicode.com/"));
```

### **Model Parse** ⚔️

You have give to first parse model, second result model. (Result model could be list, model or primitive)

```dart
        final response =
        await networkManager.fetch<Todo, List<Todo>>("/todos", parseModel: Todo(), method: RequestType.GET);

```

### **Network Model** 🛒

You must be wrap model to INetoworkModel so we understand model has a toJson and toFrom properties.

```dart
    class Todo extends INetworkModel<Todo>
```

### Tasks

---

- [ ] Example project
- [x] Unit Test with json place holder
- [x] Unit Test with custom api
- [ ] Make a unit test all layers.
- [ ] Cache Option

## License

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](/LICENSE)

2020 created for @VB10

## Youtube Channel

---

[![Youtube](https://yt3.ggpht.com/a/AATXAJyul3hpzl86GIjF-EZxBzy6T62PJxpvzRwz9AbUOw=s288-c-k-c0xffffffff-no-rj-mo)](https://www.youtube.com/watch?v=UCdUaAKTLJrPZFStzEJnpQAg)
