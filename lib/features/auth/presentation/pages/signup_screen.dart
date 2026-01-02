import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login_screen.dart';
import 'package:fitness_tracking/features/auth/domain/usecases/register_usecase.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool _isLoading = false;

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
              const Text(
                "Create Account",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 5),
              const Text(
                "Please Enter Your Credentials To Proceed",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 40),

              /// Full Name Field
              buildField(controller: name, label: "Full Name"),

              const SizedBox(height: 20),

              /// Phone Field
              buildField(controller: phone, label: "Phone"),

              const SizedBox(height: 20),

              /// Email Field
              buildField(controller: email, label: "Email"),

              const SizedBox(height: 20),

              /// Password Field
              buildField(
                controller: password,
                label: "Password",
                isPassword: true,
              ),

              const SizedBox(height: 30),

              /// Create Account Button
              GestureDetector(
                onTap: _isLoading
                    ? null
                    : () async {
                        final fullName = name.text.trim();
                        final mail = email.text.trim();
                        final phoneNumber = phone.text.trim();
                        final pwd = password.text;
                        if (fullName.isEmpty || mail.isEmpty || pwd.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill all fields')));
                          return;
                        }
                        setState(() => _isLoading = true);
                        final usecase = ref.read(registerUsecaseProvider);
                        final params = RegisterParams(
                          fullName: fullName,
                          email: mail,
                          phoneNumber: phoneNumber,
                          password: pwd,
                        );
                        final result = await usecase.call(params);
                        setState(() => _isLoading = false);
                        result.fold((failure) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(failure.message)));
                        }, (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Registration successful')));
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => LoginScreen()),
                          );
                        });
                      },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Color(0xffD4FF00),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            "Create Account",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// Login Link
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (_) => LoginScreen()));
                  },
                  child: const Text.rich(
                    TextSpan(
                      text: "Already Have Account? ",
                      style: TextStyle(color: Colors.white),
                      children: [
                        TextSpan(
                          text: "Login!",
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
