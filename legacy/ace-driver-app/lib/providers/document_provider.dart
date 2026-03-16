import 'dart:io';
import 'package:flutter/material.dart';
import '../repositories/document_repository.dart';

class DocumentProvider with ChangeNotifier {
  final DocumentRepository _repository = DocumentRepository();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> uploadDocument({
    required int type,
    required File file,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.uploadDocument(type: type, file: file);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
