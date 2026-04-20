import 'package:flutter/material.dart';
import '../../../core/constants/color.dart';
import '../../../core/models/chat_models.dart';
import '../../../data/repositories/chat_repository.dart';

class ChatScreen extends StatefulWidget {
  final int receptorId;
  final String nombre;

  const ChatScreen({super.key, required this.receptorId, required this.nombre});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ChatRepository _chatRepo = ChatRepository();
  List<MessageModel> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    final data = await _chatRepo.getMensajes(widget.receptorId);
    setState(() {
      // Invertimos la lista porque el ListView usa reverse: true
      _messages = data.reversed.toList(); 
      _isLoading = false;
    });
  }

  void _sendMessage() async {
    if (_msgController.text.trim().isEmpty) return;

    final texto = _msgController.text.trim();
    _msgController.clear();

    final success = await _chatRepo.enviarMensaje(widget.receptorId, texto);
    if (success) {
      _fetchMessages(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.nombre, 
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildChatList(), // <--- AQUÍ ESTABA EL ERROR, AHORA SÍ LLAMA A LA LISTA CON DIVISORES
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      reverse: true, 
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        
        bool showDateDivider = false;
        
        // Si es el último mensaje (el más viejo en el tiempo, arriba en la pantalla)
        if (index == _messages.length - 1) {
          showDateDivider = true;
        } else {
          // Comparamos fecha con el mensaje anterior en el tiempo (index + 1)
          final nextMsg = _messages[index + 1];
          if (msg.fechaCompleta != nextMsg.fechaCompleta) {
            showDateDivider = true;
          }
        }

        return Column(
          children: [
            if (showDateDivider) _buildDateDivider(msg.diaStr),
            _buildBubble(msg),
          ],
        );
      },
    );
  }

  Widget _buildDateDivider(String dateLabel) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          const Expanded(child: Divider(thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              dateLabel,
              style: const TextStyle(
                fontSize: 11, 
                fontWeight: FontWeight.w600, 
                color: AppColors.textSecondary
              ),
            ),
          ),
          const Expanded(child: Divider(thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildBubble(MessageModel msg) {
    bool isMe = msg.tipo == 'sent';
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1))],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg.texto, 
              style: TextStyle(color: isMe ? Colors.white : AppColors.textPrimary, fontSize: 15)
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  msg.hora, 
                  style: TextStyle(color: isMe ? Colors.white70 : AppColors.textSecondary, fontSize: 10)
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.done_all, size: 12, color: msg.leido ? Colors.lightBlueAccent : Colors.white70),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, -2))]
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _msgController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: "Escribe un mensaje...",
                  hintStyle: const TextStyle(fontSize: 14),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _sendMessage,
              child: const CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}