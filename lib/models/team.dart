import 'package:flutter/material.dart';

class Team {
  const Team({
    required this.id,
    required this.name,
    required this.principal,
    required this.description,
    required this.drivers,
    required this.base,
    required this.powerUnit,
    required this.color,
    required this.bannerAsset,
  });

  final String id;
  final String name;
  final String principal;
  final String description;
  final List<String> drivers;
  final String base;
  final String powerUnit;
  final Color color;
  final String bannerAsset;
}
