// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'picture_repo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductPicture _$ProductPictureFromJson(Map<String, dynamic> json) {
  return ProductPicture(
    json['product_picture'] as String,
  );
}

Map<String, dynamic> _$ProductPictureToJson(ProductPicture instance) =>
    <String, dynamic>{
      'product_picture': instance.imageURL,
    };
