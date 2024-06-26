class VehicleManager {
  static VehicleManager? _instance;
  int? _id;
  VehicleManager._internal();

  static VehicleManager get instance {
    _instance ??= VehicleManager._internal();
    return _instance!;
  }

  void setId(int newId) => _id = newId;
  int? getId() => _id;
}
