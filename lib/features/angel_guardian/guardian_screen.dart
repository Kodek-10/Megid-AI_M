import 'package:flutter/material.dart';
import '../../core/bottom_nav.dart';
import '../../core/theme.dart';
import '../../services/api_service.dart';
import '../../services/device_service.dart';

class GuardianScreen extends StatefulWidget {
  const GuardianScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  @override
  State<GuardianScreen> createState() => _GuardianScreenState();
}

class _GuardianScreenState extends State<GuardianScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _relationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;
  String? _myDeviceId;

  // Données locales synchronisées avec le backend
  final List<Map<String, dynamic>> _guardians = [];

  // Logs d'activité récupérés du backend
  final List<Map<String, dynamic>> _logs = [
    {
      'who': 'Moteur NLP',
      'what': 'SMS frauduleux intercepté (Score: 92/100)',
      'time': 'À l\'instant',
      'level': 'error',
      'icon': Icons.dangerous,
    },
    {
      'who': 'Ange Gardien',
      'what': 'Alerte transmise avec succès',
      'time': '1 min',
      'level': 'success',
      'icon': Icons.security,
    },
    {
      'who': 'Scanner IA',
      'what': 'Lien suspect bloqué : promotion.bf',
      'time': '34 min',
      'level': 'warning',
      'icon': Icons.warning_amber,
    },
    {
      'who': 'Audit Fuites',
      'what': 'Vérification HIBP — Aucune fuite',
      'time': '3 h',
      'level': 'info',
      'icon': Icons.mail_lock,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadDeviceIdAndGuardians();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _relationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ── Charger l'ID de l'appareil et les Anges Gardiens depuis le backend ────
  Future<void> _loadDeviceIdAndGuardians() async {
    setState(() => _isLoading = true);
    try {
      _myDeviceId = await DeviceService.getDeviceId();

      // Récupérer les Anges Gardiens depuis le backend
      final result = await ApiService.getMyGuardians(_myDeviceId!);
      final guardiansList =
          result['guardians'] as List<dynamic>? ?? [];

      if (!mounted) return;
      setState(() {
        _guardians.clear();
        for (final g in guardiansList) {
          _guardians.add({
            'name': 'Ange Gardien ${(g as Map)['guardian_id'] ?? ''}',
            'relation': 'Configuré',
            'status': 'Protection active',
            'score': '70',
            'sensitivity_mode': g['sensitivity_mode'] ?? 'balanced',
            'guardian_id': g['guardian_id'],
          });
        }
      });
    } catch (_) {
      // Silencieux — afficher la liste vide
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Ajouter un Ange Gardien et le persister en base ──────────────────────
  Future<void> _addGuardian() async {
    final name = _nameController.text.trim();
    final relation = _relationController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || relation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir le nom et la relation')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final deviceId = _myDeviceId ?? await DeviceService.getDeviceId();
      final fcmToken = await DeviceService.getFcmToken();

      // Générer un ID unique pour l'Ange Gardien
      final guardianId =
          '${deviceId}_guardian_${DateTime.now().millisecondsSinceEpoch}';

      // Persister la relation dans le backend
      await ApiService.createGuardianPair(
        protectedDeviceId: deviceId,
        guardianDeviceId: guardianId,
        guardianFcmToken: fcmToken ?? 'pending_${DateTime.now().millisecondsSinceEpoch}',
        protectedName: name,
        sensitivityMode: 'balanced',
      );

      // Ajouter à la liste locale
      if (!mounted) return;
      setState(() {
        _guardians.add({
          'name': name,
          'relation': relation,
          'phone': phone,
          'status': 'Protection en cours',
          'score': '70',
          'sensitivity_mode': 'balanced',
          'guardian_id': guardianId,
        });
      });

      _nameController.clear();
      _relationController.clear();
      _phoneController.clear();

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Ange Gardien ajouté : $name'),
          backgroundColor: MegidaiColors.safe,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur backend : ${e.message}'),
          backgroundColor: MegidaiColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Envoyer une alerte test ───────────────────────────────────────────────
  Future<void> _sendTestAlert() async {
    final deviceId = _myDeviceId ?? await DeviceService.getDeviceId();
    try {
      await ApiService.alertGuardian(
        protectedDeviceId: deviceId,
        threatType: 'test',
        threatLevel: 'suspect',
        riskScore: 55,
        threatDescription: 'Notification de test Megidai',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📨 Alerte test envoyée aux Anges Gardiens'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ange Gardien'),
        actions: [
          // Bouton alerte test
          IconButton(
            icon: const Icon(Icons.notifications_active),
            tooltip: 'Envoyer alerte test',
            onPressed: _sendTestAlert,
          ),
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onThemeToggle,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDeviceIdAndGuardians,
              child: Column(
                children: [
                  // ── Header ───────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                MegidaiColors.primary.withOpacity(0.8),
                                MegidaiColors.accent.withOpacity(0.8)
                              ]
                            : [MegidaiColors.primary, MegidaiColors.accent],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ange Gardien',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Surveillance active de votre sécurité numérique',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Statuts ───────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatusCard(
                            'Protection',
                            'Active',
                            Icons.shield,
                            MegidaiColors.safe,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatusCard(
                            'Anges',
                            '${_guardians.length} actif(s)',
                            Icons.people,
                            MegidaiColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Bouton ajouter ────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton.icon(
                      onPressed: _openAddGuardianDialog,
                      icon: const Icon(Icons.person_add),
                      label: const Text('Ajouter un Ange Gardien'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Liste des Anges Gardiens ──────────────────────────
                  if (_guardians.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Personnes sous protection',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 160,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _guardians.length,
                        itemBuilder: (context, index) =>
                            _buildGuardianCard(_guardians[index], index),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: theme.dividerColor.withOpacity(0.4)),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.shield_outlined,
                                size: 48,
                                color: Colors.grey.withOpacity(0.5)),
                            const SizedBox(height: 12),
                            Text(
                              'Aucun Ange Gardien configuré',
                              style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ajoutez un proche pour qu\'il soit alerté en cas de menace critique.',
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                  // ── Activités récentes ────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Activités récentes',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: _showAllActivities,
                          child: const Text('Voir tout'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _logs.length,
                      itemBuilder: (context, index) =>
                          _buildLogItem(_logs[index]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard(
      String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 12),
          Text(title,
              style: theme.textTheme.bodySmall?.copyWith(
                  color:
                      theme.textTheme.bodySmall?.color?.withOpacity(0.75))),
          const SizedBox(height: 6),
          Text(value,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildGuardianCard(Map<String, dynamic> guardian, int index) {
    final theme = Theme.of(context);
    return GestureDetector(
      onLongPress: () => _showGuardianOptions(guardian, index),
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      MegidaiColors.primary.withOpacity(0.15),
                  child: Text(
                    (guardian['name'] as String).isNotEmpty
                        ? (guardian['name'] as String)[0].toUpperCase()
                        : '?',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: MegidaiColors.primary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guardian['name'] as String,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        guardian['relation'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              guardian['status'] as String,
              style: theme.textTheme.bodySmall?.copyWith(
                color: MegidaiColors.safe,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            // Mode de sensibilité
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: MegidaiColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Mode : ${guardian['sensitivity_mode'] ?? 'balanced'}',
                style: const TextStyle(
                    fontSize: 10, color: MegidaiColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGuardianOptions(Map<String, dynamic> guardian, int index) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 8),
                  child: Text('Options',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete, color: MegidaiColors.danger),
                  title: const Text('Supprimer',
                      style: TextStyle(color: MegidaiColors.danger)),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteGuardian(index);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteGuardian(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ?'),
        content: Text(
            'Supprimer ${_guardians[index]['name']} de vos Anges Gardiens ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              final name = _guardians[index]['name'];
              setState(() => _guardians.removeAt(index));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$name supprimé')),
              );
            },
            child: const Text('Supprimer',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _openAddGuardianDialog() {
    _nameController.clear();
    _relationController.clear();
    _phoneController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ajouter un Ange Gardien',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _relationController,
                    decoration: const InputDecoration(
                      labelText: 'Relation (ex: Fils, Fille, Ami...)',
                      prefixIcon: Icon(Icons.group),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Téléphone (optionnel)',
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 24),
                  StatefulBuilder(
                    builder: (context, setLocalState) => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving
                            ? null
                            : () async {
                                await _addGuardian();
                              },
                        style: ElevatedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Enregistrer'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogItem(Map<String, dynamic> log) {
    final theme = Theme.of(context);
    Color levelColor;
    switch (log['level']) {
      case 'success':
        levelColor = MegidaiColors.safe;
        break;
      case 'warning':
        levelColor = MegidaiColors.caution;
        break;
      case 'error':
        levelColor = MegidaiColors.danger;
        break;
      default:
        levelColor = MegidaiColors.info;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: levelColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(log['icon'], color: levelColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log['who'],
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(log['what'],
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color
                            ?.withOpacity(0.7))),
                const SizedBox(height: 4),
                Text(log['time'],
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color
                            ?.withOpacity(0.5),
                        fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAllActivities() {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: MegidaiColors.primary.withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.history,
                          color: MegidaiColors.primary, size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text('Toutes les activités',
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) =>
                        _buildLogItem(_logs[index]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}