import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HelpSupportView extends StatelessWidget {
  const HelpSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: const Text('Trợ giúp & Hỗ trợ', style: AppTextStyles.h3),
        backgroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: Get.back,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _Section(
            icon: Icons.contact_support_outlined,
            title: 'Liên hệ hỗ trợ',
            children: [
              _InfoRow(label: 'Email', value: 'support@foodhit.vn'),
              _InfoRow(label: 'Hotline', value: '1800 1234 (miễn phí)'),
              _InfoRow(label: 'Giờ làm việc', value: 'T2–T6, 8:00–17:30'),
            ],
          ),
          SizedBox(height: 16),
          _Section(
            icon: Icons.quiz_outlined,
            title: 'Câu hỏi thường gặp',
            children: [
              _FaqItem(
                question: 'Làm sao để thêm món ăn mới?',
                answer:
                    'Vào mục Thực đơn → nhấn nút "+" ở góc phải → điền thông tin và lưu.',
              ),
              _FaqItem(
                question: 'Làm sao để đổi trạng thái đơn hàng?',
                answer:
                    'Vào Đơn hàng → chọn đơn cần cập nhật → nhấn nút chuyển trạng thái.',
              ),
              _FaqItem(
                question: 'Tôi không nhận được thông báo đơn mới?',
                answer:
                    'Đảm bảo ứng dụng có quyền thông báo và đang kết nối internet ổn định.',
              ),
              _FaqItem(
                question: 'Làm sao để tạo mã khuyến mãi?',
                answer:
                    'Vào mục Khuyến mãi → nhấn "Thêm mới" → điền thông tin coupon và lưu.',
              ),
            ],
          ),
          SizedBox(height: 16),
          _Section(
            icon: Icons.info_outline,
            title: 'Thông tin ứng dụng',
            children: [
              _InfoRow(label: 'Phiên bản', value: 'v1.0.0'),
              _InfoRow(label: 'Nền tảng', value: 'Android / iOS'),
              _InfoRow(label: 'Nhà phát triển', value: 'Food Hit Team'),
            ],
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primaryOrange),
            const SizedBox(width: 8),
            Text(title.toUpperCase(),
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Text(label,
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey)),
          const Spacer(),
          Text(value, style: AppTextStyles.labelLarge),
        ],
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  const _FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Expanded(
                    child: Text(widget.question,
                        style: AppTextStyles.labelLarge)),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.grey600,
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.only(left: 16, right: 16, bottom: 13),
            child: Text(widget.answer,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textGrey)),
          ),
      ],
    );
  }
}
