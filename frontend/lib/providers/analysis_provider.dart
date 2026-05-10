import 'package:flutter/material.dart';
import 'package:food_calorie_app/models/models.dart';
import 'package:food_calorie_app/services/api_service.dart';

class AnalysisProvider with ChangeNotifier {
  AnalysisResult? _currentResult;
  bool _isAnalyzing = false;
  String? _errorMessage;

  AnalysisResult? get currentResult => _currentResult;
  bool get isAnalyzing => _isAnalyzing;
  String? get errorMessage => _errorMessage;

  Future<bool> analyzeImage(String imagePath) async {
    _isAnalyzing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.analyzeImage(imagePath);
      _currentResult = AnalysisResult.fromJson(response);
      _isAnalyzing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isAnalyzing = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> analyzeImageBase64(String base64Image) async {
    _isAnalyzing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.analyzeImageBase64(base64Image);
      _currentResult = AnalysisResult.fromJson(response);
      _isAnalyzing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isAnalyzing = false;
      notifyListeners();
      return false;
    }
  }

  void clearResult() {
    _currentResult = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
