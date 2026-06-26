import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:coorent/controllers/auth_controller.dart';

class OtpView extends StatefulWidget {
  const OtpView({super.key});

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> {
  final AuthController _authController = Get.find<AuthController>();
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _verify() {
    String code = _controllers.map((c) => c.text).join();
    if (code.length == 6) {
      _authController.verifyOtpCode(code);
    } else {
      Get.snackbar('Error', 'Please enter a 6-digit OTP code');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Number'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                'Enter Verification Code',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'We have sent a 6-digit verification code to\n+91 ${_authController.mobileNumber.value}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          if (index < 5) {
                            FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                          } else {
                            _focusNodes[index].unfocus();
                          }
                        } else {
                          if (index > 0) {
                            FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
                          }
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              Obx(() {
                if (_authController.canResend.value) {
                  return TextButton(
                    onPressed: () {
                      _authController.sendOtpCode(_authController.mobileNumber.value);
                    },
                    child: const Text('Resend OTP'),
                  );
                } else {
                  return Text(
                    'Resend code in ${_authController.countdown.value}s',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  );
                }
              }),
              const Spacer(),
              Obx(() => ElevatedButton(
                    onPressed: _authController.isLoading.value ? null : _verify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _authController.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Verify Code',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  )),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
