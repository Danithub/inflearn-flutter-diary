import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

const String PrefsKey = "diaryList";

class Diary {
  String text; // 내용
  DateTime createdAt; // 작성 시간

  Diary({
    required this.text,
    required this.createdAt,
  });

  static Diary fromJson(Map<String, dynamic> jsonMap) {
    return Diary(
      text: jsonMap["text"],
      createdAt: DateTime.parse(jsonMap["createdAt"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "text": text,
      "createdAt": createdAt.toString(),
    };
  }
}

class DiaryService extends ChangeNotifier {
  DiaryService(this.prefs) {
    List<String> stringDiaryList = prefs.getStringList(PrefsKey) ?? [];
    for (String stringDiary in stringDiaryList) {
      Map<String, dynamic> jsonMap = jsonDecode(stringDiary);

      Diary diary = Diary.fromJson(jsonMap);
      diaryList.add(diary);
    }
  }

  SharedPreferences prefs;

  /// Diary 목록
  List<Diary> diaryList = [];

  /// 특정 날짜의 diary 조회
  List<Diary> getByDate(DateTime date) {
    return diaryList
        .where((diary) => isSameDay(date, diary.createdAt))
        .toList();
  }

  /// Diary 작성
  void create(String text, DateTime selectedDate) {
    DateTime now = DateTime.now();

    DateTime createdAt = DateTime(selectedDate.year, selectedDate.month,
        selectedDate.day, now.hour, now.minute, now.second);

    Diary diary = Diary(text: text, createdAt: createdAt);

    diaryList.add(diary);
    notifyListeners();

    _saveDiaryList();
  }

  /// Diary 수정
  void update(DateTime createdAt, String newContent) {
    Diary diary = diaryList.firstWhere((diary) => diary.createdAt == createdAt);

    diary.text = newContent;
    notifyListeners();

    _saveDiaryList();
  }

  /// Diary 삭제
  void delete(DateTime createdAt) {
    diaryList.removeWhere((diary) => diary.createdAt == createdAt);
    notifyListeners();

    _saveDiaryList();
  }

  void _saveDiaryList() {
    List<String> stringDiaryList = [];

    for (Diary diary in diaryList) {
      Map<String, dynamic> jsonMap = diary.toJson();

      String stringDiary = jsonEncode(jsonMap);
      stringDiaryList.add(stringDiary);
    }

    prefs.setStringList(PrefsKey, stringDiaryList);
  }
}
