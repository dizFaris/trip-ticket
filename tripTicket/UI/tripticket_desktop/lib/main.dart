import 'package:flutter/material.dart';
import 'package:tripticket_desktop/screens/master_screen.dart';
import 'package:tripticket_desktop/utils/utils.dart';
import 'package:tripticket_desktop/providers/auth_provider.dart';
import 'package:tripticket_desktop/providers/user_provider.dart';
import 'app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TripTicket',
      theme: ThemeData(
        primaryColor: Colors.green,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primaryGreen,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        drawerTheme: DrawerThemeData(backgroundColor: AppColors.primaryGreen),
        listTileTheme: ListTileThemeData(
          textColor: Colors.white,
          selectedColor: AppColors.primaryYellow,
          selectedTileColor: AppColors.primaryGreen,
          iconColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? usernameError;
  String? passwordError;
  bool isLoading = false;
  late UserProvider userProvider;

  @override
  void initState() {
    super.initState();
    userProvider = UserProvider();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: SizedBox.expand(
              child: Image.asset(
                'assets/images/main_background.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 64.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome to TripTicket',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Log in to proceed',
                      style: TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person),
                        labelText: 'Username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        errorText: usernameError,
                      ),
                      onChanged: (value) {
                        if (usernameError != null) {
                          setState(() {
                            usernameError = null;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock),
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        errorText: passwordError,
                        errorMaxLines: 3,
                      ),
                      onChanged: (value) {
                        if (passwordError != null) {
                          setState(() {
                            passwordError = null;
                          });
                        }
                      },
                      onSubmitted: (_) {
                        _login();
                      },
                    ),

                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Log In',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _login() async {
    if (!validateInputs()) return;

    setState(() {
      isLoading = true;
    });

    AuthProvider.username = _usernameController.text;
    AuthProvider.password = _passwordController.text;
    try {
      await userProvider.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      _usernameController.clear();
      _passwordController.clear();

      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => MasterScreen()));
    } on Exception catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Ok"),
            ),
          ],
          content: Text(e.toString()),
        ),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  bool validateInputs() {
    final usernameVal = _usernameController.text;
    final passwordVal = _passwordController.text;

    final usernameValidation =
        inputRequired(usernameVal) ??
        noSpecialCharacters(usernameVal) ??
        minLength(usernameVal, 3) ??
        maxLength(usernameVal, 20);

    final passwordValidation =
        inputRequired(passwordVal) ?? password(passwordVal);

    setState(() {
      usernameError = usernameValidation;
      passwordError = passwordValidation;
    });

    return usernameError == null && passwordError == null;
  }
}
