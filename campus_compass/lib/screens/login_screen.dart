import 'package:campus_compass/theme/app_colors.dart';
import 'package:campus_compass/theme/app_theme.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 25),

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
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 50),

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
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
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

                        const SizedBox(height: 5),

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
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return const AlertDialog(
                                        title: TextField(),
                                      );
                                    },
                                  );
                                },
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
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
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
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              filled: true,
                              fillColor: AppColors.lightCircle,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

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
                              const Text('Remember this device'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Login button
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width / 8,
                          ),
                          height:
                              MediaQuery.of(context).size.height / 17,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/map');
                            },
                            child: const Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Login',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(width: 13),
                                Icon(
                                  Icons.arrow_forward,
                                  color: AppColors.white,
                                )
                              ],
                            ),
                          ),
                        ),

                        // Create account
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('New to Concordia?'),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'Create account',
                                style: AppTheme.linkStyle,
                              ),
                            )
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Divider section
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width / 13,
                          ),
                          child: const Row(
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

                        const SizedBox(height: 25),

                        // Guest access
                        Container(
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
                                    color: Colors.blue[50],
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.checkmark_shield,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Continue as Guest',
                                      style: AppTheme.bulletStyle,
                                    ),
                                    Text(
                                      'Immediate access to safety \nmap & alerts',
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 10),
                                const Icon(
                                  Icons.arrow_forward,
                                  color: AppColors.mutedText,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Footer text
                        Text(
                          'By continuing, you agree to the safety sharing terms \nand privacy guidelines of Concordia University.',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 20),
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
}