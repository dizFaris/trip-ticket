import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tripticket_mobile/providers/auth_provider.dart';
import 'package:tripticket_mobile/providers/user_provider.dart';
import 'package:tripticket_mobile/screens/support_ticket_screen.dart';
import 'package:tripticket_mobile/utils/utils.dart';
import 'package:tripticket_mobile/app_colors.dart';
import 'package:tripticket_mobile/widgets/date_picker.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _initialData = {};
  bool _isLoading = true;
  final UserProvider _userProvider = UserProvider();
  DateTime? _birthDate;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Validator minLengthValidator(int min) =>
      (value) => minLength(value, min);
  Validator maxLengthValidator(int max) =>
      (value) => maxLength(value, max);

  @override
  void initState() {
    super.initState();
    _getUserData();

    _usernameController.addListener(() => setState(() {}));
    _firstNameController.addListener(() => setState(() {}));
    _lastNameController.addListener(() => setState(() {}));
    _emailController.addListener(() => setState(() {}));
    _phoneController.addListener(() => setState(() {}));
    _currentPasswordController.addListener(() => setState(() {}));
    _newPasswordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
  }

  Future<void> _updateUser() async {
    final updateData = <String, dynamic>{};

    if (_usernameController.text.isNotEmpty) {
      updateData['Username'] = _usernameController.text;
    }
    if (_firstNameController.text.isNotEmpty) {
      updateData['FirstName'] = _firstNameController.text;
    }
    if (_lastNameController.text.isNotEmpty) {
      updateData['LastName'] = _lastNameController.text;
    }
    if (_birthDate != null) {
      updateData['BirthDate'] = _birthDate!.toIso8601String().substring(0, 10);
    }
    if (_emailController.text.isNotEmpty) {
      updateData['Email'] = _emailController.text;
    }
    if (_phoneController.text.isNotEmpty) {
      updateData['Phone'] = _phoneController.text;
    }

    if (_currentPasswordController.text.isNotEmpty &&
        _newPasswordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty) {
      updateData['CurrentPassword'] = _currentPasswordController.text;
      updateData['NewPassword'] = _newPasswordController.text;
      updateData['NewPasswordConfirm'] = _confirmPasswordController.text;
    }

    try {
      await _userProvider.update(AuthProvider.id!, updateData);
      if (!mounted) return;

      if (_usernameController.text.isNotEmpty) {
        AuthProvider.username = _usernameController.text;
      }

      if (_currentPasswordController.text.isNotEmpty &&
          _newPasswordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty) {
        updateData['CurrentPassword'] = _currentPasswordController.text;
        updateData['NewPassword'] = _newPasswordController.text;
        updateData['NewPasswordConfirm'] = _confirmPasswordController.text;
        AuthProvider.password = _newPasswordController.text;
      }

      _currentPasswordController.text = '';
      _newPasswordController.text = '';
      _confirmPasswordController.text = '';

      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          title: Text("Success"),
          content: Text("User successfully updated"),
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

      _getUserData();
    } catch (e) {
      if (!mounted) return;

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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _getUserData() async {
    try {
      var user = await _userProvider.getById(AuthProvider.id!);

      setState(() {
        _usernameController.text = user.username;
        _firstNameController.text = user.firstName;
        _lastNameController.text = user.lastName;
        _birthDate = user.birthDate;
        _emailController.text = user.email;
        _phoneController.text = user.phone ?? "";

        _initialData = {
          'Username': user.username,
          'FirstName': user.firstName,
          'LastName': user.lastName,
          'BirthDate': user.birthDate.toIso8601String().substring(0, 10),
          'Email': user.email,
          'Phone': user.phone ?? "",
        };
      });
    } on Exception catch (e) {
      if (!mounted) return;

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
    setState(() {
      _isLoading = false;
    });
  }

  bool _hasChanges() {
    return _usernameController.text != _initialData['Username'] ||
        _firstNameController.text != _initialData['FirstName'] ||
        _lastNameController.text != _initialData['LastName'] ||
        (_birthDate?.toIso8601String().substring(0, 10) !=
            _initialData['BirthDate']) ||
        _emailController.text != _initialData['Email'] ||
        _phoneController.text != _initialData['Phone'] ||
        _currentPasswordController.text.isNotEmpty ||
        _newPasswordController.text.isNotEmpty ||
        _confirmPasswordController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text(
          'User',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
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
                          _currentPasswordController,
                          "Password",
                          obscureText: true,
                          maxLength: 30,
                          isPasswordField: true,
                          validators: [
                            inputRequired,
                            password,
                            maxLengthValidator(30),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _buildTextField(
                          _newPasswordController,
                          "Password",
                          obscureText: true,
                          isPasswordField: true,
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
                          isPasswordField: true,
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
                                Navigator.pop(context, true);
                              },
                              child: const Text(
                                "Logout",
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
                              onPressed: _hasChanges()
                                  ? () {
                                      if (_formKey.currentState!.validate()) {
                                        if (_birthDate == null) {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text(
                                                "Validation Error",
                                              ),
                                              content: const Text(
                                                "Birth date is required.",
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text("Ok"),
                                                ),
                                              ],
                                            ),
                                          );
                                          return;
                                        }

                                        showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text("Confirm Save"),
                                            content: const Text(
                                              "Are you sure you want to save the changes?",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(
                                                  ctx,
                                                ).pop(), // cancel
                                                child: const Text("Cancel"),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(ctx).pop();
                                                  setState(() {
                                                    _isLoading = true;
                                                  });
                                                  _updateUser();
                                                },
                                                child: const Text("Confirm"),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    }
                                  : null,
                              child: const Text(
                                "Save",
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
                            const Text("Having trouble? "),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SupportTicketScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Contact support",
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
    bool isPasswordField = false,
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
        if (isPasswordField) {
          final hasAnyPassword =
              _currentPasswordController.text.isNotEmpty ||
              _newPasswordController.text.isNotEmpty ||
              _confirmPasswordController.text.isNotEmpty;

          if (hasAnyPassword) {
            if (value == null || value.isEmpty) return "This field is required";
            for (final validator in validators) {
              final result = validator(value);
              if (result != null) return result;
            }
            if (label == "Confirm Password" &&
                value != _newPasswordController.text) {
              return "Passwords do not match";
            }
          }
        } else {
          if (value == null || value.isEmpty) return "This field is required";
          for (final validator in validators) {
            final result = validator(value);
            if (result != null) return result;
          }
        }
        return null;
      },
    );
  }
}
