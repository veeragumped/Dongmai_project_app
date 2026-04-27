import 'package:flutter/material.dart';
import 'package:gongdong/navbar/NavigationBar/navbar.dart';
import 'package:gongdong/model/profile.dart';
import 'package:gongdong/register/register.dart';
import 'package:gongdong/style/app_style.dart';
import 'package:gongdong/model/auth_controller.dart';
import 'package:gongdong/widgets/passwordwidget.dart';
import '../widgets/loginbutton.dart';
import '../widgets/emailwidget.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formKey = GlobalKey<FormState>();
  Profile profile = Profile();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Appcolors.jetblackColor,
      body: ListView(children: [_buildHeader(), _buildForm()]),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(61.0),
      child: Center(
        child: Column(
          children: [
            Image.asset('assets/images/logo.png', height: 192, width: 202),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Center(
      child: Column(
        children: [
          Form(
            key: formKey,
            child: Column(
              children: [
                Textwidget(
                  errortext: "กรุณาใส่อีเมล",
                  name: 'อีเมล',
                  width: 305,
                  height: AppSpacing.gap,
                  color: Appcolors.creamywhiteColor,
                  saved: (email) {
                    profile.emailp = email;
                  },
                ),
                SizedBox(height: 27),
                Passwordwidget(
                  errortext: "กรุณาใส่รหัสผ่าน",
                  width: 305,
                  height: AppSpacing.gap,
                  color: Appcolors.creamywhiteColor,
                  saved: (password) {
                    profile.passwordp = password;
                  },
                ),
              ],
            ),
          ),
          _buildForgetPass(),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildForgetPass() {
    return Padding(
      padding: const EdgeInsets.only(left: 209),
      child: TextButton(
        onPressed: () {
          formKey.currentState?.save();
          AuthController.resetPassword(context, profile.emailp);
        },
        child: Text(
          'ลืมรหัส?',
          style: TextStyle(
            color: Appcolors.creamywhiteColor,
            fontSize: 20,
            fontFamily: 'supermarket',
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        SizedBox(height: 33),
        LoginButton(
          text: 'เข้าสู่ระบบ',
          height: AppSpacing.height,
          width: 305,
          color: Appcolors.copperColor,
          textcolor: Appcolors.creamywhiteColor,
          onPressed: () => AuthController.loginUser(
            context: context,
            formKey: formKey,
            profile: profile,
            targetPage: Navbar(),
          ),
        ),
        SizedBox(height: AppSpacing.smallgap),
        //Text(
        //  'หรือ',
        // style: TextStyle(
        //    color: Appcolors.creamywhiteColor,
        //   fontSize: 30,
        //   fontFamily: 'supermarket',
        // ),
        //  textAlign: TextAlign.center,
        //),
        SizedBox(height: AppSpacing.smallgap),
        //LoginButton(
        //  text: 'เข้าสู่ระบบด้วย Google',
        //  height: 38,
        //  width: 305,
        // color: Appcolors.copperColor,
        // textcolor: Appcolors.creamywhiteColor,
        // onPressed: () {},
        //),
        SizedBox(height: AppSpacing.gap80),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return Register();
                },
              ),
            );
          },
          child: Text(
            'ยังไม่มีบัญชี? สร้างบัญชี',
            style: TextStyle(
              color: Appcolors.creamywhiteColor,
              fontFamily: 'supermarket',
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }
}
