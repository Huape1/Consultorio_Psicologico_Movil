import 'package:flutter/material.dart';
import '../../../core/constants/color.dart';
import '../../../core/models/chat_models.dart';
import '../../../data/repositories/chat_repository.dart';
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
  
  // selectedChat guardará el mapa del paciente o admin con el que se habla
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

  // --- LÓGICA DE DATOS (BACKEND) ---

  Future<void> _fetchContactos() async {
    try {
      final data = await _apiService.getRequest('/psicologo/contactos/');
      if (data != null) {
        setState(() {
          _contactos = data;
          _isLoadingContactos = false;
        });
      }
    } catch (e) {
      debugPrint("Error cargando contactos: $e");
      setState(() => _isLoadingContactos = false);
    }
  }

  Future<void> _fetchMessages() async {
    if (selectedChat == null) return;
    setState(() => _isLoadingMessages = true);
    try {
      final data = await _apiService.getRequest('/psicologo/mensajes/?receptor_id=${selectedChat['id']}');
      if (data != null) {
        setState(() {
          // Convertimos el JSON a modelos y lo invertimos para el scroll tipo chat
          _messages = (data as List)
              .map((m) => MessageModel.fromJson(m))
              .toList()
              .reversed
              .toList();
          _isLoadingMessages = false;
        });
      }
    } catch (e) {
      debugPrint("Error cargando mensajes: $e");
      setState(() => _isLoadingMessages = false);
    }
  }

  void _sendMessage() async {
    if (_msgController.text.trim().isEmpty) return;
    final text = _msgController.text.trim();
    _msgController.clear();

    final success = await _chatRepo.enviarMensaje(selectedChat['id'], text);
    if (success) {
      // Refrescamos la lista para ver el mensaje recién enviado
      _fetchMessages();
    }
  }

  // --- NAVEGACIÓN Y ESTRUCTURA ---

  @override
  Widget build(BuildContext context) {
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

  // VISTA 1: LISTADO DE PACIENTES Y SOPORTE
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider),
                    itemBuilder: (context, index) {
                      final chat = filtered[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        leading: chat['foto'] != null 
                          ? CircleAvatar(radius: 25, backgroundImage: NetworkImage(chat['foto']))
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

  // VISTA 2: CONVERSACIÓN ABIERTA
  Widget _buildChatDetail() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.primary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => selectedChat = null),
        ),
        title: Row(
          children: [
            selectedChat['foto'] != null 
              ? CircleAvatar(radius: 18, backgroundImage: NetworkImage(selectedChat['foto']))
              : Avatar(name: selectedChat['nombre'], size: 'small'),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                selectedChat['nombre'], 
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              )
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoadingMessages 
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  reverse: true, // Importante para que los mensajes nuevos aparezcan abajo
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    
                    // Lógica para mostrar separadores de fecha
                    bool showDate = false;
                    if (index == _messages.length - 1) {
                      showDate = true;
                    } else {
                      final nextMsg = _messages[index + 1];
                      if (msg.fechaCompleta != nextMsg.fechaCompleta) {
                        showDate = true;
                      }
                    }

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

  // --- COMPONENTES VISUALES ---

  Widget _buildDateDivider(String label) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Row(children: [
        const Expanded(child: Divider(thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        ),
        const Expanded(child: Divider(thickness: 1)),
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
            Text(msg.texto, style: TextStyle(color: isMe ? Colors.white : AppColors.textPrimary, fontSize: 15)),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(msg.hora, style: TextStyle(color: isMe ? Colors.white70 : AppColors.textSecondary, fontSize: 10)),
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

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Icon(Icons.mark_chat_unread_outlined, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: TextField(
        onChanged: (v) => setState(() => searchQuery = v),
        decoration: InputDecoration(
          hintText: "Buscar chat...",
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}