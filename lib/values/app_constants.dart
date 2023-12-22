import 'package:flutter/material.dart';

//URL DO MOCKAPI UTILIZADO PARA AUTENTICAR USUÁRIOS
const baseApi = 'https://6583352802f747c8367b427f.mockapi.io/api/v1/';

class AppConstants {
  AppConstants._();

  static final navigationKey = GlobalKey<NavigatorState>();

  static final RegExp emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  static final RegExp passwordRegex = RegExp(
    r'^[-a-zA-Z0-9-(){3,}]+(\s+[-a-zA-Z0-9-(){3,}]+)*$',
  );
}
