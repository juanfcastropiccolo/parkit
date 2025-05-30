import 'dart:convert';
import 'package:http/http.dart' as http;

class CarQueryYear {
  final int year;
  CarQueryYear(this.year);
}

class CarQueryMake {
  final String makeName;
  final String makeId;
  CarQueryMake(this.makeName, this.makeId);
}

class CarQueryModel {
  final String modelName;
  CarQueryModel(this.modelName);
}

class CarQueryTrim {
  final String trimName;
  final String modelId;
  CarQueryTrim(this.trimName, this.modelId);
}

class CarQueryService {
  static const String baseUrl = 'https://www.carqueryapi.com/api/0.3/';

  Future<List<int>> getYears() async {
    final uri = Uri.parse('$baseUrl?cmd=getYears');
    final res = await http.get(uri, headers: {'User-Agent': 'Mozilla/5.0'});
    if (res.statusCode == 200) {
      var raw = res.body;
      raw = raw.replaceFirst('([', '[').replaceFirst(']);', ']');
      final data = jsonDecode(raw);
      final yearsData = data['Years'];
      // If API returns a list of years
      if (yearsData is Map && yearsData['years'] != null) {
        final List<dynamic> yearsJson = yearsData['years'];
        return yearsJson.map<int>((y) => int.parse(y['year'] as String)).toList();
      }
      // Fallback: API returns min_year and max_year
      final minYear = int.tryParse(yearsData['min_year']?.toString() ?? '0') ?? 0;
      final maxYear = int.tryParse(yearsData['max_year']?.toString() ?? '0') ?? 0;
      if (minYear > 0 && maxYear >= minYear) {
        return [for (var y = maxYear; y >= minYear; y--) y];
      }
      return [];
    }
    return [];
  }

  Future<List<CarQueryMake>> getMakes(int year) async {
    final uri = Uri.parse('$baseUrl?cmd=getMakes&year=$year');
    final res = await http.get(uri, headers: {'User-Agent': 'Mozilla/5.0'});
    if (res.statusCode == 200) {
      var raw = res.body;
      raw = raw.replaceFirst('([', '[').replaceFirst(']);', ']');
      final data = jsonDecode(raw);
      final dynamic makesData = data['Makes'];
      List<dynamic> makesJson;
      if (makesData is List) {
        makesJson = makesData;
      } else if (makesData is Map && makesData['makes'] is List) {
        makesJson = makesData['makes'];
      } else {
        return [];
      }
      return makesJson
          .map<CarQueryMake>(
            (m) => CarQueryMake(m['make_display'], m['make_id']),
          )
          .toList();
    }
    return [];
  }

  Future<List<CarQueryModel>> getModels(String makeId, int year) async {
    final uri = Uri.parse('$baseUrl?cmd=getModels&make=$makeId&year=$year');
    final res = await http.get(uri, headers: {'User-Agent': 'Mozilla/5.0'});
    if (res.statusCode == 200) {
      // Strip JSONP wrapper if present
      var raw = res.body;
      final start = raw.indexOf('[');
      final end = raw.lastIndexOf(']');
      if (start != -1 && end != -1 && end > start) {
        raw = raw.substring(start, end + 1);
      }
      final decoded = jsonDecode(raw);
      // Determine list of models
      List<dynamic> modelsJson;
      if (decoded is List) {
        modelsJson = decoded;
      } else if (decoded is Map && decoded['Models'] != null) {
        final md = decoded['Models'];
        if (md is List) {
          modelsJson = md;
        } else if (md is Map && md['models'] is List) {
          modelsJson = md['models'];
        } else {
          return [];
        }
      } else {
        return [];
      }
      return modelsJson
          .map<CarQueryModel>(
            (m) => CarQueryModel(
              m['model_name'] as String,
            ),
          )
          .toList();
    }
    return [];
  }

  Future<List<CarQueryTrim>> getTrims(
    String makeId,
    String modelName,
    int year,
  ) async {
    final uri = Uri.parse(
      '$baseUrl?cmd=getTrims&make=$makeId&model=$modelName&year=$year',
    );
    final res = await http.get(uri, headers: {'User-Agent': 'Mozilla/5.0'});
    if (res.statusCode == 200) {
      var raw = res.body;
      raw = raw.replaceFirst('([', '[').replaceFirst(']);', ']');
      final data = jsonDecode(raw);
      final trimsData = data['Trims'];
      if (trimsData == null) return [];
      List<dynamic> trimsJson;
      if (trimsData is List) {
        trimsJson = trimsData;
      } else if (trimsData is Map && trimsData['trims'] is List) {
        trimsJson = trimsData['trims'];
      } else {
        return [];
      }
      return trimsJson
          .map<CarQueryTrim>(
            (t) => CarQueryTrim(
              t['model_trim'] ?? t['model_name'],
              t['model_id'],
            ),
          )
          .toList();
    }
    return [];
  }

  Future<Map<String, dynamic>?> getModelDimensions(
    String modelId,
  ) async {
    final uri = Uri.parse('$baseUrl?cmd=getModel&model=$modelId');
    final res = await http.get(uri, headers: {'User-Agent': 'Mozilla/5.0'});
    if (res.statusCode == 200) {
      var raw = res.body;
      raw = raw.replaceFirst('([', '[').replaceFirst(']);', ']');
      final decoded = jsonDecode(raw);
      List<dynamic> list;
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map && decoded['Model'] != null) {
        final m = decoded['Model'];
        list = m is List ? m : [m];
      } else {
        return null;
      }
      if (list.isEmpty) return null;
      final model = list.first as Map<String, dynamic>;
      return {
        'length_mm': int.tryParse(model['model_length_mm']?.toString() ?? '0') ?? 0,
        'width_mm': int.tryParse(model['model_width_mm']?.toString() ?? '0') ?? 0,
        'height_mm': int.tryParse(model['model_height_mm']?.toString() ?? '0') ?? 0,
      };
    }
    return null;
  }
}