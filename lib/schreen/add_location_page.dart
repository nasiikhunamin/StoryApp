import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:storyapp/export.dart';
import 'package:storyapp/route/location_page_manager.dart';
import 'package:storyapp/widget/snackbar_custom.dart';

class AddLocationPage extends StatefulWidget {
  final VoidCallback onSuccesStoryAdded;
  const AddLocationPage({
    super.key,
    required this.onSuccesStoryAdded,
  });

  @override
  State<AddLocationPage> createState() => _AddLocationPageState();
}

class _AddLocationPageState extends State<AddLocationPage> {
  late GoogleMapController _mapController;
  LatLng? _selectLocation;
  final Set<Marker> _marker = {};

  @override
  void dispose() {
    super.dispose();
    _mapController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.addLocationButton),
        actions: [
          if (_selectLocation != null) _selectButton(context),
        ],
      ),
      body: _body(context),
    );
  }

  Widget _selectButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        context.read<LocationPageManager>().returnData(_selectLocation!);
        widget.onSuccesStoryAdded();
      },
      icon: const Icon(Icons.check),
    );
  }

  Widget _body(BuildContext context) {
    return FutureBuilder(
      future: _getCurrentLocation(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return GoogleMap(
            initialCameraPosition:
                CameraPosition(target: snapshot.data!, zoom: 18),
            onMapCreated: _onMapCreated,
            onTap: _onMapTap,
            markers: _marker,
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Future<LatLng> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      if (mounted) {
        showCustomSnackbar(context, "Error Getting Current Location");
      }
      return const LatLng(0, 0);
    }
  }

  _onMapCreated(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
    });
  }

  _onMapTap(LatLng latLng) {
    setState(
      () {
        _selectLocation = latLng;
        _marker.clear();
        _marker.add(
          Marker(
            markerId: const MarkerId('selectedLocation'),
            position: latLng,
          ),
        );
      },
    );
  }
}
