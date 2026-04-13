import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/supabase_config.dart';
import '../services/music_service.dart';
import 'login_screen.dart';
import 'order_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _musicEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _musicEnabled = MusicService.isPlaying;
  }

  Future<void> _loadUserData() async {
    final user = AuthService().currentUser;
    
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await SupabaseConfig.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      setState(() {
        _userData = response;
        _isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleMusic(bool value) async {
    setState(() {
      _musicEnabled = value;
    });
    if (value) {
      await MusicService.play();
    } else {
      await MusicService.stop();
    }
  }

  Future<void> _logout() async {
    await AuthService().logout();
    await MusicService.stop();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Color(0xFFf5f5dc),
        appBar: AppBar(
          title: Text('Profile', style: TextStyle(color: Color(0xFF5e2217))),
          backgroundColor: Color(0xFFf5f5dc),
          elevation: 0,
        ),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF5e2217))),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFf5f5dc),
      appBar: AppBar(
       
        backgroundColor: Color(0xFFf5f5dc),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF5e2217).withOpacity(0.1),
              child: Icon(Icons.person, size: 50, color: Color(0xFF5e2217)),
            ),
            SizedBox(height: 20),
            
            // User Info Card
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.person, color: Color(0xFF5e2217)),
                      title: Text('Full Name'),
                      subtitle: Text(_userData?['full_name'] ?? 'Not set'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.email, color: Color(0xFF5e2217)),
                      title: Text('Email'),
                      subtitle: Text(user?.email ?? 'No email'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.phone, color: Color(0xFF5e2217)),
                      title: Text('Phone'),
                      subtitle: Text(_userData?['phone'] ?? 'Not set'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            
            // Order History Button
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: Icon(Icons.history, color: Color(0xFF5e2217)),
                title: Text('Order History'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OrderHistoryScreen()),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            
            // Music Toggle
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: SwitchListTile(
                title: Text('Background Music'),
                subtitle: Text('Play classical music while browsing'),
                value: _musicEnabled,
                onChanged: _toggleMusic,
                activeColor: Color(0xFF5e2217),
                secondary: Icon(_musicEnabled ? Icons.music_note : Icons.music_off, color: Color(0xFF5e2217)),
              ),
            ),
            SizedBox(height: 30),
            
            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: Icon(Icons.logout),
                label: Text('Logout', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}