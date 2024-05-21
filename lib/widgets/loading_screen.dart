import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingScreen({
    Key? key,
    required this.isLoading,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black45,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
          ),
      ],
    );
  }
}
