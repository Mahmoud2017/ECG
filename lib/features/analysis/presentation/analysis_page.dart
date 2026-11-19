import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/di/injector.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/common.dart';
import '../../history/presentation/patients_cubit.dart';
import '../data/ecg_analysis.dart';
import 'analysis_cubit.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => AnalysisCubit(sl(), sl()),
        child: const _AnalysisView(),
      );
}

class _AnalysisView extends StatefulWidget {
  const _AnalysisView();

  @override
  State<_AnalysisView> createState() => _AnalysisViewState();
}

class _AnalysisViewState extends State<_AnalysisView> {
  static const _leads = ['12-lead', '6-lead', '3-lead', 'Single lead'];
  static const _rates = [250, 500, 1000];

  final _form = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _age = TextEditingController();
  final _notes = TextEditingController();
  String? _filePath;
  String? _fileName;
  String _sex = 'male';
  String _lead = _leads.first;
  int _rate = 500;

  @override
  void dispose() {
    _code.dispose();
    _age.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _generateCode() {
    final r = Random();
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    _code.text = 'P-${List.generate(6, (_) => chars[r.nextInt(chars.length)]).join()}';
  }

  Future<void> _pickFromFiles() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['dcm', 'pdf', 'jpg', 'jpeg', 'png', 'xml'],
    );
    final f = res?.files.single;
    if (f?.path != null) _setFile(f!.path!, f.name);
  }

  Future<void> _pickFromCamera() async {
    final img = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 95);
    if (img != null) _setFile(img.path, img.name);
  }

  void _setFile(String path, String name) => setState(() {
        _filePath = path;
        _fileName = name;
      });

  void _comingSoon() => showAppDialog(
        context,
        title: context.tr('coming_soon'),
        message: context.tr('coming_soon_body'),
        icon: Icons.hourglass_top_rounded,
      );

  void _run() {
    if (_filePath == null) {
      showSnack(context, 'error_no_file', error: true);
      return;
    }
    if (!_form.currentState!.validate()) return;
    context.read<AnalysisCubit>().run(AnalysisRequest(
          filePath: _filePath!,
          patientCode: _code.text.trim(),
          age: int.parse(_age.text.trim()),
          sex: _sex,
          leadConfiguration: _lead,
          samplingRate: _rate,
          notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AnalysisCubit, AnalysisState>(
      listener: (context, state) {
        if (state.status == AnalysisStatus.success) {
          sl<PatientsCubit>().load();
          context.push(Routes.analysisResult, extra: state.patient);
          setState(() {
            _filePath = _fileName = null;
            _code.clear();
            _age.clear();
            _notes.clear();
          });
          context.read<AnalysisCubit>().reset();
        } else if (state.status == AnalysisStatus.failure) {
          showSnack(context, state.error ?? 'error_generic', error: true);
        }
      },
      builder: (context, state) {
        final running = state.status == AnalysisStatus.running;
        return Scaffold(
          appBar: AppBar(title: Text(context.tr('upload_title'))),
          body: AbsorbPointer(
            absorbing: running,
            child: Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _UploadCard(fileName: _fileName, onBrowse: _pickFromFiles),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _SourceTile(icon: Icons.photo_camera_outlined, title: context.tr('camera_scan'), subtitle: context.tr('camera_scan_sub'), onTap: _pickFromCamera)),
                      const SizedBox(width: 8),
                      Expanded(child: _SourceTile(icon: Icons.folder_shared_outlined, title: context.tr('pacs_files'), subtitle: context.tr('pacs_files_sub'), onTap: _comingSoon)),
                      const SizedBox(width: 8),
                      Expanded(child: _SourceTile(icon: Icons.sync_rounded, title: context.tr('direct_sync'), subtitle: context.tr('direct_sync_sub'), onTap: _comingSoon)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SectionHeader(title: context.tr('patient_details')),
                  const SizedBox(height: 8),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          controller: _code,
                          label: context.tr('patient_code'),
                          validator: Validators.patientCode,
                          suffix: TextButton(onPressed: _generateCode, child: Text(context.tr('auto_generate'))),
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _age,
                          label: context.tr('age'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: Validators.age,
                        ),
                        const SizedBox(height: 12),
                        Text(context.tr('biological_sex'), style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        SegmentedButton<String>(
                          segments: [
                            for (final s in ['male', 'female', 'other'])
                              ButtonSegment(value: s, label: Text(context.tr('sex_$s'))),
                          ],
                          selected: {_sex},
                          onSelectionChanged: (v) => setState(() => _sex = v.first),
                        ),
                        const SizedBox(height: 12),
                        _LabeledDropdown<String>(
                          label: context.tr('lead_configuration'),
                          value: _lead,
                          items: _leads,
                          display: (v) => v,
                          onChanged: (v) => setState(() => _lead = v),
                        ),
                        const SizedBox(height: 12),
                        _LabeledDropdown<int>(
                          label: context.tr('sampling_rate'),
                          value: _rate,
                          items: _rates,
                          display: (v) => '$v Hz',
                          onChanged: (v) => setState(() => _rate = v),
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _notes,
                          label: context.tr('clinical_notes'),
                          hint: context.tr('notes_hint'),
                          maxLines: 3,
                          textInputAction: TextInputAction.newline,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (running) ...[
                    const LinearProgressIndicator(),
                    const SizedBox(height: 8),
                    Text(context.tr('analyzing'), textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                  ],
                  AppButton(
                    label: context.tr('run_analysis'),
                    icon: Icons.auto_awesome_rounded,
                    loading: running,
                    onPressed: _run,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.tr('ai_disclaimer'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _UploadCard extends StatelessWidget {
  const _UploadCard({required this.fileName, required this.onBrowse});

  final String? fileName;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final ready = fileName != null;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.gradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(ready ? Icons.check_circle_rounded : Icons.cloud_upload_outlined, color: Colors.white, size: 48),
          const SizedBox(height: 8),
          Text(
            ready ? context.tr('file_ready') : context.tr('start_analysis_title'),
            textAlign: TextAlign.center,
            style: text.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            ready ? fileName! : context.tr('upload_formats'),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: text.bodySmall?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            style: FilledButton.styleFrom(minimumSize: const Size(160, 44)),
            onPressed: onBrowse,
            child: Text(context.tr(ready ? 'change_file' : 'browse_files')),
          ),
        ],
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 6),
            Text(title, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
            Text(subtitle, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10)),
          ],
        ),
      );
}

class _LabeledDropdown<T> extends StatelessWidget {
  const _LabeledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.display,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T) display;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DropdownButtonFormField<T>(
            initialValue: value,
            items: [for (final i in items) DropdownMenuItem(value: i, child: Text(display(i)))],
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ],
      );
}
