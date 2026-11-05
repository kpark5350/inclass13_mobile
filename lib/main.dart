
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginApp(),
    );
  }
}

class LoginApp extends StatefulWidget {
  const LoginApp({super.key});

  @override
  State<LoginApp> createState() => _LoginAppState();
}

class _LoginAppState extends State<LoginApp> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();

  final Map<String, String> accounts = {};

  String? currentUser;
  bool registerPage = false;
  bool changePasswordPage = false;
  bool loading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void register() {
    String email = emailController.text.trim().toLowerCase();
    String password = passwordController.text;
    String confirm = confirmController.text;

    if (email.isEmpty || password.isEmpty || confirm.isEmpty) {
      showMessage('Please fill in all fields');
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      showMessage('Please enter a valid email');
      return;
    }

    if (password.length < 6) {
      showMessage('Password must be at least 6 characters');
      return;
    }

    if (password != confirm) {
      showMessage('Passwords do not match');
      return;
    }

    if (accounts.containsKey(email)) {
      showMessage('This email is already registered');
      return;
    }

    setState(() {
      loading = true;
    });

    accounts[email] = password;

    setState(() {
      currentUser = email;
      registerPage = false;
      loading = false;
    });

    passwordController.clear();
    confirmController.clear();

    showMessage('Account created successfully');
  }

  void login() {
    String email = emailController.text.trim().toLowerCase();
    String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showMessage('Please enter email and password');
      return;
    }

    if (!accounts.containsKey(email)) {
      showMessage('Account not found');
      return;
    }

    if (accounts[email] != password) {
      showMessage('Incorrect password');
      return;
    }

    setState(() {
      currentUser = email;
    });

    passwordController.clear();
    showMessage('Login successful');
  }

  void logout() {
    setState(() {
      currentUser = null;
      registerPage = false;
      changePasswordPage = false;
    });

    emailController.clear();
    passwordController.clear();
    oldPasswordController.clear();
    newPasswordController.clear();

    showMessage('Signed out successfully');
  }

  void updatePassword() {
    String oldPassword = oldPasswordController.text;
    String newPassword = newPasswordController.text;

    if (oldPassword.isEmpty || newPassword.isEmpty) {
      showMessage('Please fill in both fields');
      return;
    }

    if (accounts[currentUser] != oldPassword) {
      showMessage('Current password is incorrect');
      return;
    }

    if (newPassword.length < 6) {
      showMessage('New password must be at least 6 characters');
      return;
    }

    if (oldPassword == newPassword) {
      showMessage('Please choose a different password');
      return;
    }

    setState(() {
      accounts[currentUser!] = newPassword;
      changePasswordPage = false;
    });

    oldPasswordController.clear();
    newPasswordController.clear();

    showMessage('Password updated successfully');
  }

  Widget inputField(
    String label,
    TextEditingController controller, {
    bool hidden = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: hidden,
        keyboardType: hidden
            ? TextInputType.visiblePassword
            : label == 'Email'
                ? TextInputType.emailAddress
                : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget loginScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Auth Lab'),
        backgroundColor: Colors.blue.shade100,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.account_circle,
                  size: 75,
                  color: Colors.blue,
                ),
                const SizedBox(height: 15),
                Text(
                  registerPage ? 'Create Account' : 'Welcome Back',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  registerPage
                      ? 'Register a new account'
                      : 'Sign in to continue',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),
                inputField('Email', emailController),
                inputField(
                  'Password',
                  passwordController,
                  hidden: true,
                ),
                if (registerPage)
                  inputField(
                    'Confirm Password',
                    confirmController,
                    hidden: true,
                  ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: loading
                      ? null
                      : registerPage
                          ? register
                          : login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(15),
                  ),
                  child: Text(
                    registerPage ? 'Register' : 'Sign In',
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    setState(() {
                      registerPage = !registerPage;
                    });
                    passwordController.clear();
                    confirmController.clear();
                  },
                  child: Text(
                    registerPage
                        ? 'Already have an account? Sign In'
                        : 'Do not have an account? Register',
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Local demo - No Firebase connection',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget profileScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.blue.shade100,
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.account_circle,
                  size: 90,
                  color: Colors.blue,
                ),
                const SizedBox(height: 15),
                const Text(
                  'You are signed in!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Account Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 25),
                        const Text(
                          'Email Address',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          currentUser ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Account Status',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 5),
                        const Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text('Signed In'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      changePasswordPage = true;
                    });
                  },
                  child: const Text('Update Password'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: logout,
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget passwordScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Password'),
        backgroundColor: Colors.blue.shade100,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              changePasswordPage = false;
            });
            oldPasswordController.clear();
            newPasswordController.clear();
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 70,
                  color: Colors.blue,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Change Password',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                inputField(
                  'Current Password',
                  oldPasswordController,
                  hidden: true,
                ),
                inputField(
                  'New Password',
                  newPasswordController,
                  hidden: true,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: updatePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(15),
                  ),
                  child: const Text('Save New Password'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return loginScreen();
    }

    if (changePasswordPage) {
      return passwordScreen();
    }

    return profileScreen();
  }
}
