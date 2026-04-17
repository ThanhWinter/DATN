import "package:flutter/material.dart";
import "package:core_ui/core_ui.dart";
import "package:get/get.dart";

import "../controllers/auth_controller.dart";

class LoginView extends GetView<AuthController> {
  LoginView({super.key});

  final TextEditingController _emailController =
      TextEditingController(text: "admin@mail.com");
  final TextEditingController _passwordController =
      TextEditingController(text: "123456");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              if (controller.errorMessage.value.isNotEmpty) ...[
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 8),
              ],
              PrimaryButton(
                label: "Login",
                isLoading: controller.isLoading.value,
                onPressed: () => controller.login(
                  email: _emailController.text.trim(),
                  password: _passwordController.text.trim(),
                ),
              ),
              const SizedBox(height: 16),
              if (controller.token.value.isNotEmpty)
                SelectableText("Token: ${controller.token.value}"),
            ],
          ),
        ),
      ),
    );
  }
}
