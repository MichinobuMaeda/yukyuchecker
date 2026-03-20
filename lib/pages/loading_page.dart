import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        // ignore: deprecated_member_use
        year2023: false,
        color: Theme.of(context).colorScheme.primary,
        constraints: const BoxConstraints(minWidth: 128, minHeight: 128),
      ),
    );
  }
}
