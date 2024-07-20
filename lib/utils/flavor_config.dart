import 'package:storyapp/utils/flavor_value.dart';
import 'package:storyapp/utils/helper.dart';

class FlavorConfig {
  final FlavorType flavor;
  final FlavorValue value;

  static FlavorConfig? _instance;

  FlavorConfig({
    this.flavor = FlavorType.free,
    this.value = const FlavorValue(),
  }) {
    _instance = this;
  }

  static FlavorConfig get instance => _instance ?? FlavorConfig();
}
