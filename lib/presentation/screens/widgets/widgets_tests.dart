import 'package:hamro_project/constant/const.dart';
import 'package:hamro_project/presentation/auth/login.dart';
import 'package:hamro_project/presentation/screens/widgets/custom_button.dart';
import 'package:hamro_project/presentation/screens/widgets/customtextbutton.dart';

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

                // Image Example:
                Image.asset(
                  saugat2, //  fetched from constant (image)
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20), //  spacing
                // Custom Eleveted Button call:
                CustomElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const LoginScreen(), // navigate to login screen
                      ),
                    );
                  },
                  text: "Login Page",
                ),
                SizedBox(height: 20),
                Customtextbutton(
                  onPressed: () {},
                  text: "for cr",
                  textStyle: TextStyle(color: Colors.yellow),
                ), // Custom Text Button call
              ],
            ),
          ),
        ),
      ),
    );
  }
}
