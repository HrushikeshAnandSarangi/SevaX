import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

class CommunityCard extends StatelessWidget {
  const CommunityCard({
    Key? key,
    required this.name,
    required this.memberCount,
    required this.imageUrl,
    required this.buttonLabel,
    required this.buttonColor,
    required this.textColor,
    required this.onbuttonPress,
    required this.memberIds,
  });

  final String name;
  final String memberCount;
  final String imageUrl;
  final String buttonLabel;
  final Color buttonColor;
  final Color textColor;
  final VoidCallback onbuttonPress;
  final List<String> memberIds;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                height: 80,
                width: 80,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 80,
                    width: 80,
                    color: Colors.grey[300],
                    child: Icon(Icons.error_outline, color: Colors.grey[600]),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 80,
                    width: 80,
                    color: Colors.grey[200],
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${memberCount} ${S.of(context).members}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                  // You can uncomment and use the member image stack here if needed
                ],
              ),
            ),
            SizedBox(width: 16),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 120),
              child: CustomElevatedButton(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  buttonLabel,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: textColor),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                onPressed: onbuttonPress,
                color: buttonColor,
                textColor: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
