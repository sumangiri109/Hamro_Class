import 'package:hamro_project/constant/const.dart';

class Customtextbutton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final Color color;
  final TextStyle textStyle;

  const Customtextbutton({
    super.key,
    required this.onPressed,
    required this.text,
    this.color = Colors.red,
    this.textStyle = const TextStyle(
      // Default text style
      fontFamily: lexendRegular,
      color: white,
      fontSize: 20,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text, style: textStyle.copyWith(fontSize: 17)),
    );
  }
}
