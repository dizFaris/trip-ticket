import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:tripticket_desktop/providers/auth_provider.dart';
import 'package:tripticket_desktop/providers/user_provider.dart';
import 'package:tripticket_desktop/screens/master_screen.dart';
import 'package:tripticket_desktop/screens/trips_screen.dart';
import 'package:tripticket_desktop/utils/utils.dart';
import 'package:tripticket_desktop/app_colors.dart';
import 'package:tripticket_desktop/widgets/date_picker.dart';

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

  final phoneFormatter = MaskTextInputFormatter(
    mask: '### ### ####',
    filter: {"#": RegExp(r'[0-9]')},
  );

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
      updateData['Phone'] = phoneFormatter.getUnmaskedText();
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

      if (!mounted) return;
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

        if (user.phone != null && user.phone!.isNotEmpty) {
          _phoneController.value = phoneFormatter.formatEditUpdate(
            const TextEditingValue(),
            TextEditingValue(text: user.phone!),
          );
        } else {
          _phoneController.text = "";
        }

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
        phoneFormatter.getUnmaskedText() != (_initialData['Phone'] ?? '') ||
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
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () =>
                    masterScreenKey.currentState?.navigateTo(TripsScreen()),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Edit user data",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: SizedBox(
                  height: 32,
                  width: 32,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Form(
                      key: _formKey,
                      child: Column(
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
                            hintText: "061 123 4567",
                            keyboardType: TextInputType.phone,
                            inputFormatters: [phoneFormatter],
                            validators: [inputRequired, phoneValidator],
                          ),
                          const SizedBox(height: 10),
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
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 40,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  backgroundColor: AppColors.primaryGreen,
                                ),
                                onPressed: _hasChanges()
                                    ? () {
                                        if (_formKey.currentState!.validate()) {
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text("Confirm Save"),
                                              content: const Text(
                                                "Are you sure you want to save the changes?",
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(ctx).pop(),
                                                  child: const Text("Cancel"),
                                                ),
                                                TextButton(
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
                        ],
                      ),
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
        isDense: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color.fromARGB(31, 68, 61, 61)),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryGreen, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        errorMaxLines: 3,
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
