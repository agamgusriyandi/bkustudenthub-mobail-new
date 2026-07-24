class Icd10Item {
  final String code;
  final String name;

  const Icd10Item({required this.code, required this.name});
}

const List<Icd10Item> commonIcd10List = [
  Icd10Item(code: 'A09', name: 'Diare dan Gastroenteritis Infeksi'),
  Icd10Item(code: 'J06.9', name: 'Infeksi Saluran Pernapasan Akut (ISPA)'),
  Icd10Item(code: 'R50.9', name: 'Demam, tidak spesifik'),
  Icd10Item(code: 'K30', name: 'Dispepsia (Gangguan Pencernaan / Maag)'),
  Icd10Item(code: 'J02.9', name: 'Faringitis Akut (Radang Tenggorokan)'),
  Icd10Item(code: 'A01.0', name: 'Demam Tifoid (Tipes)'),
  Icd10Item(code: 'J11.1', name: 'Influenza dengan manifestasi pernapasan'),
  Icd10Item(code: 'R51', name: 'Sakit Kepala (Headache)'),
  Icd10Item(code: 'G43.9', name: 'Migrain, tidak spesifik'),
  Icd10Item(code: 'H10.9', name: 'Konjungtivitis (Sakit Mata Merah)'),
  Icd10Item(code: 'M79.1', name: 'Mialgia (Nyeri Otot)'),
  Icd10Item(code: 'M54.5', name: 'Low Back Pain (Nyeri Punggung Bawah)'),
  Icd10Item(code: 'R10.4', name: 'Nyeri Abdomen (Sakit Perut)'),
  Icd10Item(code: 'A90', name: 'Demam Berdarah Dengue (DBD) Klasik'),
  Icd10Item(
    code: 'A91',
    name: 'Demam Berdarah Dengue (Dengue Hemorrhagic Fever)',
  ),
  Icd10Item(code: 'J45.9', name: 'Asma, tidak spesifik'),
  Icd10Item(code: 'K04.0', name: 'Pulpitis (Sakit Gigi)'),
  Icd10Item(code: 'L20.9', name: 'Dermatitis Atopik (Eksim)'),
  Icd10Item(code: 'L50.9', name: 'Urtikaria (Biduran/Kaligata)'),
  Icd10Item(code: 'B35.4', name: 'Tinea Corporis (Kadas/Kurap)'),
  Icd10Item(code: 'J01.9', name: 'Sinusitis Akut'),
  Icd10Item(code: 'J03.9', name: 'Tonsilitis Akut (Amandel)'),
  Icd10Item(code: 'N39.0', name: 'Infeksi Saluran Kemih (ISK)'),
  Icd10Item(code: 'R42', name: 'Pusing dan Giddiness (Vertigo)'),
  Icd10Item(code: 'T14.0', name: 'Luka Superficial (Lecet/Memar)'),
  Icd10Item(code: 'S93.4', name: 'Keseleo / Sprain Pergelangan Kaki'),
  Icd10Item(code: 'B01.9', name: 'Varisela (Cacar Air)'),
  Icd10Item(code: 'E11.9', name: 'Diabetes Mellitus Tipe 2'),
  Icd10Item(code: 'I10', name: 'Hipertensi Esensial (Darah Tinggi)'),
  Icd10Item(code: 'R04.0', name: 'Epistaksis (Mimisan)'),
  Icd10Item(code: 'R07.4', name: 'Nyeri Dada'),
  Icd10Item(code: 'R21', name: 'Ruam dan Erupsi Kulit'),
  Icd10Item(code: 'R53.83', name: 'Fatigue (Kelelahan)'),
  Icd10Item(code: 'Z00.0', name: 'Pemeriksaan Kesehatan Umum (MCU)'),
  Icd10Item(code: 'Z02.7', name: 'Penerbitan Surat Keterangan Sehat/Sakit'),
  Icd10Item(code: 'Z73.3', name: 'Stres Terkait Tuntutan Akademik'),
];
