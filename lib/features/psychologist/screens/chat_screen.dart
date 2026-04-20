import 'package:flutter/material.dart';
import '../../../core/constants/color.dart';
import '../../../core/constants/mock_data.dart';
import '../../../shared/widgets/avatar.dart';

class PsychologistChatScreen extends StatefulWidget {
  const PsychologistChatScreen({super.key});

  @override
  State<PsychologistChatScreen> createState() => _PsychologistChatScreenState();
}

class _PsychologistChatScreenState extends State<PsychologistChatScreen> {
  dynamic selectedPatient;
  String searchQuery = '';
  final TextEditingController _messageController = TextEditingController();

  List<Map<String, dynamic>> messages = [
    {
      'id': '1',
      'text': 'Hola doctor, ¿cómo está?',
      'isMe': false,
      'time': '10:00 AM'
    },
    {
      'id': '2',
      'text': 'Hola, muy bien. ¿En qué puedo ayudarte?',
      'isMe': true,
      'time': '10:05 AM'
    },
  ];

  @override
  Widget build(BuildContext context) {
    if (selectedPatient != null) return _buildChatDetail();
    return _buildChatList();
  }

  Widget _buildChatList() {
    final filteredPatients = mockPatients.where((p) {
      final fullName = "${p.name} ${p.lastName}".toLowerCase();
      return fullName.contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader("Mensajes"),
            _buildSearchBar(),
            Expanded(
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: filteredPatients.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppColors.divider),
                itemBuilder: (context, index) {
                  final patient = filteredPatients[index];
                  final fullName = "${patient.name} ${patient.lastName}";
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    leading: Avatar(name: fullName, size: 'medium'),
                    title: Text(fullName,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text("Tengo una duda...",
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("10:00 AM",
                            style: TextStyle(
                                fontSize: 10, color: AppColors.textSecondary)),
                        SizedBox(height: 5),
                        CircleAvatar(
                            radius: 8,
                            backgroundColor: AppColors.primary,
                            child: Text("1",
                                style: TextStyle(
                                    fontSize: 8, color: Colors.white))),
                      ],
                    ),
                    onTap: () => setState(() => selectedPatient = patient),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatDetail() {
    final patientFullName =
        "${selectedPatient.name} ${selectedPatient.lastName}";
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => setState(() => selectedPatient = null),
        ),
        title: Row(
          children: [
            Avatar(name: patientFullName, size: 'small'),
            const SizedBox(width: 10),
            Text(patientFullName,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 16)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                bool isMe = msg['isMe'];
                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isMe ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(msg['text'],
                            style: TextStyle(
                                color:
                                    isMe ? Colors.white : AppColors.textPrimary,
                                fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(msg['time'],
                            style: TextStyle(
                                color: isMe
                                    ? Colors.white70
                                    : AppColors.textSecondary,
                                fontSize: 10)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.divider))),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: "Escribe un mensaje...",
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                if (_messageController.text.trim().isEmpty) return;
                setState(() {
                  messages.add({
                    'id': DateTime.now().toString(),
                    'text': _messageController.text,
                    'isMe': true,
                    'time': 'Justo ahora',
                  });
                  _messageController.clear();
                });
              },
              child: const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit_note)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        onChanged: (v) => setState(() => searchQuery = v),
        decoration: InputDecoration(
          hintText: "Buscar chat...",
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
