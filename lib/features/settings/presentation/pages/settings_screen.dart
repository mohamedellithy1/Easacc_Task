import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/device_entity.dart';
import '../../../../core/utils/auth_utils.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _urlController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  DeviceEntity? _selectedDevice;

  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().loadSettings();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout(BuildContext context) async {
    await logout();
    if (context.mounted) context.go('/');
  }

  String _normalizeUrl(String url) {
    url = url.trim();
    if (url.isEmpty) return url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'https://$url';
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userName = currentUser?.displayName;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _handleLogout(context),
              tooltip: 'Logout',
            ),
          ],
        ),
        body: BlocConsumer<SettingsCubit, SettingsState>(
          listener: (context, state) {
            if (state is UrlSaved) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('URL Saved successfully'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
            } else if (state is SettingsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            } else if (state is SettingsLoaded) {
              if (_urlController.text.isEmpty && state.url != null) {
                _urlController.text = state.url!;
              }
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (userName != null && userName.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF667eea).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.white,
                              backgroundImage: currentUser?.photoURL != null
                                  ? NetworkImage(currentUser!.photoURL!)
                                  : null,
                              child: currentUser?.photoURL == null
                                  ? Text(
                                      userName[0].toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF667eea),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (currentUser?.email != null)
                                    Text(
                                      currentUser!.email!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    _buildUrlSection(context),
                    const SizedBox(height: 32),
                    _buildDeviceDiscoverySection(context, state),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        if (_urlController.text.isNotEmpty) {
                          final url = _normalizeUrl(_urlController.text);
                          _urlController.text = url;
                          context.push('/webview', extra: url);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a URL first'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onSecondary,
                      ),
                      child: const Text('Open WebView'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUrlSection(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuration',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'Website URL',
                hintText: 'https://example.com',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.link),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withOpacity(0.3),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a URL';
                }
                if (!Uri.parse(_normalizeUrl(value)).isAbsolute) {
                  return 'Please enter a valid URL';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final url = _normalizeUrl(_urlController.text);
                    _urlController.text = url;
                    context.read<SettingsCubit>().saveUrl(url);
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('Save URL'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceDiscoverySection(
    BuildContext context,
    SettingsState state,
  ) {
    List<DeviceEntity> devices = [];
    bool isLoading = false;

    if (state is SettingsLoaded) {
      devices = state.devices;
    } else if (state is SettingsLoading) {
      isLoading = true;
    }

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Device Discovery',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => context.read<SettingsCubit>().scanDevices(),
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  tooltip: 'Scan Devices',
                ),
              ],
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<DeviceEntity>(
              decoration: InputDecoration(
                labelText: 'Select Printer / Device',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.print),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withOpacity(0.3),
              ),
              value: _selectedDevice,
              hint: const Text('Select a device...'),
              items: devices.map((DeviceEntity device) {
                return DropdownMenuItem<DeviceEntity>(
                  value: device,
                  child: Text(
                    device.name.isNotEmpty ? device.name : device.id,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (DeviceEntity? newValue) {
                setState(() {
                  _selectedDevice = newValue;
                });
              },
              isExpanded: true,
            ),

            const SizedBox(height: 16),

            if (devices.isEmpty && !isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text('No devices found. Tap refresh to scan.'),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Discovered Devices:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: devices.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final device = devices[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: device.type == 'Bluetooth'
                              ? Colors.blue.withOpacity(0.2)
                              : Colors.green.withOpacity(0.2),
                          child: Icon(
                            device.type == 'Bluetooth'
                                ? Icons.bluetooth
                                : Icons.wifi,
                            color: device.type == 'Bluetooth'
                                ? Colors.blue
                                : Colors.green,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          device.name.isNotEmpty
                              ? device.name
                              : 'Unknown Device',
                        ),
                        subtitle: Text(device.id),
                        onTap: () {
                          setState(() {
                            _selectedDevice = device;
                          });
                        },
                        selected: _selectedDevice == device,
                        selectedTileColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withOpacity(0.3),
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
