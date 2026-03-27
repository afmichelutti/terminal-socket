import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    Key? key,
    required this.title,
    this.onPressed,
  }) : super(key: key);
  final String title;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        // if (onPressed != null)
        //   TextButton(
        //     onPressed: onPressed,
        //     child: const Text(
        //       'Ver todos',
        //       style: TextStyle(color: Colors.black54),
        //     ),
        //   ),
      ],
    );
  }
}
