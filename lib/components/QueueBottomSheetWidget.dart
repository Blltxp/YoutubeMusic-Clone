import 'package:flutter/material.dart';

class QueueBottomSheetWidget extends StatelessWidget {
  final List<dynamic> playlist;
  final int currentSongIndex;
  final Function(int, int) onReorder;
  final Function(int) onRemove;
  final Function(int) onTapSong;

  const QueueBottomSheetWidget({
    super.key,
    required this.playlist,
    required this.currentSongIndex,
    required this.onReorder,
    required this.onRemove,
    required this.onTapSong,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      itemCount: playlist.length,
      onReorder: onReorder,
      itemBuilder: (context, index) {
        final song = playlist[index];
        final isCurrentSong = index == currentSongIndex;
        return Dismissible(
          key: Key(song.id.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) => onRemove(index),
          child: ListTile(
            key: Key(song.id.toString()),
            leading: Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(song.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (isCurrentSong)
                  Positioned.fill(
                    child: Container(
                      decoration:
                          BoxDecoration(color: Colors.black.withOpacity(0.3)),
                      child: const Icon(Icons.volume_up,
                          color: Colors.white, size: 20),
                    ),
                  ),
              ],
            ),
            title: Text(
              song.name,
              style: TextStyle(
                color: isCurrentSong ? Colors.white : Colors.white70,
                fontWeight: isCurrentSong ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              song.artistName ?? '',
              style: TextStyle(
                  color: isCurrentSong ? Colors.white70 : Colors.white70),
            ),
            trailing: const Icon(Icons.drag_handle, color: Colors.white70),
            tileColor: isCurrentSong ? Colors.white.withOpacity(0.15) : null,
            onTap: () => onTapSong(index),
          ),
        );
      },
    );
  }
}
