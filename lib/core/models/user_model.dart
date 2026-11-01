import 'package:flutter/foundation.dart';

/// Role pengguna di sistem Home-In
enum UserRole {
  pemilik,
  admin,
  penjaga,
  penghuni,
  calonPenghuni;

  static UserRole fromString(String? role) {
    switch (role?.toLowerCase()) {
      case 'pemilik':
        return UserRole.pemilik;
      case 'admin':
        return UserRole.admin;
      case 'penjaga':
        return UserRole.penjaga;
      case 'penghuni':
        return UserRole.penghuni;
      case 'calon_penghuni':
      default:
        return UserRole.calonPenghuni;
    }
  }

  String toDbString() {
    switch (this) {
      case UserRole.pemilik:
        return 'pemilik';
      case UserRole.admin:
        return 'admin';
      case UserRole.penjaga:
        return 'penjaga';
      case UserRole.penghuni:
        return 'penghuni';
      case UserRole.calonPenghuni:
        return 'calon_penghuni';
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.pemilik:
        return 'Pemilik Kost';
      case UserRole.admin:
        return 'Admin Kost';
      case UserRole.penjaga:
        return 'Penjaga Kost';
      case UserRole.penghuni:
        return 'Penghuni';
      case UserRole.calonPenghuni:
        return 'Calon Penghuni';
    }
  }
}

/// Data profil dan status penghuni (jika user memiliki role penghuni)
@immutable
class PenghuniProfile {
  const PenghuniProfile({
    required this.id,
    required this.userId,
    this.kamarId,
    this.nomorKamar,
    this.lantaiKamar,
    this.namaGedung,
    this.namaCabang,
    required this.status,
    this.tanggalMasuk,
    this.tanggalKeluar,
    this.masaTinggalSampai,
  });

  final int id;
  final int userId;
  final int? kamarId;
  final String? nomorKamar;
  final int? lantaiKamar;
  final String? namaGedung;
  final String? namaCabang;
  final String status; // 'aktif', 'nonaktif', dll.
  final DateTime? tanggalMasuk;
  final DateTime? tanggalKeluar;
  final DateTime? masaTinggalSampai;

  bool get isAktif => status.toLowerCase() == 'aktif';

  factory PenghuniProfile.fromJson(Map<String, dynamic> json) {
    return PenghuniProfile(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      kamarId: json['kamar_id'] as int?,
      nomorKamar: json['nomor_kamar'] as String? ?? json['kamar']?['nomor_kamar'] as String?,
      lantaiKamar: json['lantai'] as int? ?? json['kamar']?['lantai'] as int?,
      namaGedung: json['nama_gedung'] as String? ?? json['kamar']?['gedung']?['nama_gedung'] as String?,
      namaCabang: json['nama_cabang'] as String? ?? json['kamar']?['gedung']?['cabang']?['nama_cabang'] as String?,
      status: (json['status'] as String? ?? 'aktif'),
      tanggalMasuk: json['tanggal_masuk'] != null
          ? DateTime.tryParse(json['tanggal_masuk'].toString())
          : null,
      tanggalKeluar: json['tanggal_keluar'] != null
          ? DateTime.tryParse(json['tanggal_keluar'].toString())
          : null,
      masaTinggalSampai: json['masa_tinggal_sampai'] != null
          ? DateTime.tryParse(json['masa_tinggal_sampai'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'kamar_id': kamarId,
      'nomor_kamar': nomorKamar,
      'lantai': lantaiKamar,
      'nama_gedung': namaGedung,
      'nama_cabang': namaCabang,
      'status': status,
      'tanggal_masuk': tanggalMasuk?.toIso8601String(),
      'tanggal_keluar': tanggalKeluar?.toIso8601String(),
      'masa_tinggal_sampai': masaTinggalSampai?.toIso8601String(),
    };
  }
}

/// Model pengguna utama aplikasi Home-In
@immutable
class UserModel {
  const UserModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.noHp,
    required this.role,
    this.fotoProfil,
    this.statusAktif = true,
    this.penghuni,
    this.cabangId,
    this.namaCabang,
  });

  final int id;
  final String nama;
  final String email;
  final String noHp;
  final UserRole role;
  final String? fotoProfil;
  final bool statusAktif;
  final PenghuniProfile? penghuni;
  final int? cabangId;
  final String? namaCabang;

  /// Memeriksa apakah akun berhak masuk sebagai Admin / Pemilik
  bool get isAdminOrPemilik =>
      role == UserRole.admin || role == UserRole.pemilik;

  /// Memeriksa apakah akun berhak masuk sebagai Penghuni Aktif
  bool get isActivePenghuni {
    if (role != UserRole.penghuni) return false;
    if (!statusAktif) return false;
    if (penghuni != null && !penghuni!.isAktif) return false;
    return true;
  }

  /// Inisial nama untuk avatar
  String get initial {
    final words = nama.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) return 'U';
    if (words.length == 1) {
      return words.first.substring(0, words.first.length.clamp(1, 2)).toUpperCase();
    }
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      nama: json['nama'] as String? ?? json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      noHp: json['no_hp'] as String? ?? '',
      role: UserRole.fromString(json['role'] as String?),
      fotoProfil: json['foto_profil'] as String?,
      statusAktif: json['status_aktif'] == 1 ||
          json['status_aktif'] == true ||
          json['status_aktif'] == '1',
      penghuni: json['penghuni'] != null
          ? PenghuniProfile.fromJson(json['penghuni'] as Map<String, dynamic>)
          : null,
      cabangId: json['cabang_id'] as int?,
      namaCabang: json['nama_cabang'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'no_hp': noHp,
      'role': role.toDbString(),
      'foto_profil': fotoProfil,
      'status_aktif': statusAktif ? 1 : 0,
      'penghuni': penghuni?.toJson(),
      'cabang_id': cabangId,
      'nama_cabang': namaCabang,
    };
  }

  UserModel copyWith({
    int? id,
    String? nama,
    String? email,
    String? noHp,
    UserRole? role,
    String? fotoProfil,
    bool? statusAktif,
    PenghuniProfile? penghuni,
    int? cabangId,
    String? namaCabang,
  }) {
    return UserModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      noHp: noHp ?? this.noHp,
      role: role ?? this.role,
      fotoProfil: fotoProfil ?? this.fotoProfil,
      statusAktif: statusAktif ?? this.statusAktif,
      penghuni: penghuni ?? this.penghuni,
      cabangId: cabangId ?? this.cabangId,
      namaCabang: namaCabang ?? this.namaCabang,
    );
  }
}

