import 'package:flutter/material.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import '../../src/colors/colors.dart';

class MyProgressDialog {
  static ProgressDialog? createProgressDialog (BuildContext context, String text){

    ProgressDialog progressDialog = ProgressDialog(
        context,
        type: ProgressDialogType.normal,
        isDismissible: false,
        showLogs: true
    );

    progressDialog.style(
        message: text,
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: const CircularProgressIndicator(color: primary),
        elevation: 10.0,
        insetAnimCurve: Curves.bounceInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: const TextStyle(
            color: primary, fontSize: 12.0, fontWeight: FontWeight.w400),
        messageTextStyle: const TextStyle(
            color: negroLetras, fontSize: 16.0, fontWeight: FontWeight.w500)
    );

    return progressDialog;

  }
}