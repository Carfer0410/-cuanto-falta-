#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Traducciones para agregar a todos los idiomas
translations = {
    'fr': {
        # CONFIGURACIÓN
        'appearance': 'Apparence',
        'theme': 'Thème',
        'lightTheme': 'Clair',
        'darkTheme': 'Mode sombre',
        'systemTheme': 'Système',
        'notifications': 'Notifications',
        'eventNotifications': 'Rappels d\'événements',
        'challengeNotifications': 'Notifications motivationnelles',
        'sound': 'Son',
        'vibration': 'Vibration',
        'about': 'À propos',
        'version': 'Version',
        'advancedSettings': 'Paramètres avancés',
        'eventFrequency': 'Fréquence de vérification des événements',
        'challengeFrequency': 'Fréquence de vérification des défis',
        'systemStatus': 'État du système',
        'notificationInfo': 'À propos des notifications',
        'soundEnabled': 'Jouer le son avec les notifications',
        'vibrationEnabled': 'Faire vibrer l\'appareil avec les notifications',
        'themeDescription': 'Basculer entre thème clair et sombre',

        # MENSAJES DE SNACKBAR - CONFIGURACIONES
        'eventsActivated': '✅ Notifications d\'événements activées',
        'eventsDeactivated': '🔕 Notifications d\'événements désactivées',
        'challengesActivated': '✅ Notifications de défis activées',
        'challengesDeactivated': '🔕 Notifications de défis désactivées',
        'soundActivated': '🔊 Son activé',
        'soundDeactivated': '🔇 Son désactivé',
        'vibrationActivated': '📳 Vibration activée',
        'vibrationDeactivated': '📴 Vibration désactivée',
        'eventFrequencyChanged': '⏱️ Fréquence d\'événements: toutes les {frequency} minutes',
        'challengeFrequencyChanged': '🎯 Fréquence de défis: toutes les {frequency} heures',
        'languageChanged': '🌍 Langue changée: {language}',
        'testNotificationSent': '🔔 Notification de test envoyée',

        # SUBTÍTULOS DE NOTIFICACIONES
        'eventNotificationSubtitleEnabled': 'Le système vérifie les événements toutes les {frequency} minutes pour envoyer des rappels opportuns',
        'eventNotificationSubtitleDisabled': 'Vous ne recevrez pas de rappels d\'événements',
        'challengeNotificationSubtitleEnabled': 'Le système vérifie les réussites toutes les {frequency} heures pour envoyer la motivation',
        'challengeNotificationSubtitleDisabled': 'Vous ne recevrez pas de notifications motivationnelles',

        # DIÁLOGO DE INFORMACIÓN DE NOTIFICACIONES
        'notificationInfoTitle': '📱 Informations sur les notifications',
        'eventRemindersTitle': '📅 Rappels d\'événements:',
        'eventRemindersDescription': '• Vous ne recevez des notifications qu\'aux moments clés: 30j, 15j, 7j, 3j, 1j avant et le jour de l\'événement\\n• Le système vérifie périodiquement mais n\'envoie PAS de spam',
        'motivationalNotificationsTitle': '🎯 Notifications motivationnelles:',
        'motivationalNotificationsDescription': '• Seulement quand vous atteignez des jalons: jour 1, jour 3, semaine 1, 2 semaines, mois 1, etc.\\n• Système anti-spam: chaque réussite n\'est notifiée qu\'UNE fois',
        'verificationFrequencyTitle': '⚙️ Fréquence de vérification:',
        'verificationFrequencyDescription': '• Contrôle la fréquence à laquelle le système recherche de nouveaux rappels\\n• Ne contrôle PAS la fréquence des notifications reçues\\n• Plus fréquent = détection plus rapide des événements à venir',
        'understood': 'Compris',

        # DIÁLOGO DE STATUS DEL SISTEMA
        'systemStatusTitle': '🔧 État du système',
        'eventSystemTitle': '📅 Système d\'événements:',
        'challengeSystemTitle': '🎯 Système de défis:',
        'audioConfigTitle': '🔊 Configuration audio:',
        'systemActive': '✅ En cours',
        'systemInactive': '❌ Arrêté',
        'frequencyEvery': 'Toutes les {frequency}',
        'minutesUnit': 'minutes',
        'hoursUnit': 'heures',
        'soundEnabledStatus': '✅ Activé',
        'soundDisabledStatus': '❌ Désactivé',
        'vibrationEnabledStatus': '✅ Activée',
        'vibrationDisabledStatus': '❌ Désactivée',
        'close': 'Fermer',
        'test': 'Tester',
        'testNotificationTitle': '🧪 Test du système',
        'testNotificationBody': 'Le système de notification fonctionne correctement.',

        # STATUS GENERAL DEL SISTEMA
        'eventsStatus': 'Événements',
        'challengesStatus': 'Défis',
        'active': '✅ Actif',
        'inactive': '❌ Inactif',
        'howNotificationsWork': 'Comment fonctionnent les rappels',
    },
    'de': {
        # CONFIGURACIÓN
        'appearance': 'Aussehen',
        'theme': 'Thema',
        'lightTheme': 'Hell',
        'darkTheme': 'Dunkler Modus',
        'systemTheme': 'System',
        'notifications': 'Benachrichtigungen',
        'eventNotifications': 'Ereigniserinnerungen',
        'challengeNotifications': 'Motivierende Benachrichtigungen',
        'sound': 'Ton',
        'vibration': 'Vibration',
        'about': 'Über',
        'version': 'Version',
        'advancedSettings': 'Erweiterte Einstellungen',
        'eventFrequency': 'Ereignisprüffrequenz',
        'challengeFrequency': 'Challenge-Prüffrequenz',
        'systemStatus': 'Systemstatus',
        'notificationInfo': 'Über Benachrichtigungen',
        'soundEnabled': 'Ton bei Benachrichtigungen abspielen',
        'vibrationEnabled': 'Gerät bei Benachrichtigungen vibrieren lassen',
        'themeDescription': 'Zwischen hellem und dunklem Thema wechseln',

        # MENSAJES DE SNACKBAR - CONFIGURACIONES
        'eventsActivated': '✅ Ereignisbenachrichtigungen aktiviert',
        'eventsDeactivated': '🔕 Ereignisbenachrichtigungen deaktiviert',
        'challengesActivated': '✅ Challenge-Benachrichtigungen aktiviert',
        'challengesDeactivated': '🔕 Challenge-Benachrichtigungen deaktiviert',
        'soundActivated': '🔊 Ton aktiviert',
        'soundDeactivated': '🔇 Ton deaktiviert',
        'vibrationActivated': '📳 Vibration aktiviert',
        'vibrationDeactivated': '📴 Vibration deaktiviert',
        'eventFrequencyChanged': '⏱️ Ereignisfrequenz: alle {frequency} Minuten',
        'challengeFrequencyChanged': '🎯 Challenge-Frequenz: alle {frequency} Stunden',
        'languageChanged': '🌍 Sprache geändert: {language}',
        'testNotificationSent': '🔔 Testbenachrichtigung gesendet',

        # SUBTÍTULOS DE NOTIFICACIONES
        'eventNotificationSubtitleEnabled': 'System prüft Ereignisse alle {frequency} Minuten für rechtzeitige Erinnerungen',
        'eventNotificationSubtitleDisabled': 'Sie erhalten keine Ereigniserinnerungen',
        'challengeNotificationSubtitleEnabled': 'System prüft Erfolge alle {frequency} Stunden für Motivation',
        'challengeNotificationSubtitleDisabled': 'Sie erhalten keine motivierenden Benachrichtigungen',

        # DIÁLOGO DE INFORMACIÓN DE NOTIFICACIONES
        'notificationInfoTitle': '📱 Benachrichtigungsinformationen',
        'eventRemindersTitle': '📅 Ereigniserinnerungen:',
        'eventRemindersDescription': '• Sie erhalten nur zu wichtigen Zeitpunkten Benachrichtigungen: 30T, 15T, 7T, 3T, 1T vorher und am Ereignistag\\n• Das System prüft regelmäßig, sendet aber KEINEN Spam',
        'motivationalNotificationsTitle': '🎯 Motivierende Benachrichtigungen:',
        'motivationalNotificationsDescription': '• Nur bei Meilensteinen: Tag 1, Tag 3, Woche 1, 2 Wochen, Monat 1, etc.\\n• Anti-Spam-System: jeder Erfolg wird nur EINMAL benachrichtigt',
        'verificationFrequencyTitle': '⚙️ Prüffrequenz:',
        'verificationFrequencyDescription': '• Steuert, wie oft das System nach neuen Erinnerungen sucht\\n• Steuert NICHT die Häufigkeit empfangener Benachrichtigungen\\n• Häufiger = schnellere Erkennung bevorstehender Ereignisse',
        'understood': 'Verstanden',

        # DIÁLOGO DE STATUS DEL SISTEMA
        'systemStatusTitle': '🔧 Systemstatus',
        'eventSystemTitle': '📅 Ereignissystem:',
        'challengeSystemTitle': '🎯 Challenge-System:',
        'audioConfigTitle': '🔊 Audiokonfiguration:',
        'systemActive': '✅ Läuft',
        'systemInactive': '❌ Gestoppt',
        'frequencyEvery': 'Alle {frequency}',
        'minutesUnit': 'Minuten',
        'hoursUnit': 'Stunden',
        'soundEnabledStatus': '✅ Aktiviert',
        'soundDisabledStatus': '❌ Deaktiviert',
        'vibrationEnabledStatus': '✅ Aktiviert',
        'vibrationDisabledStatus': '❌ Deaktiviert',
        'close': 'Schließen',
        'test': 'Testen',
        'testNotificationTitle': '🧪 Systemtest',
        'testNotificationBody': 'Das Benachrichtigungssystem funktioniert korrekt.',

        # STATUS GENERAL DEL SISTEMA
        'eventsStatus': 'Ereignisse',
        'challengesStatus': 'Challenges',
        'active': '✅ Aktiv',
        'inactive': '❌ Inaktiv',
        'howNotificationsWork': 'Wie Erinnerungen funktionieren',
    }
}

# Leer el archivo actual
with open('lib/localization_service.dart', 'r', encoding='utf-8') as f:
    content = f.read()

print("Archivo de script creado. Ejecutar manualmente las sustituciones.")
print("Francés - Claves a agregar:")
for key, value in translations['fr'].items():
    print(f"      '{key}': '{value}',")

print("\\nAlemán - Claves a agregar:")
for key, value in translations['de'].items():
    print(f"      '{key}': '{value}',")
