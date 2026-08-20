import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_badge.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_button.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_organisasi.dart';
import 'package:bkuhub_mobile/features/ormawa/organisasi/presentation/pages/edit_organisasi_screen.dart';

class OrmawaOrganisasiDetailScreen extends StatelessWidget {
  final OrmawaOrganisasi organisasi;

  const OrmawaOrganisasiDetailScreen({super.key, required this.organisasi});

  OrmawaBadgeVariant _getBadgeVariant(String status) {
    switch (status.toLowerCase()) {
      case 'aktif':
        return OrmawaBadgeVariant.success;
      case 'non-aktif':
      case 'inaktif':
        return OrmawaBadgeVariant.danger;
      default:
        return OrmawaBadgeVariant.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrmawaTheme.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          BkuAppBar(
            title: 'Profil Organisasi',
            subtitle: organisasi.nama,
            variant: AppBarVariant.ormawa,
            expandedHeight: 125.0,
            showBackButton: true,
            isExpandable: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OrmawaCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: OrmawaTheme.primarySoft,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.groups_rounded,
                            color: OrmawaTheme.primary,
                            size: 26,
                          ),
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                organisasi.nama,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: OrmawaTheme.textHeading,
                                ),
                              ),
                              if (organisasi.tahunBerdiri != null && organisasi.tahunBerdiri!.isNotEmpty) ...[
                                SizedBox(height: 2),
                                Text(
                                  'Berdiri ${organisasi.tahunBerdiri}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: OrmawaTheme.textMuted,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        OrmawaBadge(
                          text: organisasi.status.toUpperCase(),
                          variant: _getBadgeVariant(organisasi.status),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildSectionTitle('Deskripsi Lembaga'),
                  const SizedBox(height: 8),
                  OrmawaCard(
                    child: Text(
                      organisasi.deskripsi.isNotEmpty ? organisasi.deskripsi : 'Belum ada deskripsi profil.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: OrmawaTheme.textHeading,
                        height: 1.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildSectionTitle('Visi & Misi'),
                  const SizedBox(height: 8),
                  OrmawaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Visi',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: OrmawaTheme.primaryDark,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          organisasi.visi != null && organisasi.visi!.isNotEmpty ? organisasi.visi! : '-',
                          style: TextStyle(
                            fontSize: 12,
                            color: OrmawaTheme.textHeading,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Misi',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: OrmawaTheme.primaryDark,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          organisasi.misi != null && organisasi.misi!.isNotEmpty ? organisasi.misi! : '-',
                          style: TextStyle(
                            fontSize: 12,
                            color: OrmawaTheme.textHeading,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Informasi Kontak & Sekretariat'),
                  const SizedBox(height: 8),
                  OrmawaCard(
                    child: Column(
                      children: [
                        _buildContactRow(
                          Icons.email_outlined,
                          'Email',
                          organisasi.email != null && organisasi.email!.isNotEmpty ? organisasi.email! : '-',
                        ),
                        const SizedBox(height: 10),
                        _buildContactRow(
                          Icons.language_rounded,
                          'Website',
                          organisasi.website != null && organisasi.website!.isNotEmpty ? organisasi.website! : '-',
                        ),
                        const SizedBox(height: 10),
                        _buildContactRow(
                          Icons.location_on_outlined,
                          'Sekretariat',
                          organisasi.alamat != null && organisasi.alamat!.isNotEmpty ? organisasi.alamat! : '-',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OrmawaButton(
                      text: 'Edit Informasi Organisasi',
                      icon: Icons.edit_rounded,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditOrganisasiScreen(organisasi: organisasi),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: OrmawaTheme.textSectionTitle,
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: OrmawaTheme.primarySoft,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: OrmawaTheme.primary),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  color: OrmawaTheme.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: OrmawaTheme.textHeading,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}