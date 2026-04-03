abstract class MegidaiConstants {

  // ── URL du backend ────────────────────────────────────────────────────
  // Émulateur Android
  static const String backendUrl = 'http://10.0.2.2:8000';
  // Vrai téléphone → remplacer par l'IP locale de votre machine
  // static const String backendUrl = 'http://192.168.X.X:8000';

  // ── Endpoints ─────────────────────────────────────────────────────────
  static const String endpointScan      = '/reputation/scan';
  static const String endpointReport    = '/reputation/report';
  static const String endpointNlp       = '/nlp/analyze';
  static const String endpointGradients = '/federated/gradients';
  static const String endpointGuardian  = '/guardian/alert';

  // ── Seuils du feu tricolore ───────────────────────────────────────────
  static const int seuilVert   = 40;  // En dessous → VERT, ouverture directe
  static const int seuilOrange = 70;  // Entre 41-70 → ORANGE, demande confirmation
  // Au dessus de 70 → ROUGE, blocage automatique

  // ── Seuil d'alerte Ange Gardien ───────────────────────────────────────
  static const int seuilAlerte = 85;  // Score > 85 → notifier l'Ange Gardien

  // ── Durées ────────────────────────────────────────────────────────────
  static const Duration animFast   = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 400);
  static const Duration timeoutApi = Duration(seconds: 10);

  // ── Federated Learning ────────────────────────────────────────────────
  static const int maxSmsBatch = 50;  // Max SMS analysés au premier lancement
}
