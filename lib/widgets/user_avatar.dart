import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String photoUrl;
  final double radius;

  const UserAvatar({
    Key? key,
    required this.photoUrl,
    this.radius = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (photoUrl.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: Icon(
          Icons.person,
          size: radius * 1.2,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }
    
    return CircleAvatar(
      radius: radius,
      backgroundImage: NetworkImage(photoUrl),
    );
  }
}
