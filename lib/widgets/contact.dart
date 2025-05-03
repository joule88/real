// lib/widgets/contact_agent_widget.dart
import 'package:flutter/material.dart';

class ContactAgentWidget extends StatelessWidget {
  const ContactAgentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 60,
      decoration: BoxDecoration(
        color: Color(0xFFDDEF6D),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundImage: AssetImage('assets/girl.png'), // Ubah jika perlu
            radius: 20,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Anderson", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Real Estate Agent", style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chat_bubble_outline, size: 20),
        ],
      ),
    );
  }
}
