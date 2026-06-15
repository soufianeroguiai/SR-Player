import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final s = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        leading: IconButton(
          icon: Icon(Symbols.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── المظهر ──────────────────────────────────────────────
          _SectionHeader('المظهر', Symbols.palette_rounded),
          _SettingsCard(children: [
            _ChoiceTile(
              icon: Symbols.dark_mode_rounded,
              title: 'المظهر',
              subtitle: _themeName(s.themeMode),
              onTap: () => _showThemePicker(context, s),
            ),
          ]),

          const SizedBox(height: 20),

          // ── المشغل ──────────────────────────────────────────────
          _SectionHeader('المشغل', Symbols.play_circle_rounded),
          _SettingsCard(children: [
            _SwitchTile(
              icon: Symbols.resume_rounded,
              title: 'تذكر موضع التشغيل',
              subtitle: 'متابعة الفيديو من آخر موضع',
              value: s.rememberPosition,
              onChanged: s.setRememberPosition,
            ),
            const Divider(height: 1, indent: 56),
            _SwitchTile(
              icon: Symbols.play_arrow_rounded,
              title: 'تشغيل تلقائي',
              subtitle: 'تشغيل الفيديو فور الفتح',
              value: s.autoPlay,
              onChanged: s.setAutoPlay,
            ),
            const Divider(height: 1, indent: 56),
            _ChoiceTile(
              icon: Symbols.speed_rounded,
              title: 'سرعة التشغيل الافتراضية',
              subtitle: '${s.defaultSpeed}x',
              onTap: () => _showSpeedPicker(context, s),
            ),
          ]),

          const SizedBox(height: 20),

          // ── الترجمة ─────────────────────────────────────────────
          _SectionHeader('الترجمة', Symbols.subtitles_rounded),
          _SettingsCard(children: [
            _SwitchTile(
              icon: Symbols.subtitles_rounded,
              title: 'إظهار الترجمة تلقائياً',
              subtitle: 'تفعيل الترجمة عند بدء التشغيل',
              value: s.showSubtitlesByDefault,
              onChanged: s.setShowSubtitlesByDefault,
            ),
          ]),

          const SizedBox(height: 20),

          // ── المكتبة ─────────────────────────────────────────────
          _SectionHeader('المكتبة', Symbols.video_library_rounded),
          _SettingsCard(children: [
            _ChoiceTile(
              icon: Symbols.sort_rounded,
              title: 'الترتيب الافتراضي',
              subtitle: _sortName(s.sortBy),
              onTap: () => _showSortPicker(context, s),
            ),
            const Divider(height: 1, indent: 56),
            _SwitchTile(
              icon: s.sortDesc
                  ? Symbols.arrow_downward_rounded
                  : Symbols.arrow_upward_rounded,
              title: 'ترتيب تنازلي',
              subtitle: 'من الأحدث/الأكبر إلى الأقدم/الأصغر',
              value: s.sortDesc,
              onChanged: s.setSortDesc,
            ),
            const Divider(height: 1, indent: 56),
            _SwitchTile(
              icon: Symbols.grid_view_rounded,
              title: 'عرض الشبكة',
              subtitle: 'عرض الفيديوهات كبطاقات مصغرة',
              value: s.gridView,
              onChanged: s.setGridView,
            ),
          ]),

          const SizedBox(height: 20),

          // ── عن التطبيق ──────────────────────────────────────────
          _SectionHeader('عن التطبيق', Symbols.info_rounded),
          _SettingsCard(children: [
            ListTile(
              leading: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: context.read<SettingsProvider>() != null
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Symbols.play_arrow_rounded,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 24),
              ),
              title: const Text('S-Player',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('الإصدار 1.0.0'),
            ),
          ]),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _themeName(ThemeMode m) {
    switch (m) {
      case ThemeMode.dark: return 'داكن';
      case ThemeMode.light: return 'فاتح';
      case ThemeMode.system: return 'تلقائي (نظام)';
    }
  }

  String _sortName(String s) {
    switch (s) {
      case 'name': return 'الاسم';
      case 'size': return 'الحجم';
      case 'duration': return 'المدة';
      default: return 'التاريخ';
    }
  }

  void _showThemePicker(BuildContext context, SettingsProvider s) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _BottomSheetTitle('اختر المظهر'),
            const Divider(height: 1),
            ...[
              (ThemeMode.dark, 'داكن', Symbols.dark_mode_rounded),
              (ThemeMode.light, 'فاتح', Symbols.light_mode_rounded),
              (ThemeMode.system, 'تلقائي (نظام)', Symbols.brightness_auto_rounded),
            ].map((item) => ListTile(
                  leading: Icon(item.$3),
                  title: Text(item.$2),
                  trailing: s.themeMode == item.$1
                      ? Icon(Symbols.check_rounded, color: cs.primary)
                      : null,
                  selected: s.themeMode == item.$1,
                  onTap: () {
                    s.setThemeMode(item.$1);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showSpeedPicker(BuildContext context, SettingsProvider s) {
    final cs = Theme.of(context).colorScheme;
    const speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _BottomSheetTitle('سرعة التشغيل الافتراضية'),
            const Divider(height: 1),
            ...speeds.map((sp) => ListTile(
                  title: Text('${sp}x'),
                  trailing: s.defaultSpeed == sp
                      ? Icon(Symbols.check_rounded, color: cs.primary)
                      : null,
                  selected: s.defaultSpeed == sp,
                  onTap: () {
                    s.setDefaultSpeed(sp);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showSortPicker(BuildContext context, SettingsProvider s) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _BottomSheetTitle('ترتيب حسب'),
            const Divider(height: 1),
            ...[
              ('date', 'التاريخ', Symbols.calendar_today_rounded),
              ('name', 'الاسم', Symbols.sort_by_alpha_rounded),
              ('size', 'الحجم', Symbols.data_usage_rounded),
              ('duration', 'المدة', Symbols.timer_rounded),
            ].map((item) => ListTile(
                  leading: Icon(item.$3),
                  title: Text(item.$2),
                  trailing: s.sortBy == item.$1
                      ? Icon(Symbols.check_rounded, color: cs.primary)
                      : null,
                  selected: s.sortBy == item.$1,
                  onTap: () {
                    s.setSortBy(item.$1);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }
}

// ── Shared Widgets ───────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader(this.title, this.icon);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: 8),
          Text(title,
              style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 0.4)),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final void Function(bool) onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: value
              ? cs.primaryContainer
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon,
            color: value ? cs.onPrimaryContainer : cs.onSurfaceVariant,
            size: 22),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(value: value, onChanged: onChanged),
      onTap: () => onChanged(!value),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ChoiceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: cs.onSurfaceVariant, size: 22),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(Symbols.chevron_right_rounded,
          color: cs.onSurfaceVariant, size: 20),
      onTap: onTap,
    );
  }
}

class _BottomSheetTitle extends StatelessWidget {
  final String title;
  const _BottomSheetTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
      child: Text(title,
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 16)),
    );
  }
}
