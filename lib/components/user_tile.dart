import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String title;
  final String time;
  final String subTitle;
  final void Function()? onTap;
  const UserTile(
      {super.key,
      required this.title,
      required this.onTap,
      required this.time,
      required this.subTitle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // icon
                CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    radius: 25,
                    child: const Icon(Icons.person)),
                const SizedBox(
                  width: 20,
                ),

                // username
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      subTitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    )
                  ],
                )
              ],
            ),
            Column(
              children: [
                Text(
                  time,
                  style:
                      const TextStyle(color: Colors.greenAccent, fontSize: 12),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
