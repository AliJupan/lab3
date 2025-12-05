class Category {
  String id;
  String name;
  String thumb;
  String description;

  Category({
    required this.id,
    required this.name,
    required this.thumb,
    required this.description,
  });

  Category.fromJson(Map<String, dynamic> data)
      : id = data['idCategory'],
        name = data['strCategory'],
        thumb = data['strCategoryThumb'],
        description = data['strCategoryDescription'].split(".")[0];

  Map<String, dynamic> toJson() => {
    'idCategory': id,
    'strCategory': name,
    'strCategoryThumb': thumb,
    'strCategoryDescription': description,
  };
}