import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/example_bloc.dart';

/// Reference page demonstrating the full BLoC + Clean Architecture pattern.
///
/// Wrap this page with a [BlocProvider] supplying [ExampleBloc] when
/// navigating — see `app_router.dart` for the wiring.
class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example')),
      body: BlocBuilder<ExampleBloc, ExampleState>(
        builder: (context, state) => switch (state) {
          ExampleInitial() => const SizedBox.shrink(),
          ExampleLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
          ExampleLoaded(:final items) => items.isEmpty
              ? const Center(child: Text('No items found.'))
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text(item.id)),
                      title: Text(item.title),
                    );
                  },
                ),
          ExampleError(:final userMessage) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      userMessage,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => context
                          .read<ExampleBloc>()
                          .add(const ExampleRefreshed()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
        },
      ),
    );
  }
}
