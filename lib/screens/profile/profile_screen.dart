import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/session_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    final me = session.profile;

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: me == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: (me.avatar != null && me.avatar!.isNotEmpty)
                      ? CachedNetworkImageProvider(me.avatar!)
                      : null,
                  child: (me.avatar == null || me.avatar!.isEmpty)
                      ? Text(me.name.isNotEmpty ? me.name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 28))
                      : null,
                ),
                const SizedBox(height: 16),
                Center(child: Text(me.name, style: Theme.of(context).textTheme.headlineSmall)),
                if (me.bio != null && me.bio!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Center(child: Text(me.bio!, textAlign: TextAlign.center)),
                ],
                const SizedBox(height: 24),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.monetization_on_outlined),
                    title: const Text('Монеты'),
                    trailing: Text('${me.coins}', style: Theme.of(context).textTheme.titleMedium),
                  ),
                ),
                if (me.telegramId != null)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.telegram),
                      title: const Text('Telegram привязан'),
                      subtitle: Text(me.telegramId!),
                    ),
                  )
                else
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.telegram),
                      title: const Text('Привязать Telegram'),
                      subtitle: const Text('Для уведомлений о новых сообщениях и постах'),
                      onTap: () {
                        // TODO: фаза 2 — deep-link на Telegram-бота для привязки уведомлений.
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text('Скоро')));
                      },
                    ),
                  ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () => context.read<SessionState>().logout(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Выйти'),
                ),
              ],
            ),
    );
  }
}
