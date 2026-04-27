import 'package:flutter/material.dart';
import 'package:gongdong/navbar/NavigationBar/navbar.dart';
import 'package:gongdong/login/login.dart';
import 'package:gongdong/model/profile.dart';
import 'package:gongdong/style/app_style.dart';
import 'package:gongdong/model/auth_controller.dart';
import 'package:gongdong/widgets/emailwidget.dart';
import 'package:gongdong/widgets/loginbutton.dart';
import 'package:gongdong/widgets/passwordwidget.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(
          top: AppSpacing.toppadding,
          bottom: AppSpacing.bottonpadding,
        ),
        child: Text(
          'สร้างบัญชี',
          style: TextStyle(
            fontFamily: 'supermarket',
            fontSize: 40,
            color: Colors.white,
            decoration: TextDecoration.underline,
            decorationColor: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        SizedBox(height: AppSpacing.gap),
        Form(
          key: formKey,
          child: Column(
            children: [
              Textwidget(
                errortext: "กรุณากรอกอีเมล",
                name: 'อีเมล',
                width: AppSpacing.width,
                height: AppSpacing.height,
                color: Appcolors.creamywhiteColor,
                saved: (email) {
                  profile.emailp = email;
                },
              ),
              SizedBox(height: AppSpacing.gap),
              Passwordwidget(
                errortext: "กรุณากรอกรหัสผ่าน",
                width: AppSpacing.width,
                height: AppSpacing.height,
                color: Appcolors.creamywhiteColor,
                saved: (password) {
                  profile.passwordp = password;
                },
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.gap),
        LoginButton(
          text: 'สร้างบัญชี',
          height: AppSpacing.height,
          width: AppSpacing.width,
          color: Appcolors.copperColor,
          textcolor: Appcolors.creamywhiteColor,
          onPressed: () => AuthController.registerUser(
            context: context,
            formKey: formKey,
            profile: profile,
            targetPage: Navbar(),
          ),
        ),
        SizedBox(height: AppSpacing.gap150),
        _buildFooter(),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        //Text(
        //'หรือ',
        // style: TextStyle(
        //   color: Appcolors.creamywhiteColor,
        //   fontSize: 30,
        //   fontFamily: 'supermarket',
        // ),
        //  textAlign: TextAlign.center,
        // ),
        SizedBox(height: AppSpacing.smallgap),
        //LoginButton(
        //  text: 'เข้าสู่ระบบด้วย Google',
        //  height: AppSpacing.height,
        //  width: AppSpacing.width,
        //  color: Appcolors.creamywhiteColor,
        // textcolor: Appcolors.jetblackColor,
        // onPressed: () => AuthController.registerUser(
        //   context: context,
        //    formKey: formKey,
        //   profile: profile,
        //   targetPage: Navbar(),
        //  ),
        //  ),
        SizedBox(height: AppSpacing.gap80),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return Login();
                },
              ),
            );
          },
          child: Text(
            'มีบัญชีอยู่แล้ว? เข้าสู่ระบบ',
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
