import 'package:flutter/material.dart';
import 'signup_screen.dart';
import '../../../dashboard/presentation/pages/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 10),

              /// Title
              RichText(
                text: const TextSpan(
                  text: "Welcome To ",
                  style: TextStyle(color: Colors.white, fontSize: 28),
                  children: [
                    TextSpan(
                      text: "HealthSync",
                      style: TextStyle(
                          color: Color(0xffD4FF00),
                          fontSize: 28,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 5),
              const Text(
                "Hello There, Please Sign In To Continue",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 40),

              /// Email Field
              buildField(
                controller: emailController,
                label: "Email Or Phone",
              ),

              const SizedBox(height: 20),

              /// Password Field
              buildField(
                controller: passwordController,
                label: "Password",
                isPassword: true,
              ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: Text("Forgot Password?",
                    style: TextStyle(color: Color(0xffD4FF00))),
              ),

              const SizedBox(height: 30),

              /// Login Button
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => DashboardScreen()));
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Color(0xffD4FF00),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text("Login",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// Register Link
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (_) => SignupScreen()));
                  },
                  child: const Text.rich(
                    TextSpan(
                      text: "Don't Have Account? ",
                      style: TextStyle(color: Colors.white),
                      children: [
                        TextSpan(
                          text: "Register!",
                          style: TextStyle(color: Color(0xffD4FF00)),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Field Widget
  Widget buildField({
    required TextEditingController controller,
    required String label,
    bool isPassword = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xffD4FF00)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          suffixIcon:
          isPassword ? Icon(Icons.visibility_off, color: Colors.grey) : null,
        ),
      ),
    );
  }
}
//
// import 'package:flutter/material.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("LOGIN "),
//       ),
//       body: SafeArea(child: Padding(padding:  const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text("welcome to Health Sync")
//           ],
//         ),
//       ),
//       ),
//
//     );
//   }
// }
//
