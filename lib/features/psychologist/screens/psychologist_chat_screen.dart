import 'package:flutter/material.dart';
import '../../../core/constants/color.dart';
import '../../../core/models/chat_models.dart';
import '../../../data/repositories/chat_repository.dart'; // Asegúrate de tener enviarMensaje aquí
import '../../../core/api/api_service.dart';
import '../../../shared/widgets/avatar.dart';

class PsychologistChatScreen extends StatefulWidget {
  const PsychologistChatScreen({super.key});

  @override
  State<PsychologistChatScreen> createState() => _PsychologistChatScreenState();
}

class _PsychologistChatScreenState extends State<PsychologistChatScreen> {
  final ApiService _apiService = ApiService();
  final ChatRepository _chatRepo = ChatRepository();
  
  dynamic selectedChat; 
  String searchQuery = '';
  List<dynamic> _contactos = [];
  List<MessageModel> _messages = [];
  
  bool _isLoadingContactos = true;
  bool _isLoadingMessages = false;
  final TextEditingController _msgController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchContactos();
  }

  // --- MÉTODOS DE DATOS ---

  Future<void> _fetchContactos() async {
    final data = await _apiService.getRequest('/psicologo/contactos/');
    if (data != null) {
      setState(() {
        _contactos = data;
        _isLoadingContactos = false;
      });
    }
  }

  Future<void> _fetchMessages() async {
    if (selectedChat == null) return;
    setState(() => _isLoadingMessages = true);
    final data = await _apiService.getRequest('/psicologo/mensajes/?receptor_id=${selectedChat['id']}');
    if (data != null) {
      setState(() {
        _messages = (data as List).map((m) => MessageModel.fromJson(m)).toList().reversed.toList();
        _isLoadingMessages = false;
      });
    }
  }

  void _sendMessage() async {
    if (_msgController.text.trim().isEmpty) return;
    final text = _msgController.text.trim();
    _msgController.clear();

    // Reutilizamos el repositorio que ya tienes
    final success = await _chatRepo.enviarMensaje(selectedChat['id'], text);
    if (success) {
      _fetchMessages();
    }
  }

  // --- INTERFAZ ---

  @override
  Widget build(BuildContext context) {
    // Si hay un chat seleccionado, mostramos el detalle, si no, la lista.
    return WillPopScope(
      onWillPop: () async {
        if (selectedChat != null) {
          setState(() => selectedChat = null);
          return false;
        }
        return true;
      },
      child: selectedChat != null ? _buildChatDetail() : _buildChatList(),
    );
  }

  // PANTALLA 1: LISTA DE CONTACTOS
  Widget _buildChatList() {
    final filtered = _contactos.where((c) => 
      c['nombre'].toLowerCase().contains(searchQuery.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader("Mensajes"),
            _buildSearchBar(),
            Expanded(
              child: _isLoadingContactos 
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final chat = filtered[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                        leading: chat['foto'] != null 
                          ? CircleAvatar(backgroundImage: NetworkImage(chat['foto']))
                          : Avatar(name: chat['nombre'], size: 'medium'),
                        title: Text(chat['nombre'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(chat['ultimo_msg'], maxLines: 1, overflow: TextOverflow.ellipsis),
                        onTap: () {
                          setState(() => selectedChat = chat);
                          _fetchMessages();
                        },
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // PANTALLA 2: VENTANA DE CONVERSACIÓN
  Widget _buildChatDetail() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => setState(() => selectedChat = null),
        ),
        title: Row(
          children: [
            selectedChat['foto'] != null 
              ? CircleAvatar(radius: 18, backgroundImage: NetworkImage(selectedChat['foto']))
              : Avatar(name: selectedChat['nombre'], size: 'small'),
            const SizedBox(width: 10),
            Expanded(child: Text(selectedChat['nombre'], style: const TextStyle(color: AppColors.textPrimary, fontSize: 16))),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoadingMessages 
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    bool showDate = false;
                    if (index == _messages.length - 1) showDate = true;
                    else if (msg.fechaCompleta != _messages[index + 1].fechaCompleta) showDate = true;

                    return Column(
                      children: [
                        if (showDate) _buildDateDivider(msg.diaStr),
                        _buildBubble(msg),
                      ],
                    );
                  },
                ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildDateDivider(String label) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Row(children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
        ),
        const Expanded(child: Divider()),
      ]),
    );
  }

  Widget _buildBubble(MessageModel msg) {
    bool isMe = msg.tipo == 'sent';
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2)],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(msg.texto, style: TextStyle(color: isMe ? Colors.white : AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text(msg.hora, style: TextStyle(color: isMe ? Colors.white70 : AppColors.textSecondary, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _msgController,
                decoration: InputDecoration(
                  hintText: "Escribe un mensaje...",
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              backgroundColor: AppColors.primary,
              child: IconButton(icon: const Icon(Icons.send, color: Colors.white), onPressed: _sendMessage),
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
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Icon(Icons.chat_bubble_outline),
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
          hintText: "Buscar paciente...",
          prefixIcon: const Icon(Icons.search),
          filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}