import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tripticket_mobile/app_colors.dart';
import 'package:tripticket_mobile/main.dart';
import 'package:tripticket_mobile/providers/user_provider.dart';
import 'package:tripticket_mobile/utils/utils.dart';
import 'package:tripticket_mobile/widgets/date_picker.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final UserProvider _userProvider = UserProvider();
  DateTime? _birthDate;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Validator minLengthValidator(int min) =>
      (value) => minLength(value, min);
  Validator maxLengthValidator(int max) =>
      (value) => maxLength(value, max);

  Future<void> _registerUser() async {
    try {
      final request = {
        "Username": _usernameController.text,
        "FirstName": _firstNameController.text,
        "LastName": _lastNameController.text,
        "Email": _emailController.text,
        "Phone": _phoneController.text,
        "Password": _passwordController.text,
        "PasswordConfirm": _confirmPasswordController.text,
        "BirthDate": _birthDate?.toIso8601String().substring(0, 10),
      };

      await _userProvider.insert(request);

      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      Navigator.pop(context, true);

      if (!mounted) return;
      final result = await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          title: Text("Success"),
          content: Text("User successfully added"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text("Ok"),
            ),
          ],
        ),
      );

      if (result == true || result == null) {
        if (!mounted) return;
        Navigator.of(context).pop();
      }
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Ok"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Form(
              key: _formKey,
              child: _isLoading
                  ? SizedBox(
                      height: 32,
                      width: 32,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        _buildTextField(
                          _usernameController,
                          "Username",
                          maxLength: 20,
                          validators: [
                            inputRequired,
                            noSpecialCharacters,
                            minLengthValidator(3),
                            maxLengthValidator(20),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _buildTextField(
                          _firstNameController,
                          "First Name",
                          maxLength: 20,
                          validators: [
                            inputRequired,
                            minLengthValidator(2),
                            maxLengthValidator(20),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _buildTextField(
                          _lastNameController,
                          "Last Name",
                          maxLength: 30,
                          validators: [
                            inputRequired,
                            minLengthValidator(2),
                            maxLengthValidator(30),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Text(
                              "Birth date",
                              style: TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 8),
                            DatePickerButton(
                              initialDate: _birthDate,
                              allowPastDates: true,
                              placeHolder: 'Select date',
                              onDateSelected: (date) {
                                setState(() {
                                  _birthDate = date;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildTextField(
                          _emailController,
                          "Email",
                          maxLength: 70,
                          keyboardType: TextInputType.emailAddress,
                          validators: [
                            inputRequired,
                            emailFormat,
                            maxLengthValidator(70),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _buildTextField(
                          _phoneController,
                          "Phone",
                          maxLength: 10,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],

                          validators: [
                            inputRequired,
                            onlyNumbers,
                            minLengthValidator(6),
                            maxLengthValidator(10),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _buildTextField(
                          _passwordController,
                          "Password",
                          obscureText: true,
                          maxLength: 30,
                          validators: [
                            inputRequired,
                            password,
                            maxLengthValidator(30),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _buildTextField(
                          _confirmPasswordController,
                          "Confirm Password",
                          obscureText: true,
                          maxLength: 30,
                          validators: [inputRequired, maxLengthValidator(30)],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 40,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: AppColors.primaryYellow,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlack,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 40,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: AppColors.primaryGreen,
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  if (_birthDate == null) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text("Validation Error"),
                                        content: Text(
                                          "Birth date is required.",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text("Ok"),
                                          ),
                                        ],
                                      ),
                                    );
                                    return;
                                  }
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  _registerUser();
                                }
                              },
                              child: const Text(
                                "Register",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text("Already registered? "),
                              Text(
                                "Log in",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: AppColors.primaryYellow,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    List<Validator> validators = const [],
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black87),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black12),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryGreen, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (value) {
        for (final validator in validators) {
          final result = validator(value);
          if (result != null) return result;
        }
        if (label == "Confirm Password" && value != _passwordController.text) {
          return "Passwords do not match";
        }
        return null;
      },
    );
  }
}
