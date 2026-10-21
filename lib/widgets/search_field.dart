import 'package:flutter/material.dart';

/// A rounded grey search box with a search icon and a clear (✖) button.
class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const SearchField({
    super.key,
    required this.controller,
    required this.onSubmitted,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final roundBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(28),
      borderSide: BorderSide.none,
    );

    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search news...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: ListenableBuilder(
          listenable: controller,
          builder: (context, child) {
            if (controller.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Clear',
              onPressed: onClear,
            );
          },
        ),
        filled: true,
        fillColor: colors.surfaceContainerHigh,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: roundBorder,
        enabledBorder: roundBorder,
        focusedBorder: roundBorder.copyWith(
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
      ),
    );
  }
}