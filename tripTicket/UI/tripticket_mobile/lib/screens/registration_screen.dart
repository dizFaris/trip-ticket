import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
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
  final Map<String, String?> _fieldErrors = {};
  String? _birthDateError;
  Validator minLengthValidator(int min) =>
      (value) => minLength(value, min);
  Validator maxLengthValidator(int max) =>
      (value) => maxLength(value, max);

  List<Validator> _getValidators(String label) {
    switch (label) {
      case "Username":
        return [
          inputRequired,
          noSpecialCharacters,
          minLengthValidator(3),
          maxLengthValidator(20),
        ];
      case "First Name":
        return [inputRequired, minLengthValidator(2), maxLengthValidator(20)];
      case "Last Name":
        return [inputRequired, minLengthValidator(2), maxLengthValidator(30)];
      case "Email":
        return [inputRequired, emailFormat, maxLengthValidator(70)];
      case "Phone":
        return [inputRequired, phoneValidator];
      case "Password":
        return [inputRequired, password, maxLengthValidator(30)];
      case "Confirm Password":
        return [inputRequired, maxLengthValidator(30)];
      default:
        return [];
    }
  }

  final phoneFormatter = MaskTextInputFormatter(
    mask: '### ### ####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  Future<void> _registerUser() async {
    try {
      final request = {
        "Username": _usernameController.text,
        "FirstName": _firstNameController.text,
        "LastName": _lastNameController.text,
        "Email": _emailController.text,
        "Phone": phoneFormatter.getUnmaskedText(),
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
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
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                  _birthDateError = null;
                                });
                              },
                            ),
                          ],
                        ),
                        if (_birthDateError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2, left: 12),
                            child: Text(
                              _birthDateError!,
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
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
                          hintText: "061 123 4567",
                          keyboardType: TextInputType.phone,
                          inputFormatters: [phoneFormatter],
                          validators: [inputRequired, phoneValidator],
                        ),
                        const SizedBox(height: 10),
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
                                setState(() {
                                  _fieldErrors.clear();
                                  _birthDateError = null;
                                });

                                bool isDateValid = true;
                                if (_birthDate == null) {
                                  setState(() {
                                    _birthDateError = "Birth date is required.";
                                  });
                                  isDateValid = false;
                                }

                                bool isFormValid = true;
                                final fields = {
                                  "Username": _usernameController,
                                  "First Name": _firstNameController,
                                  "Last Name": _lastNameController,
                                  "Email": _emailController,
                                  "Phone": _phoneController,
                                  "Password": _passwordController,
                                  "Confirm Password":
                                      _confirmPasswordController,
                                };

                                fields.forEach((label, controller) {
                                  for (final validator in _getValidators(
                                    label,
                                  )) {
                                    final result = validator(controller.text);
                                    if (result != null) {
                                      _fieldErrors[label] = result;
                                      isFormValid = false;
                                      break;
                                    }
                                  }

                                  if (label == "Confirm Password" &&
                                      controller.text !=
                                          _passwordController.text) {
                                    _fieldErrors[label] =
                                        "Passwords do not match";
                                    isFormValid = false;
                                  }
                                });

                                setState(() {});

                                if (isFormValid && isDateValid) {
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Text("Already registered? "),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Log in",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: AppColors.primaryYellow,
                                ),
                              ),
                            ),
                          ],
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
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontWeight: FontWeight.normal,
        ),
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
        errorText: _fieldErrors[label],
        errorStyle: const TextStyle(color: Colors.red),
        errorMaxLines: 3,
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
      onChanged: (_) {
        if (_fieldErrors[label] != null) {
          setState(() {
            _fieldErrors[label] = null;
          });
        }
      },
    );
  }
}
