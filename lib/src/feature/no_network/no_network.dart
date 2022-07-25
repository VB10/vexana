import 'package:flutter/material.dart';

class NoNetwork {
  final BuildContext context;
  final Widget Function(void Function()? onRetry)? customNoNetwork;
  NoNetwork(this.context, {this.customNoNetwork});
}
