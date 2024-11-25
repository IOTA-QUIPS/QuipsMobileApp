import 'package:flutter/material.dart';
import 'package:quipsapp/services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _referralCodeController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';
  bool _acceptTerms = false;
  String _selectedCountryCode = '+51';

  final List<Map<String, String>> _countryCodes = [
    {'name': 'Perú', 'code': '+51'},
    {'name': 'Colombia', 'code': '+57'},
    {'name': 'Chile', 'code': '+56'},
    {'name': 'Argentina', 'code': '+54'},
    {'name': 'USA', 'code': '+1'},
    {'name': 'Mexico', 'code': '+52'},
    {'name': 'El Salvador', 'code': '+503'},
  ];

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: Text(
                    localizations.createAccount,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber[300],
                      shadows: [
                        Shadow(
                          offset: Offset(0, 4),
                          blurRadius: 10,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                ),

                _buildTextField(
                  controller: _firstNameController,
                  hintText: localizations.firstName,
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.fieldRequired;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),

                _buildTextField(
                  controller: _lastNameController,
                  hintText: localizations.lastName,
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.fieldRequired;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),

                _buildTextField(
                  controller: _usernameController,
                  hintText: localizations.username,
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.fieldRequired;
                    }
                    if (value.length < 3) {
                      return localizations.usernameTooShort;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),

                _buildTextField(
                  controller: _emailController,
                  hintText: localizations.email,
                  icon: Icons.email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.fieldRequired;
                    }
                    final emailRegex = RegExp(
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                    if (!emailRegex.hasMatch(value)) {
                      return localizations.invalidEmail;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),

                _buildTextField(
                  controller: _passwordController,
                  hintText: localizations.password,
                  icon: Icons.lock,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.fieldRequired;
                    }
                    if (value.length < 6) {
                      return localizations.passwordTooShort;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),

                _buildCountrySelector(localizations),
                SizedBox(height: 24),

                _buildTextField(
                  controller: _phoneNumberController,
                  hintText: localizations.phoneNumber,
                  icon: Icons.phone,
                  prefixText: _selectedCountryCode + " ",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.fieldRequired;
                    }
                    if (!RegExp(r'^[0-9]{9}$').hasMatch(value)) {
                      return localizations.invalidPhoneNumber;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),

                _buildTextField(
                  controller: _referralCodeController,
                  hintText: localizations.referralCodeOptional,
                  icon: Icons.card_giftcard,
                ),
                SizedBox(height: 32),

                _buildTermsCheckbox(localizations),
                SizedBox(height: 32),

                _isLoading
                    ? Center(child: CircularProgressIndicator(color: Colors.amber[300]))
                    : ElevatedButton(
                  onPressed: _register,
                  child: Text(localizations.register),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[300],
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    shadowColor: Colors.amber[100],
                    elevation: 6,
                  ),
                ),
                SizedBox(height: 32),

                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.redAccent),
                      textAlign: TextAlign.center,
                    ),
                  ),
                SizedBox(height: 32),

                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text(
                    localizations.alreadyHaveAccountLogin,
                    style: TextStyle(
                      color: Colors.amber[300],
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountrySelector(AppLocalizations localizations) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: DropdownButtonFormField<String>(
          value: _selectedCountryCode,
          dropdownColor: Colors.grey[900],
          iconEnabledColor: Colors.amber[300],
          style: TextStyle(color: Colors.white),
          items: _countryCodes.map((country) {
            return DropdownMenuItem<String>(
              value: country['code'],
              child: Text(
                '${country['name']} (${country['code']})',
                style: TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
          decoration: InputDecoration(
            labelText: localizations.selectCountry,
            labelStyle: TextStyle(color: Colors.grey[600]),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _selectedCountryCode = value!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox(AppLocalizations localizations) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: _acceptTerms,
            onChanged: (value) {
              setState(() {
                _acceptTerms = value!;
              });
            },
            activeColor: Colors.amber[300],
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/terms');
            },
            child: Text(
              localizations.acceptTermsAndConditions,
              style: TextStyle(
                color: Colors.amber[300],
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    String? prefixText,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
          prefixIcon: Icon(icon, color: Colors.amber[300], size: 24),
          prefixText: prefixText,
          prefixStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[900],
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptTerms) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.mustAcceptTerms;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    String phoneNumber = _selectedCountryCode + _phoneNumberController.text;
    String? errorMessage = await _authService.register(
      _usernameController.text,
      _passwordController.text,
      _firstNameController.text,
      _lastNameController.text,
      _emailController.text,
      phoneNumber,
      _referralCodeController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (errorMessage == null) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      setState(() {
        _errorMessage = errorMessage;
      });
    }
  }
}
