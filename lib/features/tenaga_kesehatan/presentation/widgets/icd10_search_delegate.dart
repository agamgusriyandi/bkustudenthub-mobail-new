import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/data/models/icd10_data.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';

class Icd10SearchBottomSheet extends StatefulWidget {
  final Function(Icd10Item) onSelected;

  const Icd10SearchBottomSheet({super.key, required this.onSelected});

  @override
  State<Icd10SearchBottomSheet> createState() => _Icd10SearchBottomSheetState();
}

class _Icd10SearchBottomSheetState extends State<Icd10SearchBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Icd10Item> _filteredList = commonIcd10List;

  void _filter(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredList = commonIcd10List;
      } else {
        final q = query.toLowerCase();
        _filteredList =
            commonIcd10List.where((item) {
              return item.code.toLowerCase().contains(q) ||
                  item.name.toLowerCase().contains(q);
            }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutral300,
                borderRadius: AppRadius.br2,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Katalog Diagnosa WHO ICD-10',
            style: AppTextStyles.titleSm.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Pilih diagnosa standar medis internasional',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral600),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _searchController,
            onChanged: _filter,
            decoration: InputDecoration(
              hintText: 'Cari penyakit atau kode (misal: ISPA, A09)...',
              prefixIcon: const Icon(Icons.search, color: AppColors.neutral500),
              border: OutlineInputBorder(
                borderRadius: AppRadius.radiusMd,
                borderSide: const BorderSide(color: AppColors.neutral300),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child:
                _filteredList.isEmpty
                    ? Center(
                      child: Text(
                        'Diagnosa tidak ditemukan',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.neutral500,
                        ),
                      ),
                    )
                    : ListView.separated(
                      itemCount: _filteredList.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _filteredList[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(20),
                              borderRadius: AppRadius.radiusSm,
                            ),
                            child: Text(
                              item.code,
                              style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          title: Text(
                            item.name,
                            style: AppTextStyles.bodyMd.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutral800,
                            ),
                          ),
                          onTap: () {
                            widget.onSelected(item);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
