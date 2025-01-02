import 'package:flutter/material.dart';

class ChatDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('scholar', style: TextStyle(color: Colors.black)),
            Text('今日内在线', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              // 更多操作逻辑
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        margin: EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('你好！'),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        margin: EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '你好！',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 8),
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.mic, color: Colors.grey),
                  onPressed: () {
                    // 录音逻辑
                  },
                ),
                IconButton(
                  icon: Icon(Icons.emoji_emotions, color: Colors.grey),
                  onPressed: () {
                    // 表情功能逻辑
                  },
                ),
                IconButton(
                  icon: Icon(Icons.image, color: Colors.grey),
                  onPressed: () {
                    // 图片上传逻辑
                  },
                ),
                IconButton(
                  icon: Icon(Icons.add, color: Colors.grey),
                  onPressed: () {
                    // 其他附件功能逻辑
                  },
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '输入消息...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // 发送消息逻辑
                  },
                  child: Text('发送'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
