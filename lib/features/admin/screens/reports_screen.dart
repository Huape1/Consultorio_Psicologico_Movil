import 'package:flutter/material.dart';
import '../../../core/constants/color.dart';
import '../../../core/constants/mock_data.dart';
import '../../../shared/widgets/avatar.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Reportes y Soporte",
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: ListView.separated(
        itemCount: mockReports.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, indent: 70),
        itemBuilder: (context, index) {
          final report = mockReports[index];
          return ListTile(
            leading: Avatar(name: report.user, size: 'medium'),
            title: Text(report.user,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(report.lastMessage,
                maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(report.timestamp,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textLight)),
                if (report.unreadCount > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(report.unreadCount.toString(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10)),
                  )
              ],
            ),
          );
        },
      ),
    );
  }
}
