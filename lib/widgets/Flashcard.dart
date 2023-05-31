class FlashCard {
  String title;
  String content;

  FlashCard(this.title, this.content);

  Map<String, dynamic> toMap() {
    return {'title': title, 'content': content};
  }

  factory FlashCard.fromJson(Map<String, dynamic> map) {
    return FlashCard(map['title'], map['content']);
  }
}
