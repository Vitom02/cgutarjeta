import 'package:hive/hive.dart';

part 'club.g.dart';

@HiveType(typeId: 11)
class Club {
  @HiveField(0)
  final String codigo;

  @HiveField(1)
  final String club;

  @HiveField(2)
  final String url;

  @HiveField(3)
  final String imagen;

  Club({
    this.codigo = '',
    this.club = '',
    this.url = '',
    this.imagen = '',
  });

  factory Club.fromJson(Map<String, dynamic> json) => Club(
        codigo: json["codigo"] ?? '',
        club: json["club"] ?? '',
        url: json["url"] ?? '',
        imagen: json["imagen"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "codigo": codigo,
        "club": club,
        "url": url,
        "imagen": imagen,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Club &&
          runtimeType == other.runtimeType &&
          codigo == other.codigo);

  @override
  int get hashCode => codigo.hashCode;
}

