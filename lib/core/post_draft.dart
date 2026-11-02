class PostDraft {
  PostDraft();
  factory PostDraft.fromPost(Map<String, String> post) => PostDraft()
    ..image = post['image'] ?? 'post'
    ..caption = post['caption'] ?? ''
    ..filter = int.tryParse(post['filter'] ?? '') ?? 0
    ..rotation = int.tryParse(post['rotation'] ?? '') ?? 0
    ..brightness = double.tryParse(post['brightness'] ?? '') ?? 0
    ..contrast = double.tryParse(post['contrast'] ?? '') ?? 1
    ..saturation = double.tryParse(post['saturation'] ?? '') ?? 1
    ..comments = post['comments'] != 'false';
  String image = 'post', caption = '', location = '', music = '', tag = '';
  int filter = 0, rotation = 0;
  double brightness = 0, contrast = 1, saturation = 1;
  bool comments = true, facebook = false, twitter = false;
  List<double> get matrix {
    final sat =
        saturation *
        (filter == 1
            ? 0.45
            : filter == 2
            ? 1.4
            : 1);
    final c = contrast;
    final offset = brightness * 100 + (1 - c) * 128;
    final r = .2126 * (1 - sat), g = .7152 * (1 - sat), b = .0722 * (1 - sat);
    return [
      (r + sat) * c,
      g * c,
      b * c,
      0,
      offset + (filter == 3 ? 15 : 0),
      r * c,
      (g + sat) * c,
      b * c,
      0,
      offset,
      r * c,
      g * c,
      (b + sat) * c,
      0,
      offset - (filter == 3 ? 12 : 0),
      0,
      0,
      0,
      1,
      0,
    ];
  }

  Map<String, String> toPost() => {
    'caption': caption.trim().isEmpty
        ? 'A moment worth sharing.'
        : caption.trim(),
    'image': image,
    'filter': '$filter',
    'rotation': '$rotation',
    'brightness': '$brightness',
    'contrast': '$contrast',
    'saturation': '$saturation',
    'location': location,
    'music': music,
    'tag': tag,
    'comments': '$comments',
  };
}
