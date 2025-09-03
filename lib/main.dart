import 'package:flutter/material.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart'; // นำเข้า LINE SDK

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

// จัดการ State ของ MyApp
class _MyAppState extends State<MyApp> {
  // ตัวแปรสำหรับเก็บข้อมูล Profile ของผู้ใช้
  UserProfile? userProfile;
  // ตัวแปรสำหรับเก็บ Access Token กุญแจยืนยันตัวตนของผู้ใช้
  String? userAccessToken;
  bool isLogin = false; // ตัวแปรสถานะการ Login

  // --- initState: เรียกเมื่อ Widget ถูกสร้างขึ้นครั้งแรก ---
  @override
  void initState() {
    super.initState();
    // ตั้งค่า LINE SDK ตอนแอปเริ่มทำงาน
    //เตรียม LINE SDK ให้พร้อมใช้งาน
    //ใส่ Channel ID ที่ได้จาก LINE Developers เพื่อเชื่อมต่อกับแอป
    LineSDK.instance.setup("2008040716").then((_) {
      // .then((_) {...}) จะทำงานเมื่อ setup เสร็จสิ้น
      debugPrint("LINE SDK is ready!");
    });
  }

  // --- build: ฟังก์ชันหลักในการสร้างและแสดงผล UI ---
  // ฟังก์ชันนี้จะถูกเรียกใหม่ทุกครั้งที่มีการเปลี่ยนแปลง State (ผ่านคำสั่ง setState)
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('LINE Login Demo')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ถ้า Login แล้ว ให้แสดงข้อมูล Profile
              if (isLogin)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (userProfile?.pictureUrl != null)
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            userProfile!.pictureUrl!,
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        'hi, ${userProfile?.displayName ?? "user"}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // แสดงชื่อผู้ใช้ ถ้าไม่มีชื่อ ให้แสดงคำว่า "ผู้ใช้งาน"
                      Text(userProfile?.statusMessage ?? ""),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed:
                            startLogout, // เมื่อกดปุ่มให้เรียกฟังก์ชัน startLogout
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),

              // ถ้า isLogin เป็น false (ยังไม่ Login) ให้แสดง Widget ส่วนนี้
              if (!isLogin)
                ElevatedButton(
                  onPressed:
                      startLogin, // เมื่อกดปุ่มให้เรียกฟังก์ชัน startLogin
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    'LINE Login จิ้มตรงนี้นะจ๊ะ',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // --- ส่วนของฟังก์ชัน Logic (การทำงาน) ---
  void startLogin() async {
    try {
      // เรียกหน้าจอ Login ของ LINE
      // async/await: ใช้สำหรับการทำงานที่ต้องรอผลลัพธ์ (เช่น การเรียก API) โดยไม่ทำให้แอปค้าง
      // เรียกหน้าจอ Login ของ LINE ผ่าน SDK
      // scopes: คือการขออนุญาตเข้าถึงข้อมูลส่วนต่างๆ ของผู้ใช้
      // "profile": ข้อมูลพื้นฐาน (ชื่อ, รูป, สถานะ)
      // "openid", "email": สำหรับขอ ID และอีเมลของผู้ใช้
      final result = await LineSDK.instance.login(
        scopes: ["profile", "openid", "email"],
      );

      // ถ้า Login สำเร็จ จะได้ข้อมูลกลับมา
      // เมื่อ Login สำเร็จและได้ข้อมูลกลับมาแล้ว
      // เรียก setState() เพื่อสั่งให้ Flutter ทำการ "rebuild" UI ใหม่ด้วยข้อมูลล่าสุด
      setState(() {
        isLogin = true;
        userProfile = result.userProfile;
        userAccessToken = result.accessToken.value;
      });

      debugPrint('Login Success!');
      debugPrint('User ID: ${result.userProfile?.userId}');
      debugPrint('User Name: ${result.userProfile?.displayName}');
    } on Exception catch (e) {
      // try-catch: ดักจับข้อผิดพลาดที่อาจเกิดขึ้นระหว่างการ Login (เช่น ผู้ใช้กดยกเลิก, ไม่มีอินเทอร์เน็ต)
      debugPrint('Login Error: $e');
      setState(() {
        isLogin = false; // ถ้าเกิด Error ให้สถานะกลับเป็นยังไม่ Login
      });
    }
  }

  // ฟังก์ชันสำหรับ Logout
  void startLogout() async {
    try {
      await LineSDK.instance.logout();
      // เมื่อ Logout สำเร็จ
      // เรียก setState() เพื่ออัปเดต UI ให้กลับไปเป็นหน้ายังไม่ Login
      setState(() {
        isLogin = false;
        userProfile = null; // ล้างข้อมูล Profile
        userAccessToken = null; // ล้าง Access Token
      });
      debugPrint('Logout Success!');
    } on Exception catch (e) {
      debugPrint('Logout Error: $e');
    }
  }
}
