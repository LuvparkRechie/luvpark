// ignore_for_file: depend_on_referenced_packages

import 'package:luvpark/classess/variables.dart';
import 'package:luvpark/sqlite/vehicle_brands_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class VehicleBrandsTable {
  static final VehicleBrandsTable instance = VehicleBrandsTable._init();

  static Database? _database;

  VehicleBrandsTable._init();

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await _initDB('${Variables.vhBrands}.db');
    return _database;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const textType = 'TEXT NULL';
    const integerType = 'INTEGER NULL';

    await db.execute('''
      CREATE TABLE ${Variables.vhBrands} (  
        ${VHBrandsDataFields.vhTypeId} $integerType, 
        ${VHBrandsDataFields.vhBrandId} $integerType,  
        ${VHBrandsDataFields.vhBrandName} $textType
        )
      ''');
  }

  Future<void> insertUpdate(dynamic json) async {
    final db = await instance.database;

    const columns = '${VHBrandsDataFields.vhBrandId},'
        '${VHBrandsDataFields.vhTypeId},'
        '${VHBrandsDataFields.vhBrandName}';
    final insertValues = "${json[VHBrandsDataFields.vhBrandId]},"
        "${json[VHBrandsDataFields.vhTypeId]},"
        "'${json[VHBrandsDataFields.vhBrandName]}'";

    final existingData = await VehicleBrandsTable.instance
        .readVehicleBrandsById(json[VHBrandsDataFields.vhBrandId]);

    // if (existingData != null) {
    //   await db!.transaction((txn) async {
    //     var batch = txn.batch();
    //     batch.rawUpdate('''
    //       UPDATE ${Variables.vhBrands}
    //       SET ${VHBrandsDataFields.vhBrandId} = ?,
    //           ${VHBrandsDataFields.vhTypeId} = ?,
    //           ${VHBrandsDataFields.vhBrandName} = ?
    //       WHERE ${VHBrandsDataFields.vhBrandId} = ?
    //       ''', [
    //       json[VHBrandsDataFields.vhBrandId],
    //       json[VHBrandsDataFields.vhTypeId],
    //       json[VHBrandsDataFields.vhBrandName],
    //       json[VHBrandsDataFields.vhBrandId],
    //     ]);

    //     await batch.commit(noResult: true);
    //   });
    // } else {
    //   await db!.transaction((txn) async {
    //     var batch = txn.batch();

    //     batch.rawInsert(
    //         'INSERT INTO ${Variables.vhBrands} ($columns) VALUES ($insertValues)');

    //     await batch.commit(noResult: true);
    //   });
    // }
    await db!.transaction((txn) async {
      var batch = txn.batch();

      batch.rawInsert(
          'INSERT INTO ${Variables.vhBrands} ($columns) VALUES ($insertValues)');

      await batch.commit(noResult: true);
    });
  }

  Future<dynamic> readVehicleBrandsById(int id) async {
    final db = await instance.database;

    final maps = await db!.query(
      Variables.vhBrands,
      columns: VHBrandsDataFields.values,
      where: '${VHBrandsDataFields.vhBrandId} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null;
    }
  }

  Future<String?> readVehicleBrandsByVbId(int vtId, int vbId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db!.query(
      Variables.vhBrands,
      orderBy: "${VHBrandsDataFields.vhBrandId} ASC",
    );

    final Map<String, dynamic>? matchingRecord = maps.firstWhere(
      (record) =>
          record[VHBrandsDataFields.vhTypeId] == vtId &&
          record[VHBrandsDataFields.vhBrandId] == vbId,
    );

    String? brandName;
    if (matchingRecord != null) {
      brandName = matchingRecord[VHBrandsDataFields.vhBrandName] as String?;
    }

    return brandName;
  }

  Future<dynamic> readVBrandDataByVTID(int vtId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db!.query(
      Variables.vhBrands,
      orderBy: "${VHBrandsDataFields.vhTypeId} ASC",
    );
    final Map<String, dynamic>? matchingRecord = maps.firstWhere(
      (record) => record[VHBrandsDataFields.vhTypeId] == vtId,
    );

    print("matchingRecord $matchingRecord");

    return matchingRecord;
  }

  Future<List<dynamic>> readAllVHBrands() async {
    final db = await instance.database;

    final result = await db!.query(
      Variables.vhBrands,
      orderBy: "${VHBrandsDataFields.vhTypeId} ASC",
    );

    return result;
  }

  Future deleteAll() async {
    final db = await instance.database;

    db!.delete(Variables.vhBrands);
  }

  Future<int> deleteMessageById(int id) async {
    final db = await database;

    return await db!
        .delete(Variables.vhBrands, where: 'push_msg_id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;

    db!.close();
  }
}
