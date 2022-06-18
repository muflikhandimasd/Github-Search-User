import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app.dart';

// Search Result Item
class SearchResultItem extends StatelessWidget {
  final User user;
  const SearchResultItem({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Image.network(
          user.avatarUrl!,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null &&
                        loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (_, object, stackTrace) => Material(
            borderRadius: BorderRadius.circular(8),
            child: Text(
              'Image not Available',
              style: ThemeFont.defFont.copyWith(fontSize: 12),
            ),
          ),
        ),
      ),
      title: Text(
        user.login!,
        style: ThemeFont.defFont.copyWith(fontSize: 16),
      ),
      onTap: () async {
        final url = Uri.parse(user.htmlUrl!);
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        }
      },
    );
  }
  // Search Result Item
}
