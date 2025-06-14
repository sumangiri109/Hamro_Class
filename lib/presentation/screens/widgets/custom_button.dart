import 'package:hamro_project/constant/const.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Size fixedSize;

  final BorderRadiusGeometry borderRadius;
  final String text;
  final TextStyle textStyle;

  const CustomElevatedButton({
    super.key,
    this.onPressed,
    this.backgroundColor = Colors.green, // Default button color
    this.fixedSize = const Size(
      175,
      50,
    ), // Default button size (use raw values)
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    this.text = "Button", // Default text
    this.textStyle = const TextStyle(
      // Default text style
      fontFamily: lexendRegular,
      color: white,
      fontSize: 20,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        fixedSize: Size(fixedSize.width, fixedSize.height),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
      ),
      child: Text(text, style: textStyle.copyWith(fontSize: 17)),
    );
  }
}
