import 'package:flutter/material.dart';

class IconHelper {
  static IconData getIcon(String iconName) {
    switch (iconName) {
      case 'mobile_friendly': return Icons.mobile_friendly;
      case 'code': return Icons.code;
      case 'terminal': return Icons.terminal;
      case 'layers': return Icons.layers;
      case 'analytics': return Icons.analytics;
      case 'cloud': return Icons.cloud;
      case 'security': return Icons.security;
      case 'palette': return Icons.palette;
      case 'settings': return Icons.settings;
      case 'bolt': return Icons.bolt;
      case 'memory': return Icons.memory;
      case 'architecture': return Icons.architecture;
      case 'science': return Icons.science;
      case 'flight': return Icons.flight;
      case 'directions_car': return Icons.directions_car;
      case 'medical_services': return Icons.medical_services;
      case 'local_hospital': return Icons.local_hospital;
      case 'health_and_safety': return Icons.health_and_safety;
      case 'business_center': return Icons.business_center;
      case 'campaign': return Icons.campaign;
      case 'groups': return Icons.groups;
      case 'account_balance': return Icons.account_balance;
      case 'gavel': return Icons.gavel;
      case 'home_work': return Icons.home_work;
      case 'hotel': return Icons.hotel;
      case 'schema': return Icons.schema;
      case 'storage': return Icons.storage;
      default: return Icons.domain;
    }
  }
}
