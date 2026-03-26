import 'package:campus_compass/theme/app_colors.dart';
import 'package:campus_compass/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isChecked = false;
  bool _isAuthLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: Container(
          color: AppColors.pageBackground,
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: 25),

                  // Logo & subtitle
                  ClipRRect(
                    child: Image.asset(
                      'assets/images/icon_prod_circ.png',
                      height: 120,
                    ),
                  ),

                  Text(
                    'Campus Safety & Navigation',
                    style: TextStyle(
                      color: AppColors.mutedText,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  SizedBox(height: 50),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        // Email label
                        Container(
                          padding: EdgeInsets.fromLTRB(
                            MediaQuery.of(context).size.width / 9,
                            0,
                            MediaQuery.of(context).size.width / 9,
                            8,
                          ),
                          child: Row(
                            children: [
                              Text(
                                'University Email',
                                style: AppTheme.bulletStyle,
                              )
                            ],
                          ),
                        ),

                        // Email field
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 1.25,
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              final email = value?.trim() ?? '';
                              if (email.isEmpty) {
                                return 'Enter your email';
                              }
                              if (!email.contains('@')) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: AppColors.mutedText,
                              ),
                              hintText: 'net_name@live.concordia.ca',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              filled: true,
                              fillColor: AppColors.lightCircle,
                            ),
                          ),
                        ),

                        SizedBox(height: 5),

                        // Password label + forgot password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width / 9,
                              ),
                              child: Text(
                                'Password',
                                style: AppTheme.bulletStyle,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                right:
                                    MediaQuery.of(context).size.width / 13,
                              ),
                              child: TextButton(
                                onPressed: _isAuthLoading ? null : _sendPasswordReset,
                                child: Text(
                                  'Forgot password?',
                                  style: AppTheme.linkStyle,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Password field
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 1.25,
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: _obscureText,
                            validator: (value) {
                              final password = value ?? '';
                              if (password.isEmpty) {
                                return 'Enter your password';
                              }
                              if (password.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: AppColors.mutedText,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                              hintText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              filled: true,
                              fillColor: AppColors.lightCircle,
                            ),
                          ),
                        ),

                        SizedBox(height: 10),

                        // Remember me checkbox
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width / 13,
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _isChecked,
                                onChanged: (bool? newValue) {
                                  setState(() {
                                    _isChecked = newValue!;
                                  });
                                },
                              ),
                              Text('Remember this device'),
                            ],
                          ),
                        ),

                        SizedBox(height: 10),

                        // Login button
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width / 8,
                          ),
                          height:
                              MediaQuery.of(context).size.height / 17,
                          child: ElevatedButton(
                            onPressed: _isAuthLoading ? null : _login,
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                if (_isAuthLoading)
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                else ...[
                                  Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(width: 13),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        // Create account
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('New to Concordia?'),
                            TextButton(
                              onPressed: _isAuthLoading ? null : _createAccount,
                              child: Text(
                                'Create account',
                                style: AppTheme.linkStyle,
                              ),
                            )
                          ],
                        ),

                        SizedBox(height: 20),

                        // Divider section
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width / 13,
                          ),
                          child: Row(
                            children: [
                              Expanded(child: Divider()),
                              Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  'OR QUICK ACCESS',
                                ),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                        ),

                        SizedBox(height: 25),

                        // Guest access
                        GestureDetector(
                          onTap: _isAuthLoading
                              ? null
                              : () => Navigator.pushReplacementNamed(context, '/map'),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width / 14,
                            ),
                            child: DottedBorder(
                              options: RectDottedBorderOptions(
                                dashPattern: [5, 5],
                                strokeWidth: 2,
                                padding: const EdgeInsets.all(16),
                                color: AppColors.secondaryBlue,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue.withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      CupertinoIcons.checkmark_shield,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Continue as Guest',
                                        style: AppTheme.bulletStyle,
                                      ),
                                      Text(
                                        'Immediate access to safety \nmap & alerts',
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 10),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: AppColors.mutedText,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 20),

                        // Footer text
                        Text(
                          'By continuing, you agree to the safety sharing terms \nand privacy guidelines of Concordia University.',
                          style: TextStyle(
                            color: AppColors.mutedText,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 20),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isAuthLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      await _ensureUserProfileDocument();

      if (!mounted) {
        return;
      }
      Navigator.pushReplacementNamed(context, '/map');
    } on FirebaseAuthException catch (e) {
      _showAuthError(_mapAuthError(e));
    } finally {
      if (mounted) {
        setState(() {
          _isAuthLoading = false;
        });
      }
    }
  }

  Future<void> _createAccount() async {
    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isAuthLoading = true;
    });

    final auth = FirebaseAuth.instance;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      final currentUser = auth.currentUser;
      if (currentUser != null && currentUser.isAnonymous) {
        final credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        await currentUser.linkWithCredential(credential);
      } else {
        await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
      await _ensureUserProfileDocument();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully.')),
      );
      Navigator.pushReplacementNamed(context, '/map');
    } on FirebaseAuthException catch (e) {
      // If the email already exists, treat this as login so the flow doesn't dead-end.
      if (e.code == 'email-already-in-use' || e.code == 'credential-already-in-use') {
        await _signInExistingUser(email: email, password: password);
      } else {
        _showAuthError(_mapAuthError(e));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAuthLoading = false;
        });
      }
    }
  }

  bool _validateForm() {
    final form = _formKey.currentState;
    if (form == null) {
      return false;
    }
    return form.validate();
  }

  String _mapAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'This email is already registered. Try logging in.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'weak-password':
        return 'Password is too weak (min 6 characters).';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'operation-not-allowed':
        return 'Email/password auth is not enabled in Firebase.';
      default:
        return error.message ?? 'Authentication failed.';
    }
  }

  Future<void> _signInExistingUser({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _ensureUserProfileDocument();

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Existing account found. Logged in.')),
      );
      Navigator.pushReplacementNamed(context, '/map');
    } on FirebaseAuthException {
      _showAuthError('Account already exists. Use the correct password to log in.');
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showAuthError('Enter a valid email first, then tap Forgot password.');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent.')),
      );
    } on FirebaseAuthException catch (e) {
      _showAuthError(_mapAuthError(e));
    }
  }

  Future<void> _ensureUserProfileDocument() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final usersRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snapshot = await usersRef.get();
    final now = FieldValue.serverTimestamp();

    if (!snapshot.exists) {
      await usersRef.set({
        'displayName': user.isAnonymous ? 'Anonymous User' : (user.email ?? 'Student'),
        'alertPreference': {
          'mode': 'haptic',
          'quietHours': null,
        },
        'createdAt': now,
        'updatedAt': now,
      });
      return;
    }

    await usersRef.set({
      'updatedAt': now,
    }, SetOptions(merge: true));
  }

  void _showAuthError(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
