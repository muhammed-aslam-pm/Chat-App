import 'package:flutter/material.dart';

class ConfirmDeletDialog extends StatelessWidget {
  const ConfirmDeletDialog(
      {super.key,
      required this.title,
      required this.buttontext,
      required this.subTitle,
      required this.onPressed});
  final String title;
  final String buttontext;
  final String subTitle;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      title: Text(
        title,
        textAlign: TextAlign.center,
      ),
      content: Text(subTitle),
      actionsAlignment: MainAxisAlignment.center,
      actions: <Widget>[
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.redAccent)),
          onPressed: onPressed,
          child: Text(buttontext),
        ),
      ],
    );
  }
}
