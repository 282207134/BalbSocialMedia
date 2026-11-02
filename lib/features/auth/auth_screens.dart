import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/store.dart';
import '../../core/theme.dart';
import '../../shared/widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? timer;
  @override
  void initState() {
    super.initState();
    timer = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      final s = StoreScope.of(context);
      Navigator.pushReplacementNamed(
        context,
        s.signedIn
            ? '/home'
            : s.onboarded
            ? '/sign-in'
            : '/onboarding',
      );
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Photo('logo', width: 120, height: 120, radius: 10),
          SizedBox(height: 8),
          Text(
            'b a l b',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 40),
          ),
        ],
      ),
    ),
  );
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.initialPage = 0});
  final int initialPage;
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late int page = widget.initialPage;
  late final PageController controller = PageController(initialPage: page);
  static const titles = [
    'Share\nYour\nPassion.',
    'Connect\nWith\nLike-Minded.',
    'Discover.\nInspire.\nGrow.',
  ];
  void finish() {
    final s = StoreScope.of(context);
    s.onboarded = true;
    s.save();
    Navigator.pushReplacementNamed(context, '/sign-up');
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: controller,
              itemCount: 3,
              onPageChanged: (v) => setState(() => page = v),
              itemBuilder: (context, i) => LayoutBuilder(
                builder: (context, box) => SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Photo(
                        'onboarding_${i + 1}',
                        width: double.infinity,
                        height: box.maxHeight * .61,
                        fit: BoxFit.contain,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 26, 24, 12),
                        child: Text(
                          titles[i],
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: List.generate(
                3,
                (i) => Container(
                  margin: const EdgeInsets.only(right: 6),
                  width: i == page ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == page ? BalbColors.primary : BalbColors.line,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 64),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: page == 2
                ? PrimaryButton('Get Started', onPressed: finish)
                : Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: finish,
                          child: const Text(
                            'Skip',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: PrimaryButton(
                          'Next',
                          onPressed: () => controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    ),
  );
}

enum AuthStep {
  signIn,
  signUp,
  recovery,
  resetCode,
  newPassword,
  success,
  confirmation,
  name,
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.step});
  final AuthStep step;
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final form = GlobalKey<FormState>();
  final first = TextEditingController(),
      second = TextEditingController(),
      third = TextEditingController();
  final codes = List.generate(4, (_) => TextEditingController());
  final nodes = List.generate(4, (_) => FocusNode());
  String? codeError;
  @override
  void dispose() {
    for (final c in [first, second, third, ...codes]) {
      c.dispose();
    }
    for (final n in nodes) {
      n.dispose();
    }
    super.dispose();
  }

  bool get login => widget.step == AuthStep.signIn;
  bool get signup => widget.step == AuthStep.signUp;
  bool get isCode =>
      widget.step == AuthStep.confirmation || widget.step == AuthStep.resetCode;
  String? requiredValue(String? v) =>
      v == null || v.trim().isEmpty ? 'Please fill in this field' : null;
  String? validEmail(String? v) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v ?? '')
      ? null
      : 'Enter a valid email address';
  String? validPassword(String? v) =>
      (v?.length ?? 0) >= 8 ? null : 'Use at least 8 characters';
  void submit() {
    if (!form.currentState!.validate()) return;
    final s = StoreScope.of(context);
    if (isCode) {
      if (codes.map((c) => c.text).join() != '1234') {
        setState(() => codeError = 'Please enter the demo code 1234');
        return;
      }
      go(
        context,
        widget.step == AuthStep.confirmation ? '/setup-name' : '/new-password',
      );
      return;
    }
    switch (widget.step) {
      case AuthStep.signIn:
        s.signedIn = true;
        s.email = first.text.trim();
        s.save();
        home(context);
      case AuthStep.signUp:
        s.email = first.text.trim();
        s.save();
        go(context, '/confirmation');
      case AuthStep.recovery:
        s.email = first.text.trim();
        s.save();
        go(context, '/reset-code');
      case AuthStep.newPassword:
        FocusScope.of(context).unfocus();
        go(context, '/password-success');
      case AuthStep.name:
        s.name = first.text.trim();
        s.username = second.text.trim();
        s.save();
        go(context, '/complete-profile');
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = login || signup;
    final step = widget.step;
    if (step == AuthStep.success) return _success(context);
    final title = switch (step) {
      AuthStep.signIn => 'Sign in',
      AuthStep.signUp => 'Sign up',
      AuthStep.recovery => 'Password\nRecovery',
      AuthStep.resetCode => 'Verification\nCode',
      AuthStep.confirmation => 'Confirmation\nCode',
      AuthStep.newPassword => 'Set New\nPassword',
      _ => 'Add your name\nand username',
    };
    final description = switch (step) {
      AuthStep.signIn => 'Welcome back! Login with ease using your email, Facebook, or Google account.',
      AuthStep.signUp => 'Get started now by entering your email or connect with your Facebook or Google account.',
      AuthStep.recovery => 'Enter the email address linked to your account and we will send a detailed guide to reset your password.',
      AuthStep.newPassword =>
        'Your new password must be different from your previous password.',
      AuthStep.name =>
        'Let your friends find you easily by adding your name and username!',
      _ =>
        'We have just sent you a 4 digit code via your email\n${StoreScope.of(context).email}\nDemo code: 1234',
    };
    return PageFrame(
      title: auth
          ? null
          : (step == AuthStep.confirmation || step == AuthStep.name
                ? 'Account Setup'
                : 'Forgot Password'),
      bottom: auth
          ? null
          : PrimaryButton(
              step == AuthStep.newPassword
                  ? 'Change Password'
                  : isCode && step == AuthStep.resetCode
                  ? 'Verify Code'
                  : 'Next',
              onPressed: submit,
            ),
      child: Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: auth ? 54 : 24),
            Center(
              child: Photo(
                auth
                    ? 'logo'
                    : step == AuthStep.name
                    ? 'setup_name'
                    : step == AuthStep.confirmation
                    ? 'setup_code'
                    : 'setup_lock',
                width: 120,
                height: 120,
              ),
            ),
            SizedBox(height: auth ? 38 : 40),
            Text(
              title,
              style: auth
                  ? Theme.of(context).textTheme.headlineMedium
                  : Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(color: BalbColors.muted, height: 1.7),
            ),
            const SizedBox(height: 28),
            if (isCode) ...[
              Row(
                children: List.generate(
                  4,
                  (i) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i < 3 ? 12 : 0),
                      child: TextField(
                        controller: codes[i],
                        focusNode: nodes[i],
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: const InputDecoration(counterText: ''),
                        onChanged: (v) {
                          if (v.isNotEmpty && i < 3) {
                            nodes[i + 1].requestFocus();
                          }
                          if (v.isEmpty && i > 0) nodes[i - 1].requestFocus();
                        },
                      ),
                    ),
                  ),
                ),
              ),
              if (codeError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    codeError!,
                    style: const TextStyle(color: BalbColors.secondary),
                  ),
                ),
              Center(
                child: TextButton(
                  onPressed: () =>
                      toast(context, 'A new demo code is ready: 1234'),
                  child: const Text('Resend Code'),
                ),
              ),
            ] else if (step == AuthStep.name) ...[
              Field(
                'Full Name',
                icon: Icons.person_outline,
                controller: first,
                validator: requiredValue,
              ),
              Field(
                'Username',
                icon: Icons.badge_outlined,
                controller: second,
                validator: (v) =>
                    RegExp(r'^[a-zA-Z0-9_]{3,24}$').hasMatch(v ?? '')
                    ? null
                    : 'Use 3–24 letters, numbers or underscores',
              ),
            ] else ...[
              if (step != AuthStep.newPassword)
                Field(
                  'Email',
                  icon: Icons.mail_outline_rounded,
                  controller: first,
                  keyboardType: TextInputType.emailAddress,
                  validator: validEmail,
                ),
              if (step != AuthStep.recovery)
                Field(
                  'Password',
                  icon: Icons.lock_outline_rounded,
                  controller: second,
                  password: true,
                  validator: validPassword,
                ),
              if (signup || step == AuthStep.newPassword)
                Field(
                  'Re-Type Password',
                  icon: Icons.lock_outline_rounded,
                  controller: third,
                  password: true,
                  validator: (v) => v == second.text && (v?.isNotEmpty ?? false)
                      ? null
                      : 'Passwords do not match',
                ),
            ],
            if (auth) ...[
              if (login)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => go(context, '/recovery'),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: BalbColors.muted, fontSize: 12),
                    ),
                  ),
                ),
              if (signup)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: TextButton(
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: const Text('Terms & Privacy'),
                          content: const Text(
                            'This is an offline UI demonstration. Your profile and activity stay on this device. No account is created on a server.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(c),
                              child: const Text('Got it'),
                            ),
                          ],
                        ),
                      ),
                      child: const Text(
                        'By tapping “Sign up”, you agree to the Terms\nand Privacy Policy.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: BalbColors.muted),
                      ),
                    ),
                  ),
                ),
              PrimaryButton(login ? 'Sign in' : 'Sign up', onPressed: submit),
              const SizedBox(height: 22),
              const Center(child: Text('Or connect with')),
              const SizedBox(height: 22),
              Row(
                children: [
                  for (final provider in ['Google', 'Facebook'])
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: OutlinedButton(
                          onPressed: () => toast(
                            context,
                            '$provider sign-in needs a connected authentication service. Use email to try the demo.',
                          ),
                          child: Text(
                            provider == 'Google' ? 'G' : 'f',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: provider == 'Google'
                                  ? Colors.blue
                                  : const Color(0xff4089ff),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 38),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(
                    context,
                    login ? '/sign-up' : '/sign-in',
                  ),
                  child: Text(
                    login
                        ? 'Need to create an account? Sign up'
                        : 'Do you have an account? Sign in',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _success(BuildContext context) => PageFrame(
    title: 'Forgot Password',
    child: Padding(
      padding: const EdgeInsets.only(top: 120),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: BalbColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Photo('setup_lock', width: 120, height: 120),
            const SizedBox(height: 32),
            Text(
              'Your password has been reset',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            const Text(
              'Demo flow completed. Connect an authentication service to reset real account passwords.',
              textAlign: TextAlign.center,
              style: TextStyle(color: BalbColors.muted),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              'Sign in',
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/sign-in',
                (_) => false,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
