import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/iptv_service.dart';
import 'player_screen.dart';

class HomeScreen extends StatelessWidget {
  final IPTVService service;

  HomeScreen({required this.service});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: Color(0xFF1E1E1E),
          title: Text('IPTV Player Pro'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.live_tv), text: "مباشر"),
              Tab(icon: Icon(Icons.movie), text: "أفلام"),
              Tab(icon: Icon(Icons.tv), text: "مسلسلات"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildStreamGrid(service.getLiveStreams(), isLive: true),
            _buildStreamGrid(service.getMovies(), isLive: false),
            _buildStreamGrid(service.getSeries(), isLive: false),
          ],
        ),
      ),
    );
  }

  Widget _buildStreamGrid(Future<List<dynamic>> future, {required bool isLive}) {
    return FutureBuilder<List<dynamic>>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        final items = snapshot.data!;
        return GridView.builder(
          padding: EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 6 : 3,
            childAspectRatio: 0.7,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final String name = item['name'] ?? '';
            final String poster = item['stream_icon'] ?? item['cover'] ?? '';
            final int streamId = item['stream_id'] ?? item['series_id'] ?? 0;
            final String ext = item['container_extension'] ?? 'm3u8';

            return GestureDetector(
              onTap: () {
                String url = service.getStreamUrl(streamId, isLive ? 'm3u8' : ext);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PlayerScreen(streamUrl: url, title: name)),
                );
              },
              child: Card(
                color: Color(0xFF1E1E1E),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: poster.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: poster,
                              fit: BoxFit.cover,
                              errorWidget: (c, u, e) => Icon(Icons.tv, size: 50, color: Colors.white24),
                            )
                          : Container(color: Colors.black26, child: Icon(Icons.tv, size: 50, color: Colors.white24)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(6),
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
