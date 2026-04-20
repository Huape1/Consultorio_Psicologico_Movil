import 'package:flutter/material.dart';
import '../../../core/constants/color.dart';
import '../../../shared/widgets/avatar.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Mensajes',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: "Buscar mensajes...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 5, // Aquí conectarías con mockMessages
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildChatItem(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Avatar(name: "Dr. Alejandro Pérez", size: 'medium'),
        title: const Text("Dr. Alejandro Pérez",
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text("Hola Andrea, ¿cómo te has sentido?",
            maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("12:45",
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            SizedBox(height: 4),
            CircleAvatar(
                radius: 8,
                backgroundColor: AppColors.primary,
                child: Text("1",
                    style: TextStyle(fontSize: 10, color: Colors.white))),
          ],
        ),
      ),
    );
  }
}
