// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String mediaKitInitError(String error) {
    return 'Échec de l\'initialisation de MediaKit :\n$error';
  }

  @override
  String ffmpegInitError(Object error) {
    return 'Échec de l\'initialisation de FFmpeg :\n$error';
  }

  @override
  String settingsLoadError(Object error) {
    return 'Échec du chargement des paramètres :\n$error';
  }

  @override
  String get errorOccurredTitle => 'Désolé, une erreur est survenue';

  @override
  String get retryButton => 'Réessayer';

  @override
  String get requestingPermissions => 'Demande des autorisations...';

  @override
  String get permissionsRequiredTitle => 'Autorisations requises';

  @override
  String get permissionsRequiredBody =>
      'L\'application a besoin de l\'autorisation d\'accès aux médias pour afficher les vidéos.';

  @override
  String get grantPermissionsButton => 'Accorder les autorisations';

  @override
  String get skipButton => 'Ignorer';

  @override
  String get favoritesTitle => 'Favoris';

  @override
  String get noFavoriteVideos => 'Aucune vidéo favorite';

  @override
  String get languageSettingLabel => 'Langue';

  @override
  String get systemLanguageOption => 'Langue du système';

  @override
  String get arabicLanguageOption => 'Arabe';

  @override
  String get englishLanguageOption => 'Anglais';

  @override
  String get frenchLanguageOption => 'Français';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get generalSection => 'Général';

  @override
  String get appearanceOption => 'Apparence';

  @override
  String get languageOption => 'Langue';

  @override
  String get themeColorOption => 'Couleur de l\'application';

  @override
  String get themeColorSubtitle =>
      'Couleur principale de l\'interface (Material You)';

  @override
  String get playerSection => 'Lecteur';

  @override
  String get playbackSection => 'Lecture';

  @override
  String get autoPlayOption => 'Lecture automatique';

  @override
  String get resumePositionOption => 'Reprendre la dernière position';

  @override
  String get rememberSpeedOption => 'Mémoriser la vitesse';

  @override
  String get repeatModeOption => 'Mode répétition';

  @override
  String get repeatNone => 'Aucune';

  @override
  String get repeatVideo => 'Répéter la vidéo';

  @override
  String get repeatPlaylist => 'Répéter la liste';

  @override
  String get autoNextOption => 'Vidéo suivante automatique';

  @override
  String get autoPipOption => 'Picture-in-picture automatique';

  @override
  String get speedSection => 'Vitesse de lecture';

  @override
  String get defaultSpeedOption => 'Vitesse par défaut';

  @override
  String get rememberLastSpeedOption => 'Mémoriser la dernière vitesse';

  @override
  String get allow4xOption => 'Autoriser la vitesse jusqu\'à 4×';

  @override
  String get pitchCorrectionOption => 'Correction de la tonalité';

  @override
  String get videoDisplaySection => 'Affichage vidéo';

  @override
  String get defaultVideoModeOption => 'Mode par défaut';

  @override
  String get rememberVideoModeOption => 'Mémoriser le dernier mode';

  @override
  String get autoRotateOption => 'Rotation automatique';

  @override
  String get autoFullscreenOption => 'Plein écran automatique';

  @override
  String get keepScreenOnOption => 'Garder l\'écran allumé';

  @override
  String get gesturesSection => 'Gestes';

  @override
  String get gestureVolumeOption => 'Glisser pour le volume';

  @override
  String get gestureBrightnessOption => 'Glisser pour la luminosité';

  @override
  String get gestureSeekOption => 'Glisser pour avancer/reculer';

  @override
  String get tapToPauseOption => 'Appuyer pour pause';

  @override
  String get doubleTapOption => 'Double appui';

  @override
  String get longPressSpeedOption => 'Appui long = vitesse temporaire ×2';

  @override
  String get vibrateOnEndOption => 'Vibrer à la fin';

  @override
  String get seekSection => 'Recherche';

  @override
  String get seekDurationOption => 'Durée du saut';

  @override
  String get seekPreviewOption => 'Afficher l\'aperçu pendant le glissement';

  @override
  String get seekTimeOption => 'Afficher le temps pendant le glissement';

  @override
  String get uiSection => 'Interface du lecteur';

  @override
  String get autoHideControlsOption => 'Masquer automatiquement les boutons';

  @override
  String get hideDelayOption => 'Délai de masquage';

  @override
  String get showRemainingTimeOption => 'Afficher le temps restant';

  @override
  String get showElapsedTimeOption => 'Afficher le temps écoulé';

  @override
  String get showVideoTitleOption => 'Afficher le titre de la vidéo';

  @override
  String get showBatteryOption => 'Afficher la batterie';

  @override
  String get showClockOption => 'Afficher l\'horloge';

  @override
  String get playlistSection => 'Listes de lecture';

  @override
  String get continuousPlaybackOption => 'Lecture en continu';

  @override
  String get removeAfterPlaybackOption => 'Supprimer après lecture';

  @override
  String get rememberPlaylistOption => 'Mémoriser la dernière liste';

  @override
  String get savePlaylistOrderOption => 'Enregistrer l\'ordre de lecture';

  @override
  String get shufflePlaylistOption => 'Lecture aléatoire';

  @override
  String get energySection => 'Énergie';

  @override
  String get preventLockOption => 'Empêcher le verrouillage de l\'écran';

  @override
  String get reduceBrightnessOption => 'Réduire la luminosité en pause';

  @override
  String get stopAfterVideoOption => 'Arrêter après la fin de la vidéo';

  @override
  String get sleepTimerOption => 'Minuterie';

  @override
  String get sleepTimerDisabled => 'Désactivé';

  @override
  String sleepTimerMinutes(Object minutes) {
    return '$minutes min';
  }

  @override
  String get controlSection => 'Contrôle';

  @override
  String get volumeKeysSeekOption => 'Touches volume pour avancer';

  @override
  String get keyboardSupportOption => 'Prise en charge du clavier';

  @override
  String get gamepadSupportOption => 'Prise en charge de la manette';

  @override
  String get advancedSection => 'Avancé';

  @override
  String get decoderModeOption => 'Mode de décodage';

  @override
  String get fallbackSoftwareOption => 'Repli sur logiciel';

  @override
  String get lowLatencyOption => 'Lecture à faible latence';

  @override
  String get frameDroppingOption => 'Abandon d\'images';

  @override
  String get vsyncOption => 'VSync';

  @override
  String get loggingOption => 'Journalisation';

  @override
  String get showVideoInfoOption => 'Afficher les infos vidéo';

  @override
  String get audioSection => 'Audio';

  @override
  String get audioGeneralSection => 'Général';

  @override
  String get audioBoostOption => 'Amplification par défaut';

  @override
  String get audioBalanceOption => 'Balance';

  @override
  String get rememberVolumeOption => 'Mémoriser le volume par vidéo';

  @override
  String get resetVolumeOption => 'Réinitialiser le volume par vidéo';

  @override
  String get audioOutputSection => 'Sortie audio';

  @override
  String get audioOutputModeOption => 'Mode de sortie';

  @override
  String get autoBluetoothOption => 'Basculer automatiquement en Bluetooth';

  @override
  String get audioTracksSection => 'Pistes audio';

  @override
  String get preferredAudioLanguageOption => 'Langue audio préférée';

  @override
  String get equalizerSection => 'Égaliseur';

  @override
  String get equalizerEnabledOption => 'Activer l\'égaliseur';

  @override
  String get openEqualizerOption => 'Ouvrir l\'égaliseur graphique';

  @override
  String get equalizerBandsSubtitle => '10 bandes';

  @override
  String get audioSyncSection => 'Synchronisation audio';

  @override
  String get audioDelayOption => 'Délai audio (ms)';

  @override
  String get resetButton => 'Réinitialiser';

  @override
  String get audioProcessingSection => 'Traitement audio';

  @override
  String get surroundSoundOption => 'Son surround';

  @override
  String get surroundSoundSubtitle => 'Simulation surround virtuelle';

  @override
  String get bassBoostOption => 'Amplificateur de basses';

  @override
  String get bassBoostSubtitle => 'Amplifier les basses fréquences';

  @override
  String get subtitlesSection => 'Sous-titres';

  @override
  String get subAppearanceSection => 'Apparence';

  @override
  String get subPositionSection => 'Position';

  @override
  String get subBehaviorSection => 'Comportement';

  @override
  String get subCompatibilitySection => 'Compatibilité';

  @override
  String get fontSizeOption => 'Taille de police';

  @override
  String get fontFamilyOption => 'Police';

  @override
  String get subScaleOption => 'Échelle des sous-titres';

  @override
  String get lineSpacingOption => 'Interligne';

  @override
  String get maxLinesOption => 'Nombre max de lignes';

  @override
  String get wrapTextOption => 'Retour à la ligne';

  @override
  String get wrapTextSubtitle => 'Retour à la ligne automatique';

  @override
  String get letterSpacingOption => 'Espacement des lettres';

  @override
  String get wordSpacingOption => 'Espacement des mots';

  @override
  String get fontWeightOption => 'Poids de la police';

  @override
  String get fontWeightLight => 'Léger';

  @override
  String get fontWeightNormal => 'Normal';

  @override
  String get fontWeightSemiBold => 'Demi-gras';

  @override
  String get fontWeightBold => 'Gras';

  @override
  String get textOpacityOption => 'Opacité du texte';

  @override
  String get textColorOption => 'Couleur du texte';

  @override
  String get backgroundSwitch => 'Arrière-plan du texte';

  @override
  String get backgroundColorOption => 'Couleur d\'arrière-plan';

  @override
  String get backgroundOpacityOption => 'Opacité d\'arrière-plan';

  @override
  String get backgroundRadiusOption => 'Rayon d\'arrière-plan';

  @override
  String get outlineSwitch => 'Contour du texte';

  @override
  String get outlineSubtitle => 'Contour autour de chaque caractère';

  @override
  String get outlineColorOption => 'Couleur du contour';

  @override
  String get outlineWidthOption => 'Épaisseur du contour';

  @override
  String get outlineScaleOption => 'Échelle du contour';

  @override
  String get shadowSwitch => 'Ombre du texte';

  @override
  String get shadowSubtitle => 'Ombre derrière le texte';

  @override
  String get shadowColorOption => 'Couleur de l\'ombre';

  @override
  String get shadowOpacityOption => 'Opacité de l\'ombre';

  @override
  String get shadowOffsetXOption => 'Décalage horizontal';

  @override
  String get shadowOffsetYOption => 'Décalage vertical';

  @override
  String get shadowBlurOption => 'Flou de l\'ombre';

  @override
  String get backgroundSection => 'Arrière-plan';

  @override
  String get backgroundShapeOption => 'Forme de l\'arrière-plan';

  @override
  String get backgroundShapeRectangle => 'Rectangle';

  @override
  String get backgroundShapeRounded => 'Arrondi';

  @override
  String get backgroundShapeCapsule => 'Capsule';

  @override
  String get backgroundBorderSwitch => 'Bordure d\'arrière-plan';

  @override
  String get backgroundBorderColorOption => 'Couleur de la bordure';

  @override
  String get backgroundBorderWidthOption => 'Épaisseur de la bordure';

  @override
  String get backgroundPaddingOption => 'Marge intérieure';

  @override
  String get italicOption => 'Effet italique';

  @override
  String get italicSubtitle =>
      'Activer la police italique pour les sous-titres';

  @override
  String get resetAppearanceButton => 'Réinitialiser l\'apparence';

  @override
  String get positionOption => 'Position des sous-titres';

  @override
  String get positionTop => 'Haut';

  @override
  String get positionCenter => 'Centre';

  @override
  String get positionBottom => 'Bas';

  @override
  String get bottomMarginOption => 'Marge inférieure';

  @override
  String get horizontalMarginOption => 'Marge horizontale';

  @override
  String get verticalMarginOption => 'Marge verticale';

  @override
  String get safeAreaPaddingOption => 'Marge de sécurité';

  @override
  String get keepInsideVideoOption => 'Rester dans la vidéo';

  @override
  String get keepInsideVideoSubtitle =>
      'Empêcher les sous-titres de sortir des limites vidéo';

  @override
  String get respectNotchOption => 'Respecter l\'encoche';

  @override
  String get respectNotchSubtitle => 'Éviter la zone de l\'encoche';

  @override
  String get textDirectionOption => 'Direction du texte';

  @override
  String get textDirectionRTL => 'De droite à gauche';

  @override
  String get textDirectionLTR => 'De gauche à droite';

  @override
  String get resetPositionButton => 'Réinitialiser la position';

  @override
  String get autoShowSubtitlesOption =>
      'Afficher automatiquement les sous-titres';

  @override
  String get autoShowSubtitlesSubtitle => 'Activer au démarrage de la lecture';

  @override
  String get subtitleFolderOption => 'Dossier des sous-titres';

  @override
  String get subtitleEncodingOption => 'Encodage des caractères';

  @override
  String get preferredSubtitleLanguageOption => 'Langue de sous-titre préférée';

  @override
  String get defaultSyncOption => 'Synchronisation par défaut';

  @override
  String get scaleModeOption => 'Mode d\'échelle';

  @override
  String get scaleModeFixed => 'Taille fixe';

  @override
  String get scaleModeResolution => 'Par résolution';

  @override
  String get scaleModeWindow => 'Par fenêtre';

  @override
  String get scaleModeSmart => 'Intelligent (recommandé)';

  @override
  String get loadLastUsedOption => 'Charger le dernier sous-titre utilisé';

  @override
  String get hideWhenNoDialogOption => 'Masquer quand pas de dialogue';

  @override
  String get resetBehaviorButton => 'Réinitialiser le comportement';

  @override
  String get improveAnimationOption => 'Améliorer l\'animation de la police';

  @override
  String get complexTextOption => 'Rendu de texte complexe';

  @override
  String get improveSsaAssOption => 'Améliorer le rendu SSA/ASS';

  @override
  String get ignoreAssFontsOption => 'Ignorer les polices ASS';

  @override
  String get ignoreAssEffectsOption => 'Ignorer les effets ASS';

  @override
  String get unicodeSupportOption => 'Support Unicode complet';

  @override
  String get antiAliasingOption => 'Anti-crénelage';

  @override
  String get hdrSupportOption => 'Support HDR';

  @override
  String get resetCompatibilityButton => 'Réinitialiser la compatibilité';

  @override
  String get librarySection => 'Bibliothèque';

  @override
  String get sortByOption => 'Tri par défaut';

  @override
  String get sortDescOption => 'Ordre décroissant';

  @override
  String get libraryGridViewOption => 'Vue en grille de la bibliothèque';

  @override
  String get foldersGridViewOption => 'Vue en grille des dossiers';

  @override
  String get recentGridViewOption => 'Vue en grille des récents';

  @override
  String get hiddenFilesOption => 'Fichiers cachés';

  @override
  String get storageSection => 'Stockage';

  @override
  String get thumbnailCacheOption => 'Cache des miniatures';

  @override
  String get calculatingSize => 'Calcul en cours...';

  @override
  String get clearCacheButton => 'Effacer';

  @override
  String get backupSection => 'Sauvegarde';

  @override
  String get exportSettingsOption => 'Exporter les paramètres';

  @override
  String get importSettingsOption => 'Importer les paramètres';

  @override
  String get resetAllButton => 'Réinitialiser tous les paramètres';

  @override
  String get resetAllDialogTitle => 'Réinitialiser les paramètres';

  @override
  String get resetAllDialogBody =>
      'Voulez-vous vraiment réinitialiser tous les paramètres par défaut ?';

  @override
  String get cancelButton => 'Annuler';

  @override
  String get confirmResetButton => 'Réinitialiser';

  @override
  String get settingsSavedMessage => 'Paramètres restaurés';

  @override
  String get clearCacheDialogTitle => 'Effacer le cache des miniatures';

  @override
  String get clearCacheDialogBody =>
      'Toutes les miniatures en cache seront supprimées et régénérées à la prochaine ouverture de la bibliothèque.';

  @override
  String get cacheClearedMessage => 'Cache des miniatures effacé';

  @override
  String exportSuccessMessage(Object path) {
    return 'Paramètres enregistrés dans : $path';
  }

  @override
  String exportFailMessage(Object error) {
    return 'Échec de l\'exportation : $error';
  }

  @override
  String get importSuccessMessage => 'Paramètres importés avec succès';

  @override
  String importFailMessage(Object error) {
    return 'Échec de l\'importation : $error';
  }

  @override
  String get decoderAuto => 'Auto (recommandé)';

  @override
  String get decoderHW => 'HW+ (matériel)';

  @override
  String get decoderSW => 'SW (logiciel)';

  @override
  String get colorFormatYCbCr => 'YCbCr (défaut)';

  @override
  String get colorFormatRGBFull => 'RGB Full (couleurs vives)';

  @override
  String get colorFormatRGBLimited => 'RGB Limited';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeSystem => 'Système';

  @override
  String get sortByName => 'Nom';

  @override
  String get sortBySize => 'Taille';

  @override
  String get sortByDuration => 'Durée';

  @override
  String get sortByDate => 'Date';

  @override
  String get videoModeContain => 'Contenir';

  @override
  String get videoModeCover => 'Couvrir';

  @override
  String get videoModeFill => 'Remplir';

  @override
  String get videoModeStretch => 'Étirer';

  @override
  String get audioModeStereo => 'Stéréo';

  @override
  String get audioModeMono => 'Mono';

  @override
  String get audioModeSurround => 'Surround';

  @override
  String get equalizerDialogTitle => 'Égaliseur graphique';

  @override
  String get applyButton => 'Appliquer';

  @override
  String get appTitle => 'SR Player';

  @override
  String get libraryTab => 'Bibliothèque';

  @override
  String get myFilesTab => 'Mes fichiers';

  @override
  String get recentTab => 'Récents';

  @override
  String get personalTab => 'Personnel';

  @override
  String get collectionsTooltip => 'Collections';

  @override
  String get viewOptionsTooltip => 'Options d\'affichage et de tri';

  @override
  String get searchTooltip => 'Rechercher';

  @override
  String get favoritesLabel => 'Favoris';

  @override
  String get playlistLabel => 'Liste de lecture';

  @override
  String get queueLabel => 'File d\'attente';

  @override
  String get gridView => 'Grille';

  @override
  String get listView => 'Liste';

  @override
  String get descending => 'Décroissant';

  @override
  String get ascending => 'Croissant';

  @override
  String get noPreviousVideo => 'Aucune vidéo précédente';

  @override
  String selectedCount(Object selected, Object total) {
    return '$selected / $total sélectionné(s)';
  }

  @override
  String get shareFiles => 'Partager les fichiers';

  @override
  String hiddenFilesToast(Object count) {
    return '$count fichier(s) masqué(s)';
  }

  @override
  String get backToFolders => 'Retour aux dossiers';

  @override
  String videosCount(Object count) {
    return '$count vidéo(s)';
  }

  @override
  String get playVideo => 'Lire';

  @override
  String get videoInfo => 'Infos';

  @override
  String get addToFavorites => 'Ajouter aux favoris';

  @override
  String get removeFromFavorites => 'Retirer des favoris';

  @override
  String get addToPlaylist => 'Ajouter à la liste';

  @override
  String get alreadyInPlaylist => 'Déjà dans la liste';

  @override
  String get addedToPlaylist => 'Ajouté à la liste';

  @override
  String get alreadyInPlaylistToast => 'Fichier déjà dans la liste';

  @override
  String get renameFile => 'Renommer';

  @override
  String get share => 'Partager';

  @override
  String get copyPath => 'Copier le chemin';

  @override
  String get openInFileManager => 'Ouvrir dans le gestionnaire';

  @override
  String get hide => 'Masquer';

  @override
  String get unhide => 'Afficher';

  @override
  String get delete => 'Supprimer';

  @override
  String get playAll => 'Tout lire';

  @override
  String get shufflePlay => 'Lecture aléatoire';

  @override
  String get hideAll => 'Tout masquer';

  @override
  String get unhideAll => 'Tout afficher';

  @override
  String get deleteFolder => 'Supprimer le dossier';

  @override
  String get renameDialogTitle => 'Renommer';

  @override
  String get newNameHint => 'Nouveau nom';

  @override
  String get okButton => 'OK';

  @override
  String get deleteFileTitle => 'Supprimer le fichier';

  @override
  String deleteFileConfirm(Object name) {
    return 'Voulez-vous vraiment supprimer \"$name\" ?';
  }

  @override
  String get deleteFilesTitle => 'Supprimer les fichiers';

  @override
  String deleteFilesConfirm(Object count) {
    return 'Voulez-vous vraiment supprimer $count vidéo(s) ?';
  }

  @override
  String get deleteFolderTitle => 'Supprimer le dossier';

  @override
  String deleteFolderConfirm(Object count) {
    return 'Voulez-vous vraiment supprimer $count vidéo(s) ?';
  }

  @override
  String fileDeletedToast(Object name) {
    return '\"$name\" supprimé';
  }

  @override
  String filesDeletedToast(Object count) {
    return '$count vidéo(s) supprimée(s)';
  }

  @override
  String get renameSuccess => 'Renommé avec succès';

  @override
  String renameFailed(Object error) {
    return 'Échec du renommage : $error';
  }

  @override
  String get pathCopiedToast => 'Chemin copié';

  @override
  String get fileManagerError =>
      'Impossible d\'ouvrir le gestionnaire de fichiers';

  @override
  String get comingSoon => 'Bientôt disponible';

  @override
  String get cancel => 'Annuler';

  @override
  String hideFilesToast(Object count) {
    return '$count fichier(s) masqué(s)';
  }

  @override
  String folderVideosCount(Object count, Object size) {
    return '$count vidéo(s)  •  $size';
  }

  @override
  String get screenLocked => 'Écran verrouillé';

  @override
  String get colorAdjustment => 'Réglage des couleurs';

  @override
  String get playbackSpeed => 'Vitesse de lecture';

  @override
  String get speed => 'Vitesse';

  @override
  String get custom => 'Personnalisé';

  @override
  String get apply => 'Appliquer';

  @override
  String get sleepTimer => 'Minuteur';

  @override
  String get selectTimeMinutes => 'Sélectionnez la durée (minutes)';

  @override
  String get customMinute => 'Personnalisé (minute)';

  @override
  String get start => 'Démarrer';

  @override
  String resumeFrom(Object time) {
    return 'Reprendre à $time';
  }

  @override
  String get tapToStartFromBeginning => 'Appuyez pour revenir au début';

  @override
  String get subtitleSettings => 'Paramètres des sous-titres';

  @override
  String get audioSettings => 'Paramètres audio';

  @override
  String get more => 'Plus';

  @override
  String get playlistEditor => 'Éditeur de playlist';

  @override
  String get releaseToOpen => 'Relâchez pour ouvrir';

  @override
  String get slideToUnlock => 'Glissez pour déverrouiller →';

  @override
  String get subtitleLoaded => '✅ Sous-titre chargé';

  @override
  String subtitleLoadFailed(Object error) {
    return 'Échec du chargement du sous-titre : $error';
  }

  @override
  String get externalSubtitleRemoved => 'Sous-titre externe supprimé';

  @override
  String playerError(Object error) {
    return 'Impossible de lire le fichier : $error';
  }

  @override
  String statsResolution(Object height, Object res, Object width) {
    return 'Résolution : $width×$height ($res)';
  }

  @override
  String statsCodec(Object codec) {
    return 'Codec : $codec';
  }

  @override
  String statsFps(Object fps) {
    return 'Images par seconde : $fps fps';
  }

  @override
  String statsHdr(Object status) {
    return 'HDR : $status';
  }

  @override
  String statsHw(Object status) {
    return 'Accélération matérielle : $status';
  }

  @override
  String statsPosition(Object dur, Object pos) {
    return 'Position : $pos / $dur';
  }

  @override
  String statsSpeed(Object speed) {
    return 'Vitesse : ${speed}x';
  }

  @override
  String statsAudioDelay(Object delay) {
    return 'Délai audio : ${delay}s';
  }

  @override
  String statsSubSync(Object sync) {
    return 'Synchro sous-titres : ${sync}s';
  }

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get enabled => 'Activé';

  @override
  String get disabled => 'Désactivé';

  @override
  String get nightModeOn => 'Mode nuit activé';

  @override
  String get nightModeOff => 'Mode nuit désactivé';

  @override
  String get sleepTimerStopped => 'Lecture arrêtée par le minuteur';
}
