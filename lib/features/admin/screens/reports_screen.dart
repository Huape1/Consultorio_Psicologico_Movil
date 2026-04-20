import 'dart:async'; // Necesario para el refresco automático opcional
import 'package:flutter/material.dart';
import '../../../core/constants/color.dart';
import '../../../core/api/api_service.dart';
import '../../../core/models/chat_models.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../shared/widgets/avatar.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ApiService _apiService = ApiService();
  final ChatRepository _chatRepo = ChatRepository();
  
  dynamic selectedChat;
  List<dynamic> _reportes = [];
  List<MessageModel> _messages = [];
  bool _isLoading = true;
  bool _isLoadingMessages = false;
  String searchQuery = ''; // Para el filtro
  final TextEditingController _msgController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchReportes();
  }

  // --- MÉTODOS DE DATOS ---

  // Refresca la lista de personas (contactos de soporte)
  Future<void> _fetchReportes() async {
    final data = await _apiService.getRequest('/admin/soporte/lista/');
    if (data != null) {
      setState(() {
        _reportes = data;
        _isLoading = false;
      });
    }
  }

  // Refresca los mensajes de un chat específico
  Future<void> _fetchMessages() async {
    if (selectedChat == null) return;
    // No ponemos _isLoadingMessages en true aquí para que el refresco sea fluido
    final data = await _apiService.getRequest('/admin/soporte/mensajes/?usuario_id=${selectedChat['id']}');
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
    final success = await _chatRepo.enviarMensaje(selectedChat['id'], text);
    if (success) _fetchMessages();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (selectedChat != null) {
          setState(() => selectedChat = null);
          _fetchReportes(); // Recargar lista al volver para limpiar contadores
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: selectedChat == null ? _buildListWithSearch() : _buildChatDetail(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(selectedChat == null ? "Soporte Técnico" : selectedChat['nombre'],
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
      backgroundColor: Colors.white,
      elevation: 0.5,
      actions: [
        if (selectedChat != null)
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _fetchMessages, // Botón para recargar mensajes manualmente
          ),
      ],
      leading: selectedChat != null 
        ? IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primary), 
            onPressed: () {
              setState(() => selectedChat = null);
              _fetchReportes(); // Actualiza la lista principal
            })
        : null,
    );
  }

  // VISTA DE LISTA CON BARRA DE BÚSQUEDA Y REFRESH
  Widget _buildListWithSearch() {
    // Lógica de filtrado
    final filteredReportes = _reportes.where((u) {
      final name = u['nombre'].toString().toLowerCase();
      return name.contains(searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchReportes, // Deslizar hacia abajo para recargar
            color: AppColors.primary,
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : filteredReportes.isEmpty 
                ? const Center(child: Text("No se encontraron mensajes"))
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: filteredReportes.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, indent: 70),
                    itemBuilder: (context, index) {
                      final report = filteredReportes[index];
                      return ListTile(
                        leading: report['foto'] != null 
                          ? CircleAvatar(backgroundImage: NetworkImage(report['foto']))
                          : Avatar(name: report['nombre'], size: 'medium'),
                        title: Text(report['nombre'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(report['ultimo_msg'], maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: _buildTrailing(report),
                        onTap: () {
                          setState(() => selectedChat = report);
                          _fetchMessages();
                        },
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        onChanged: (value) => setState(() => searchQuery = value),
        decoration: InputDecoration(
          hintText: "Buscar por nombre...",
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildTrailing(dynamic report) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(report['tiempo'], style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        if (report['unread_count'] > 0)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(10)),
            child: Text(report['unread_count'].toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }

  Widget _buildChatDetail() {
    return Column(
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
                  bool showDate = (index == _messages.length - 1) || (msg.fechaCompleta != _messages[index + 1].fechaCompleta);
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
    );
  }

  // --- REUTILIZACIÓN DE DISEÑO (Burbujas y Divisor) ---
  Widget _buildDateDivider(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(children: [
        const Expanded(child: Divider()),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold))),
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isMe ? 12 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 12),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2)],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(msg.texto, style: TextStyle(color: isMe ? Colors.white : AppColors.textPrimary)),
            Text(msg.hora, style: TextStyle(color: isMe ? Colors.white70 : AppColors.textSecondary, fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.divider))),
      child: Row(
        children: [
          Expanded(child: TextField(controller: _msgController, decoration: InputDecoration(hintText: "Responder soporte...", filled: true, fillColor: AppColors.background, border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none)))),
          IconButton(icon: const Icon(Icons.send, color: AppColors.primary), onPressed: _sendMessage),
        ],
      ),
    );
  }
}