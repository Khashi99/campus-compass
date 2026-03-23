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
          child: Center(
            child: Column(
            children: [
              SizedBox(
                height: 25,
              ),
              //Logo & subtitle
              ClipRRect(
                child: Image.asset(
                  'assets/images/icon_prod_circ.png',
                    height: 120,),
                ),
                Text('Campus Safety & Navigation', 
                  style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 16,)),
                SizedBox(
                  height: 50,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget> [
                      Container(
                      padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width / 9, 0, MediaQuery.of(context).size.width / 9, 8),
                        child: Row(
                          children: [
                            //email label text
                            Text('University Email', style: AppTheme.bulletStyle,)
                          ],
                        ),
                      ),
                      //email field
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.25,
                        child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.email_outlined, color: AppColors.mutedText,),
                          hintText: 'net_name@live.concordia.ca', 
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                          filled: true,
                          fillColor: AppColors.lightCircle,
                        ),
                      ),
                    ),
                    SizedBox(height: 5,),
                      //password field
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //password label text
                            Container( 
                              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 9),
                              child: Text('Password', style: AppTheme.bulletStyle,),
                            ),

                            //forgot password button
                            Container(
                              padding: EdgeInsets.only(right: MediaQuery.of(context).size.width / 13),
                              child: TextButton(
                                onPressed: (){
                                  showDialog(
                                    context: context, 
                                    builder: (context) {
                                      return AlertDialog(
                                        title: TextField(
                                        ),
                                      );
                                    }
                                  );
                                }, 
                                child: Text(
                                'Forgot password?', 
                                style: AppTheme.linkStyle,
                                )
                              ),
                            ),
                          ],
                        ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.25,
                        child: TextFormField(
                        obscureText: _obscureText,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock_outline, color: AppColors.mutedText,),
                          suffixIcon: IconButton(onPressed: (){
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          }, icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off)),
                          hintText: 'Password',
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                          filled: true,
                          fillColor: AppColors.lightCircle,
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 13),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _isChecked, 
                            onChanged: (bool? newValue){
                              setState(() {
                                _isChecked = newValue!;
                            });
                          }),
                          Text('Remember this device'),
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    //Login button
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 8),
                      height: MediaQuery.of(context).size.height / 17,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/map');
                        }, 
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Login', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w900, fontSize: 18),), 
                            SizedBox(width: 13,),
                            Icon(Icons.arrow_forward, color: AppColors.white,)
                          ],
                        ),
                      ),
                    ),

                    //Create account prompt & text button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('New to Concordia?',),
                        // SizedBox(width: 10,),
                        TextButton(
                          onPressed: (){
                            //Navigate to create account screen
                        }, 
                        child: Text('Create account', style: AppTheme.linkStyle,))
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    //Text with dividers
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 13),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Divider()
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text('OR QUICK ACCESS', style: AppTheme.descriptionStyle,),
                          ),
                          Expanded(
                            child: Divider(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 25,),
                    //dotted line for Continue as Guest
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 14),
                      child: DottedBorder(
                        options: RectDottedBorderOptions(
                          dashPattern: [5, 5],
                          strokeWidth: 2,
                          padding: EdgeInsets.all(16),
                          color: AppColors.secondaryBlue,
                        ),
                        
                        //dotted line contents
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            //shield icon
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                shape: BoxShape.circle,
                              ),  
                              child: Icon(CupertinoIcons.checkmark_shield, color: AppColors.primaryBlue,),           
                            ),
                            //Text information
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Continue as Guest', style: AppTheme.bulletStyle,),
                                Text('Immediate access to safety \nmap & alerts'),
                              ],
                            ),

                            SizedBox(width: 10,),

                            //arrow icon
                            Icon(Icons.arrow_forward, color: AppColors.mutedText,),                           
                          ],
                        )
                      ),
                    ), 

                    SizedBox(height: 20,),

                    //Data sharing consent
                    Text('By continuing, you agree to the safty sharing terms \nand privacy guidelines of Concordia University.', 
                    style: TextStyle(color: Colors.grey[600], fontSize: 13), textAlign: TextAlign.center,)
                  ],
                )
              ),
            ],
          ),
        ),
      )),
    );
  }
}