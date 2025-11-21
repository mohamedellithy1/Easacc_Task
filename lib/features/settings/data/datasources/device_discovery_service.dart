import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';
import '../../domain/entities/device_entity.dart';

abstract class DeviceDiscoveryService {
  Future<List<DeviceEntity>> scanDevices();
  Stream<List<DeviceEntity>> get deviceStream;
}

class DeviceDiscoveryServiceImpl implements DeviceDiscoveryService {
  List<DeviceEntity> _cachedNetworkDevices = [];

  @override
  Stream<List<DeviceEntity>> get deviceStream {
    return FlutterBluePlus.scanResults.map((results) {
      final bleDevices = results
          .where((r) => r.device.platformName.isNotEmpty)
          .map(
            (r) => DeviceEntity(
              id: r.device.remoteId.str,
              name: r.device.platformName,
              type: 'Bluetooth',
            ),
          )
          .toList();

      return [...bleDevices, ..._cachedNetworkDevices];
    });
  }

  Future<List<DeviceEntity>> scanMdnsDevices() async {
    List<DeviceEntity> devices = [];

    if (Platform.isIOS) {
      print('mDNS skipped on iOS');
      return [];
    }

    MDnsClient? client;

    try {
      final info = NetworkInfo();
      final String? ip = await info.getWifiIP();
      if (ip == null) {
        print('mDNS skipped: No WiFi connection');
        return [];
      }

      if (Platform.isAndroid) {
        await Permission.nearbyWifiDevices.request();
      }

      client = MDnsClient();
      await client.start();

      await for (final PtrResourceRecord ptr
          in client
              .lookup<PtrResourceRecord>(
                ResourceRecordQuery.serverPointer('_http._tcp.local'),
              )
              .handleError((error) {
                print('mDNS PtrRecord lookup error: $error');
                return;
              })) {
        try {
          await for (final SrvResourceRecord srv
              in client
                  .lookup<SrvResourceRecord>(
                    ResourceRecordQuery.service(ptr.domainName),
                  )
                  .handleError((error) {
                    print('mDNS SrvRecord lookup error: $error');
                    return;
                  })) {
            try {
              await for (final IPAddressResourceRecord ip
                  in client
                      .lookup<IPAddressResourceRecord>(
                        ResourceRecordQuery.addressIPv4(srv.target),
                      )
                      .handleError((error) {
                        print('mDNS IPAddress lookup error: $error');
                        return;
                      })) {
                devices.add(
                  DeviceEntity(
                    id: ip.address.address,
                    name: srv.target, 
                    type: 'mDNS',
                  ),
                );
              }
            } catch (e) {
              print('mDNS IP lookup iteration error: $e');
            }
          }
        } catch (e) {
          print('mDNS Srv lookup iteration error: $e');
        }
      }
    } catch (e) {
      print('mDNS scan error: $e');
    } finally {
      client?.stop();
    }

    return devices;
  }

  Future<List<DeviceEntity>> scanWifiNetworks() async {
    List<DeviceEntity> devices = [];
    try {
      if (Platform.isAndroid) {
        if (await Permission.location.request().isGranted) {
          final canScan = await WiFiScan.instance.canStartScan();
          if (canScan == CanStartScan.yes) {
            await WiFiScan.instance.startScan();
            final accessPoints = await WiFiScan.instance.getScannedResults();
            for (final ap in accessPoints) {
              if (ap.ssid.isNotEmpty) {
                devices.add(
                  DeviceEntity(id: ap.bssid, name: ap.ssid, type: 'WiFi'),
                );
              }
            }
          }
        }
      } else if (Platform.isIOS) {
      
        final info = NetworkInfo();

        try {
          final String? wifiName = await info.getWifiName();
          final String? wifiBSSID = await info.getWifiBSSID();

          print('iOS WiFi Debug - Name: $wifiName, BSSID: $wifiBSSID');

          if (wifiName != null &&
              wifiName.isNotEmpty &&
              wifiName != '<unknown ssid>' &&
              wifiName != 'null') {
            final cleanName = wifiName.replaceAll('"', '');
            devices.add(
              DeviceEntity(
                id: wifiBSSID ?? 'unknown',
                name: cleanName,
                type: 'WiFi (Connected)',
              ),
            );
            print('iOS WiFi: Connected to $cleanName');
          } else {
            print('iOS WiFi: No network info available. Check:');
            print('1. Location Services enabled in Settings > Privacy');
            print('2. Location permission granted for this app');
            print('3. "Access WiFi Information" capability enabled in Xcode');
          }
        } catch (e) {
          print('iOS WiFi Error: $e');
        }
      }
    } catch (e) {
      print('WiFi Scan error: $e');
    }
    return devices;
  }

  @override
  Future<List<DeviceEntity>> scanDevices() async {
    List<DeviceEntity> devices = [];

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 3));

      var scanResults = FlutterBluePlus.lastScanResults;
      for (ScanResult result in scanResults) {
        if (result.device.platformName.isNotEmpty) {
          devices.add(
            DeviceEntity(
              id: result.device.remoteId.str,
              name: result.device.platformName,
              type: 'Bluetooth',
            ),
          );
        }
      }
    } catch (e) {
      print('Bluetooth scan error: $e');
    }

    List<DeviceEntity> currentNetworkDevices = [];

    try {
      final mdnsDevices = await scanMdnsDevices();
      currentNetworkDevices.addAll(mdnsDevices);
      devices.addAll(mdnsDevices);
    } catch (e) {
      print('mDNS wrapper error: $e');
    }

    try {
      final wifiDevices = await scanWifiNetworks();
      for (var wifi in wifiDevices) {
        if (!devices.any((d) => d.id == wifi.id)) {
          currentNetworkDevices.add(wifi);
          devices.add(wifi);
        }
      }
    } catch (e) {
      print('WiFi wrapper error: $e');
    }

    try {
      final info = NetworkInfo();
      final String? ip = await info.getWifiIP();
      final String? wifiName = await info.getWifiName();
      final String? wifiBSSID = await info.getWifiBSSID();

      print('Network Info - IP: $ip, WiFi: $wifiName, BSSID: $wifiBSSID');

      if (ip != null) {
        final String subnet = ip.substring(0, ip.lastIndexOf('.'));

        String networkName = 'Unknown Network';
        if (wifiName != null &&
            wifiName.isNotEmpty &&
            wifiName != '<unknown ssid>' &&
            wifiName != 'null') {
          networkName = wifiName.replaceAll('"', '');
        }

        devices.add(
          DeviceEntity(
            id: wifiBSSID ?? subnet,
            name: networkName,
            type: 'WiFi Network',
          ),
        );
        currentNetworkDevices.add(devices.last);

        devices.add(
          DeviceEntity(id: ip, name: 'This Device ($ip)', type: 'Network'),
        );
        currentNetworkDevices.add(devices.last);

        devices.add(
          DeviceEntity(
            id: '$subnet.1',
            name: 'Router ($subnet.1)',
            type: 'Network',
          ),
        );
        currentNetworkDevices.add(devices.last);

        print(
          'Network - Added WiFi network "$networkName", current device, and router',
        );
      } else {
        print('Network - No IP available (not connected to WiFi)');
      }
    } catch (e) {
      print('Network info error: $e');
    }

    _cachedNetworkDevices = currentNetworkDevices;

    return devices;
  }
}
