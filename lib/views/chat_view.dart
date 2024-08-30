import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_chat/models/chat_message.dart';
import 'package:supabase_chat/providers/auth_provider.dart';
import 'package:supabase_chat/providers/chat_provider.dart';
import 'package:supabase_chat/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

final chatMessagesProvider = StreamProvider<List<ChatMessage>>(
  (ref) async* {
    var stream = Supabase.instance.client
        .from(kMessagesTable)
        .stream(primaryKey: [ChatMessage.idAndCreatedAtKeys().$1])
        .order(ChatMessage.idAndCreatedAtKeys().$2)
        .limit(20)
        .map(
          (data) {
            return data.map<ChatMessage>((it) => ChatMessage.fromMap(it)).toList();
          },
        );

    yield* stream;
  },
);

class HomeView extends HookConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textController = useTextEditingController();

    final message = useState<String?>(null);
    final attachment = useState<File?>(null);

    final liveChats = ref.watch(chatMessagesProvider);
    final user = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SUPABASE CHAT'),
        centerTitle: true,
        elevation: 0,
        actions: [
          CircleAvatar(
            backgroundColor: Colors.grey.withOpacity(.7),
            child: Text(
              user?.userMetadata!['displayName'][0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          //
          const SizedBox(width: 15),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: () {
              return switch (liveChats) {
                AsyncData(:final value) => () {
                    if (value.isEmpty) {
                      return const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.emoji_people, size: 40, color: Colors.grey),

                          //
                          SizedBox(height: 10),
                          //

                          Text(
                            'Feels so lonely here.... Please say hello.',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      reverse: true,
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        final message = value[index];

                        return _ChatMessageTile(message);
                      },
                    );
                  }(),
                AsyncError(:final error) => Text(error.toString()),
                _ => const Center(
                    child: CircularProgressIndicator(),
                  ),
              };
            }(),
          ),

          //
          if (attachment.value != null) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 60),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      SizedBox(
                        height: 80,
                        width: 80,
                        child: Image.file(attachment.value!, fit: BoxFit.cover),
                      ),

                      //
                      Positioned(
                        top: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () => attachment.value = null,
                          child: Container(
                            height: 25,
                            width: 25,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                            child: const Icon(
                              Icons.close,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            //
            const SizedBox(height: 15),
          ],

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: () async {
                    final imagePicker = ImagePicker();
                    final pickedFile = await imagePicker.pickImage(
                      source: ImageSource.camera,
                    );

                    if (pickedFile != null) {
                      attachment.value = File(pickedFile.path);
                    }
                  },
                ),

                //

                Expanded(
                  child: TextField(
                    controller: textController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Enter a nickname',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    onChanged: (it) => message.value = it.trim(),
                  ),
                ),

                //

                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: message.value == null || message.value!.isEmpty
                      ? null
                      : () async {
                          final chatMessage = ChatMessage(
                            id: const Uuid().v4(),
                            content: message.value!,
                            userId: user!.id,
                            userDisplayName: user.userMetadata!['displayName'],
                            createdAt: DateTime.now(),
                          );

                          ref.read(chatProvider.notifier).sendMessage(chatMessage, attachment: attachment.value);

                          message.value = null;
                          attachment.value = null;
                          textController.clear();
                        },
                ),
              ],
            ),
          ),

          //
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ChatMessageTile extends ConsumerWidget {
  const _ChatMessageTile(this.chatMessage);

  final ChatMessage chatMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final isMyMessage = chatMessage.userId == user!.id;

    return Padding(
      padding: EdgeInsets.zero.copyWith(left: isMyMessage ? 20 * 1.5 : 0, right: !isMyMessage ? 20 * 1.5 : 0, top: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (chatMessage.imagePath != null) ...[
            SizedBox(
              height: 80,
              width: 80,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network('$kBucketUrl${chatMessage.imagePath!}', fit: BoxFit.cover),
              ),
            ),

            //
            const SizedBox(height: 10),
          ],

          Column(
            crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  Visibility(
                    visible: !isMyMessage,
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(.1),
                      child: Text(
                        user.userMetadata!['displayName'][0].toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  //
                  const SizedBox(width: 10),
                  //

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: isMyMessage ? Theme.of(context).colorScheme.primary : Colors.grey[200],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    child: Text(
                      chatMessage.content,
                      style: TextStyle(
                        color: isMyMessage ? Colors.white : Colors.black,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              //
              Column(
                children: [
                  const SizedBox(height: 5),
                  //

                  Text.rich(
                    TextSpan(
                      text: 'from ${chatMessage.userDisplayName}',
                      children: [
                        TextSpan(
                          text: '  •  ${DateFormat('hh:mm a').format(chatMessage.createdAt)}',
                          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                    style: TextStyle(
                      color: isMyMessage ? Colors.grey : Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          //
          const SizedBox(height: 12),
          //
        ],
      ),
    );
  }
}
