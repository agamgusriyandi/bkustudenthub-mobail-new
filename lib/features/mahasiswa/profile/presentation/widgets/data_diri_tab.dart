import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/profile_provider.dart';

class DataDiriTabWidget extends StatefulWidget {
  const DataDiriTabWidget({super.key});

  @override
  State<DataDiriTabWidget> createState() => _DataDiriTabWidgetState();
}

class _DataDiriTabWidgetState extends State<DataDiriTabWidget> {
  Map<String, dynamic> _buildValues(Map<String, dynamic> raw) {
    final m = raw['mahasiswa'] ?? raw['data']?['mahasiswa'] ?? raw;
    final p = raw['profile'] ?? raw['data']?['profile'] ?? raw;

    return {
      'nik': m['nik'] ?? m['NIK'] ?? '',
      'nomor_kk': m['nomor_kk'] ?? m['NomorKK'] ?? '',
      'nim': m['nim'] ?? m['NIM'] ?? '',
      'nisn': m['nisn'] ?? m['NISN'] ?? '',
      'nomor_kps': m['nomor_kps'] ?? m['NomorKPS'] ?? '',
      'tempat_lahir': m['tempat_lahir'] ?? m['TempatLahir'] ?? '',
      'tanggal_lahir': m['tanggal_lahir'] ?? m['TanggalLahir'] ?? '',
      'jenis_kelamin': m['jenis_kelamin'] ?? m['JenisKelamin'] ?? '',
      'agama': m['agama'] ?? m['Agama'] ?? '',
      'golongan_darah': m['golongan_darah'] ?? m['GolonganDarah'] ?? '',
      'kewarganegaraan': m['kewarganegaraan'] ?? m['Kewarganegaraan'] ?? 'WNI',
      'status_pernikahan': m['status_pernikahan'] ?? m['StatusPernikahan'] ?? 'Belum Kawin',
      'jenis_tinggal': m['jenis_tinggal'] ?? m['JenisTinggal'] ?? '',
      'is_disabilitas': m['is_disabilitas'] ?? m['IsDisabilitas'] ?? 'Tidak',

      'nupn': m['nupn'] ?? m['NUPN'] ?? '',
      'npsn': m['npsn'] ?? m['NPSN'] ?? '',
      'nirm': m['nirm'] ?? m['NIRM'] ?? '',
      'nirl': m['nirl'] ?? m['NIRL'] ?? '',

      'email_personal': m['email_personal'] ?? m['EmailPersonal'] ?? p['email'] ?? '',
      'email_kampus': m['email_kampus'] ?? m['EmailKampus'] ?? '',
      'no_hp': m['no_hp'] ?? m['NoHP'] ?? '',
      'telepon': m['telepon'] ?? m['Telepon'] ?? '',
      'alamat': m['alamat'] ?? m['Alamat'] ?? '',
      'rt': m['rt'] ?? m['RT'] ?? '',
      'rw': m['rw'] ?? m['RW'] ?? '',
      'desa': m['desa'] ?? m['Desa'] ?? m['kelurahan'] ?? '',
      'kecamatan': m['kecamatan'] ?? m['Kecamatan'] ?? '',
      'kota': m['kota'] ?? m['Kota'] ?? '',
      'provinsi': m['provinsi'] ?? m['Provinsi'] ?? '',
      'kode_pos': m['kode_pos'] ?? m['KodePos'] ?? '',

      'alamat_domisili': m['alamat_domisili'] ?? m['AlamatDomisili'] ?? '',
      'rt_domisili': m['rt_domisili'] ?? m['RTDomisili'] ?? '',
      'rw_domisili': m['rw_domisili'] ?? m['RWDomisili'] ?? '',
      'desa_domisili': m['desa_domisili'] ?? m['DesaDomisili'] ?? '',
      'kecamatan_domisili': m['kecamatan_domisili'] ?? m['KecamatanDomisili'] ?? '',
      'kota_domisili': m['kota_domisili'] ?? m['KotaDomisili'] ?? '',
      'provinsi_domisili': m['provinsi_domisili'] ?? m['ProvinsiDomisili'] ?? '',
      'kode_pos_domisili': m['kode_pos_domisili'] ?? m['KodePosDomisili'] ?? '',

      'kontak_darurat': m['kontak_darurat'] ?? m['KontakDarurat'] ?? '',
      'telepon_darurat': m['telepon_darurat'] ?? m['TeleponDarurat'] ?? '',

      'nama_ayah': m['nama_ayah'] ?? m['NamaAyah'] ?? '',
      'pekerjaan_ayah': m['pekerjaan_ayah'] ?? m['PekerjaanAyah'] ?? '',
      'nama_ibu_kandung': m['nama_ibu_kandung'] ?? m['NamaIbuKandung'] ?? '',
      'pekerjaan_ibu': m['pekerjaan_ibu'] ?? m['PekerjaanIbu'] ?? '',
      'nama_wali': m['nama_wali'] ?? m['NamaWali'] ?? '',
      'pekerjaan_wali': m['pekerjaan_wali'] ?? m['PekerjaanWali'] ?? '',
      'penghasilan_ortu': m['penghasilan_ortu'] ?? m['PenghasilanOrtu'] ?? '',
      'pekerjaan': m['pekerjaan'] ?? m['Pekerjaan'] ?? '',

      'asal_sekolah': m['asal_sekolah'] ?? m['AsalSekolah'] ?? '',
      'no_ijazah_sma': m['no_ijazah_sma'] ?? m['NoIjazahSMA'] ?? '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final data = _buildValues(profile.rawProfileData);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildSectionCard(
          title: 'Data Pribadi',
          subtitle: 'Identitas dasar yang terdaftar dalam sistem akademik.',
          icon: Icons.person_rounded,
          children: [
            _buildField('NIK KTP (16 Digit)', data['nik'].toString()),
            _buildField('Nomor Kartu Keluarga (KK)', data['nomor_kk'].toString()),
            _buildField('NPM / NIM', data['nim'].toString()),
            _buildField('NISN', data['nisn'].toString()),
            _buildField('Nomor KPS / PKH', data['nomor_kps'].toString()),
            _buildField('Tempat Lahir', data['tempat_lahir'].toString()),
            _buildField('Tanggal Lahir', data['tanggal_lahir'].toString().split('T')[0]),
            _buildField('Jenis Kelamin', data['jenis_kelamin'].toString()),
            _buildField('Agama', data['agama'].toString()),
            _buildField('Golongan Darah', data['golongan_darah'].toString()),
            _buildField('Kewarganegaraan', data['kewarganegaraan'].toString()),
            _buildField('Status Pernikahan', data['status_pernikahan'].toString()),
            _buildField('Jenis Tinggal', data['jenis_tinggal'].toString()),
            _buildField('Status Disabilitas', data['is_disabilitas'].toString()),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        _buildSectionCard(
          title: 'Identitas Kemendikbud',
          subtitle: 'Nomor induk integrasi pangkalan data pendidikan tinggi.',
          icon: Icons.account_balance_rounded,
          children: [
            _buildField('NUPN', data['nupn'].toString()),
            _buildField('NPSN', data['npsn'].toString()),
            _buildField('NIRM', data['nirm'].toString()),
            _buildField('NIRL', data['nirl'].toString()),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        _buildSectionCard(
          title: 'Kontak & Alamat KTP',
          subtitle: 'Informasi komunikasi resmi dan alamat identitas KTP.',
          icon: Icons.contact_mail_rounded,
          children: [
            _buildField('Email Personal', data['email_personal'].toString()),
            _buildField('Email Kampus', data['email_kampus'].toString()),
            _buildField('No. HP / WhatsApp', data['no_hp'].toString()),
            _buildField('Telepon Rumah', data['telepon'].toString()),
            _buildField('Alamat Lengkap (KTP)', data['alamat'].toString()),
            _buildField('RT / RW', '${data['rt']} / ${data['rw']}'),
            _buildField('Desa / Kelurahan', data['desa'].toString()),
            _buildField('Kecamatan', data['kecamatan'].toString()),
            _buildField('Kota / Kabupaten', data['kota'].toString()),
            _buildField('Provinsi', data['provinsi'].toString()),
            _buildField('Kode Pos', data['kode_pos'].toString()),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        _buildSectionCard(
          title: 'Alamat Domisili (Beda KTP)',
          subtitle: 'Alamat tempat tinggal saat ini jika berbeda dengan KTP.',
          icon: Icons.home_work_rounded,
          children: [
            _buildField('Alamat Domisili', data['alamat_domisili'].toString()),
            _buildField('RT / RW Domisili', '${data['rt_domisili']} / ${data['rw_domisili']}'),
            _buildField('Desa Domisili', data['desa_domisili'].toString()),
            _buildField('Kecamatan Domisili', data['kecamatan_domisili'].toString()),
            _buildField('Kota Domisili', data['kota_domisili'].toString()),
            _buildField('Provinsi Domisili', data['provinsi_domisili'].toString()),
            _buildField('Kode Pos Domisili', data['kode_pos_domisili'].toString()),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        _buildSectionCard(
          title: 'Kontak Darurat',
          subtitle: 'Orang yang dapat dihubungi saat situasi darurat kampus.',
          icon: Icons.emergency_rounded,
          children: [
            _buildField('Nama Kontak Darurat', data['kontak_darurat'].toString()),
            _buildField('No. HP Kontak Darurat', data['telepon_darurat'].toString()),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        _buildSectionCard(
          title: 'Data Keluarga & Pendidikan',
          subtitle: 'Informasi orang tua / wali dan riwayat asal sekolah menengah.',
          icon: Icons.family_restroom_rounded,
          children: [
            _buildField('Nama Lengkap Ayah', data['nama_ayah'].toString()),
            _buildField('Pekerjaan Ayah', data['pekerjaan_ayah'].toString()),
            _buildField('Nama Lengkap Ibu Kandung', data['nama_ibu_kandung'].toString()),
            _buildField('Pekerjaan Ibu', data['pekerjaan_ibu'].toString()),
            _buildField('Nama Wali', data['nama_wali'].toString()),
            _buildField('Pekerjaan Wali', data['pekerjaan_wali'].toString()),
            _buildField('Penghasilan Ortu (Rp/Bulan)', data['penghasilan_ortu'].toString()),
            _buildField('Pekerjaan Mahasiswa', data['pekerjaan'].toString()),
            _buildField('Asal Sekolah (SMA/SMK)', data['asal_sekolah'].toString()),
            _buildField('No. Ijazah SMA / SMK', data['no_ijazah_sma'].toString()),
          ],
        ),
        const SizedBox(height: AppSpacing.s80),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF2563EB), size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField(String label, String value) {
    final displayVal = value.trim().isEmpty || value.trim() == '/' || value.trim() == 'null' ? '-' : value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              displayVal,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
