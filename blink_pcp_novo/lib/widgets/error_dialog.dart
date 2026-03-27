import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const ErrorDialog({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  static void show(BuildContext context, String message, VoidCallback onRetry) {
    showDialog(
      context: context,
      builder:
          (context) => ErrorDialog(errorMessage: message, onRetry: onRetry),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red),
          SizedBox(width: 8),
          Text('Erro de Conexão'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(errorMessage)],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('FECHAR'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onRetry();
          },
          child: Text('TENTAR NOVAMENTE'),
        ),
      ],
    );
  }
}
