import 'package:flutter/material.dart';
import 'package:mapmyindia_gl/mapmyindia_gl.dart';
import 'package:smart_park/src/widgets/app_drawer.dart';
import 'catalog_controller.dart';
import 'package:geolocator/geolocator.dart';

/// Displays available slots near a location
///
/// When a user changes search location, catalog must be updated
class CatalogView extends StatelessWidget {
  const CatalogView({Key? key, required this.catalogController})
      : super(key: key);

  static const routeName = '/search';

  final CatalogController catalogController;

  @override
  Widget build(BuildContext context) {
    MapmyIndiaAccountManager.setMapSDKKey("c752c74239aca588d6cf0cc7de7534ad");
    MapmyIndiaAccountManager.setRestAPIKey("c752c74239aca588d6cf0cc7de7534ad");
    MapmyIndiaAccountManager.setAtlasClientId(
        "33OkryzDZsLb8-QzWo9aM22NjYYmM1YIyoheisVigwwu5WSHecjuI_sYdrdyvMk3oExXAT7Xld7R_Wgvj1_jrILq6cCklgBx");
    MapmyIndiaAccountManager.setAtlasClientSecret(
        "lrFxI-iSEg8uudAfeRkIP0rhghQtn9fSaXqWbM2MMVhSRUKzbQHc0heTeBN7l-hM8cpMXS2FSiJtrp5VKRXk3MHkph0ljWtl5orCgQm_--4=");

    // Geolocator geolocator = Geolocator()..forceAndroidLocationManager = true;

    late MapmyIndiaMapController mapController;
    late Symbol symbol;
    var userLocationLatLng = LatLng(30.7410517, 76.779015);

    return Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(title: const Text("SmartPark")),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await catalogController
                .determinePosition()
                .then((value) => {
                      userLocationLatLng =
                          LatLng(value.latitude, value.longitude),
                      mapController.moveCamera(CameraUpdate.newLatLngZoom(
                          LatLng(userLocationLatLng.latitude,
                              userLocationLatLng.longitude),
                          15))
                    })
                .catchError((error) => throw error);
          },
          backgroundColor: Colors.blueGrey,
          child: const Icon(Icons.location_searching_sharp),
        ),
        body: Stack(
          children: [
            MapmyIndiaMap(
              initialCameraPosition: CameraPosition(
                target: userLocationLatLng,
                zoom: 15.0,
              ),
              myLocationEnabled: true,
              myLocationTrackingMode: MyLocationTrackingMode.TrackingCompass,
              myLocationRenderMode: MyLocationRenderMode.COMPASS,
              onUserLocationUpdated: (location) => {
                mapController.moveCamera(CameraUpdate.newLatLngZoom(
                    LatLng(location.position.latitude,
                        location.position.longitude),
                    15))
              },
              onMapCreated: (map) => {
                mapController = map,
                // showModalBottomSheet<void>(
                //     shape: RoundedRectangleBorder(
                //         borderRadius:
                //             BorderRadius.vertical(top: Radius.circular(20.0))),
                //     isScrollControlled: true,
                //     isDismissible: false,
                //     context: context,
                //     builder: (BuildContext context) {
                //       return SingleChildScrollView(
                //           child: Container(
                //         height: 350,
                //         color: Colors.grey,
                //         child: Column(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           mainAxisSize: MainAxisSize.min,
                //           children: <Widget>[
                //             const Text('Available Slots'),
                //           ],
                //         ),
                //       ));
                //     })
              },
              onMapClick: (point, latlng) async => {
                mapController.removeSymbol(symbol),
                symbol = await mapController.addSymbol(SymbolOptions(
                    geometry: LatLng(latlng.latitude, latlng.longitude))),
              },
            ),
            Positioned(
              top: 10,
              right: 15,
              left: 15,
              child: Container(
                color: Colors.white,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.go,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 15),
                            hintText: "Search landmark"),
                      ),
                    ),
                    IconButton(
                      splashColor: Colors.grey,
                      icon: const Icon(Icons.search),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
