import 'package:hamro_project/constant/const.dart';

class WidgetTest extends StatefulWidget {
  const WidgetTest({super.key});

  @override
  State<WidgetTest> createState() => _WidgetTestState();
}

class _WidgetTestState extends State<WidgetTest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  loginMessage, //  fetched from constant (strings)
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: lexendBold, //  fetched from constant (fonts)
                    color: black, //  fetched from constant (color)
                  ),
                ),
                const SizedBox(height: 20),
                Image.asset(
                  saugat2, //  fetched from constant (image)
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
