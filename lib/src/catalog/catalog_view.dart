import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mapmyindia_gl/mapmyindia_gl.dart';
import 'package:smart_park/src/widgets/app_drawer.dart';
import 'catalog_controller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapmyindia_place_widget/mapmyindia_place_widget.dart';
import 'package:geocoding/geocoding.dart';

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
    late ELocation? eLocation;
    String selectedAddr = "";

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
                      mapController.easeCamera(CameraUpdate.newLatLngZoom(
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
              myLocationRenderMode: MyLocationRenderMode.NORMAL,
              onUserLocationUpdated: (location) => {
                mapController.easeCamera(CameraUpdate.newLatLngZoom(
                    LatLng(location.position.latitude,
                        location.position.longitude),
                    15))
              },
              onMapCreated: (map) async => {
                mapController = map,
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
              child: ElevatedButton(
                onPressed: () => {
                  openPlaceAutocomplete(PlaceOptions(
                          enableTextSearch: true,
                          saveHistory: true,
                          hint: "Search for Location near your destination"))
                      .then((value) => {
                            eLocation = value.eLocation,
                            print("===========> Elocation -------" +
                                json.encode(eLocation?.toJson())),
                            selectedAddr =
                                eLocation?.placeName.toString() ?? "",
                            selectedAddr = selectedAddr +
                                " " +
                                (eLocation?.placeAddress.toString() ?? ""),
                            if (selectedAddr != "")
                              {
                                print(
                                    "========== Searching coordinates for - " +
                                        selectedAddr.trim()),
                                locationFromAddress(selectedAddr.trim()).then(
                                    (response) {
                                  if (response.isNotEmpty) {
                                    print("====== Response =========" +
                                        json.encode(response.first.toJson()));
                                    mapController.moveCamera(
                                        CameraUpdate.newLatLngZoom(
                                            LatLng(response.first.latitude,
                                                response.first.longitude),
                                            15));
                                    mapController
                                        .addSymbol(SymbolOptions(
                                            geometry: LatLng(
                                                response.first.latitude,
                                                response.first.longitude)))
                                        .then((value) => symbol = value);
                                    // showModalBottomSheet(
                                    //     isScrollControlled: true,
                                    //     context: context,
                                    //     builder: (BuildContext context) {
                                    //       return Card(
                                    //           elevation: 12.0,
                                    //           shape: RoundedRectangleBorder(
                                    //               borderRadius:
                                    //                   BorderRadius.circular(
                                    //                       24)),
                                    //           margin: const EdgeInsets.all(0),
                                    //           child: Container(
                                    //             height: 350,
                                    //             color: Colors.grey,
                                    //             child: Column(
                                    //               children: <Widget>[
                                    //                 CustomDraggingHandle(),
                                    //                 const Text(
                                    //                   'Available Slots',
                                    //                   textAlign:
                                    //                       TextAlign.center,
                                    //                 ),
                                    //               ],
                                    //             ),
                                    //           ));
                                    //     });
                                  } else {
                                    print("Error response seems to be empty");
                                  }
                                }, onError: (e) {
                                  print("Error geocoding -----> " + e.code);
                                })
                              }
                            else
                              {
                                print("The selected place is not valid ----> " +
                                    selectedAddr.toString())
                              }
                          }),
                },
                style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    textStyle: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text("Search for a landmark"),
                    IconButton(
                      splashColor: Colors.grey,
                      icon: const Icon(Icons.search),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            DraggableScrollableSheet(
              initialChildSize: 0.08,
              minChildSize: 0.08,
              maxChildSize: 0.5,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  child: CustomScrollViewContent(),
                );
              },
            ),
          ],
        ));
  }
}

class CustomDraggingHandle extends StatelessWidget {
  const CustomDraggingHandle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5,
      width: 30,
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(16)),
    );
  }
}

/// Content of the DraggableBottomSheet's child SingleChildScrollView
class CustomScrollViewContent extends StatelessWidget {
  const CustomScrollViewContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 12.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
        ),
        child: CustomInnerContent(),
      ),
    );
  }
}

class CustomInnerContent extends StatelessWidget {
  const CustomInnerContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: 12),
        CustomDraggingHandle(),
        SizedBox(height: 16),
        Text("Search to see available slots"),
        SizedBox(height: 500),
      ],
    );
  }
}
