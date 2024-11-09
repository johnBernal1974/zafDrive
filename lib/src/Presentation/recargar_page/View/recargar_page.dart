import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../../colors/colors.dart';
import '../../commons_widgets/headers/header_text/header_text.dart';

class RecargarPage extends StatefulWidget {
  const RecargarPage({super.key});

  @override
  State<RecargarPage> createState() => _RecargarPageState();
}

class _RecargarPageState extends State<RecargarPage> {
  double _progress = 0;
  late InAppWebViewController inAppWebViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: negro, size: 30),
        title: headerText(
            text: "Recargar",
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: negro
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: Uri.parse('https://checkout.wompi.co/l/k4GDZD'),
            ),
            onWebViewCreated: (InAppWebViewController controller){
              inAppWebViewController = controller;
            },
            onProgressChanged:(InAppWebViewController controller, int progress) {
              setState(() {
                _progress = progress / 100;
              });

            },
          ),
          _progress < 1 ? LinearProgressIndicator(
            backgroundColor: grisMedio,
            minHeight: 8,
            value: _progress,
          ): const SizedBox()
        ],
      ),
    );
  }
}
