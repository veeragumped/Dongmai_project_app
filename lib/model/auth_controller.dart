import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gongdong/model/profile.dart';
//import 'package:gongdong/navbar/NavigationBar/navbar.dart';
//import 'package:google_sign_in/google_sign_in.dart';

class AuthController {
  static Future<void> registerUser({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required Profile profile,
    required Widget targetPage,
  }) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: profile.emailp,
              password: profile.passwordp,
            );
        if (userCredential.user != null) {
          String autoUsername = profile.emailp.split('@')[0];

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
                'username': autoUsername,
                'email': profile.emailp,
                'diamonds': 0,
                'equippedShelfImage': 'assets/images/shelfbg.png',
                'profileImage': 'assets/images/user_Profile.png',
                'createdAt': DateTime.now(),
              });
        }
        if (!context.mounted) return;

        Fluttertoast.showToast(
          msg: "สร้างบัญชีเรียบร้อย!",
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.grey,
          textColor: Colors.black,
          fontSize: 24,
        );

        formKey.currentState!.reset();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => targetPage),
          (route) => false,
        );
      } on FirebaseAuthException catch (firebaseexception) {
        String message = _getThaiMessage(firebaseexception.code);

        Fluttertoast.showToast(
          msg: message,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 18,
        );
      }
    }
  }

  static String _getThaiMessage(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return 'อีเมลนี้ถูกใช้แล้ว โปรดเลือกใช้อีเมลอื่น';
      case 'weak-password':
        return 'รหัสผ่านต้องมี 6 ตัวอักษรขึ้นไป';
      case 'invalid-email':
        return 'รูปแบบอีเมลไม่ถูกต้อง';
      default:
        return 'เกิดข้อผิดพลาด ไม่สามารถลงทะเบียนได้';
    }
  }

  static Future<void> loginUser({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required Profile profile,
    required Widget targetPage,
  }) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: profile.emailp,
              password: profile.passwordp,
            )
            .then((value) {
              if (!context.mounted) return;

              Fluttertoast.showToast(
                msg: 'เข้าสู่ระบบสำเร็จ',
                gravity: ToastGravity.TOP,
              );
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => targetPage),
                (route) => false,
              );
            });
      } on FirebaseAuthException catch (firebaseexception) {
        String message = _getLoginThaiMessage(firebaseexception.code);
        Fluttertoast.showToast(msg: message, backgroundColor: Colors.red);
      }
    }
  }

  static Future<void> resetPassword(BuildContext context, String email) async {
    if (email.isEmpty) {
      Fluttertoast.showToast(
        msg: "กรุณากรอกอีเมลก่อนกดลืมรหัสผ่าน",
        backgroundColor: Colors.orange,
      );
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Fluttertoast.showToast(
        msg: "ส่งลิงก์รีเซ็ตรหัสผ่านไปที่อีเมลแล้ว",
        backgroundColor: Colors.green,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "ไม่สามารถส่งอีเมลได้: $e",
        backgroundColor: Colors.red,
      );
    }
  }

  static String _getLoginThaiMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'ไม่พบอีเมลนี้ในระบบ';
      case 'wrong-password':
        return 'รหัสผ่านไม่ถูกต้อง';
      case 'invalid-email':
        return 'รูปแบบอีเมลไม่ถูกต้อง';
      case 'user-disabled':
        return 'บัญชีนี้ถูกระงับการใช้งาน';
      case 'invalid-credential':
        return 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
      default:
        return 'เข้าสู่ระบบไม่ได้ กรุณาลองใหม่อีกครั้ง';
    }
  }
}
