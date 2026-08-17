class OrmawaFinancialSetting {
  final int ormawaId;
  final String name;
  final String code;
  final double budgetLimit;
  final double usedBudget;
  final double pendingBudget;
  final double remainingBudget;
  final String fiscalYear;
  final bool active;
  final int warningThreshold;
  final bool enforceLimit;

  const OrmawaFinancialSetting({
    required this.ormawaId,
    required this.name,
    required this.code,
    required this.budgetLimit,
    required this.usedBudget,
    required this.pendingBudget,
    required this.remainingBudget,
    required this.fiscalYear,
    required this.active,
    required this.warningThreshold,
    required this.enforceLimit,
  });

  factory OrmawaFinancialSetting.fromJson(Map<String, dynamic> json) {
    return OrmawaFinancialSetting(
      ormawaId: int.tryParse((json['ormawa_id'] ?? json['OrmawaID'] ?? 0).toString()) ?? 0,
      name: (json['name'] ?? json['Name'] ?? json['Nama'] ?? '').toString(),
      code: (json['code'] ?? json['Code'] ?? json['Kode'] ?? '').toString(),
      budgetLimit: double.tryParse((json['budget_limit'] ?? json['BudgetLimit'] ?? 0).toString()) ?? 0.0,
      usedBudget: double.tryParse((json['used_budget'] ?? json['UsedBudget'] ?? 0).toString()) ?? 0.0,
      pendingBudget: double.tryParse((json['pending_budget'] ?? json['PendingBudget'] ?? 0).toString()) ?? 0.0,
      remainingBudget: double.tryParse((json['remaining_budget'] ?? json['RemainingBudget'] ?? 0).toString()) ?? 0.0,
      fiscalYear: (json['fiscal_year'] ?? json['FiscalYear'] ?? json['periode'] ?? DateTime.now().year.toString()).toString(),
      active: json['active'] == true || json['is_active'] == true || json['Active'] == true,
      warningThreshold: int.tryParse((json['warning_threshold'] ?? json['WarningThreshold'] ?? 80).toString()) ?? 80,
      enforceLimit: json['enforce_limit'] == true || json['EnforceLimit'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ormawa_id': ormawaId,
      'budget_limit': budgetLimit,
      'periode': fiscalYear,
      'is_active': active,
      'enforce_limit': enforceLimit,
    };
  }
}

class OrmawaFinancialAuditLog {
  final int id;
  final String createdAt;
  final String periode;
  final double newValue;
  final String user;
  final String reason;

  const OrmawaFinancialAuditLog({
    required this.id,
    required this.createdAt,
    required this.periode,
    required this.newValue,
    required this.user,
    required this.reason,
  });

  factory OrmawaFinancialAuditLog.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] is Map ? json['user'] as Map<String, dynamic> : null;
    final userName = userMap?['nama_lengkap'] ?? userMap?['name'] ?? userMap?['Nama'] ?? json['user_name'] ?? 'Bagian Kemahasiswaan';
    final settingMap = json['setting'] is Map ? json['setting'] as Map<String, dynamic> : null;

    return OrmawaFinancialAuditLog(
      id: int.tryParse((json['id'] ?? json['ID'] ?? 0).toString()) ?? 0,
      createdAt: (json['created_at'] ?? json['CreatedAt'] ?? '').toString(),
      periode: (settingMap?['periode'] ?? json['periode'] ?? json['Periode'] ?? '-').toString(),
      newValue: double.tryParse((json['new_value'] ?? json['NewValue'] ?? 0).toString()) ?? 0.0,
      user: userName.toString(),
      reason: (json['reason'] ?? json['Reason'] ?? json['keterangan'] ?? 'Penyesuaian pagu anggaran').toString(),
    );
  }
}
