import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../app.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitial());

  static final refreshController = RefreshController();
  static final TextEditingController search = TextEditingController();
  int perPage = 14;

  void init() {
    search.text = '';
    getUserGithub();
  }

  void getUserGithub() async {
    var test = search.text;
    try {
      int page = 1;
      var request = await http.get(Uri.parse(
          'https://api.github.com/search/users?q=$test&page=$page&per_page=$perPage'));
      final json = jsonDecode(request.body);
      if (request.statusCode == 200) {
        List items = json['items'];
        List<User> users = items.map((e) => User.fromJson(e)).toList();
        emit(UserLoaded._(
            list: users,
            totalCount: json['total_count'],
            perPage: perPage,
            page: page));
      }
    } catch (_) {
      emit(UserError._());
    } finally {
      refreshController.loadComplete();
    }
  }

  void onLoadMoreUser() async {
    var test = search.text;
    if (state is UserLoaded) {
      var st = state as UserLoaded;
      try {
        int page = 1 + st.page;
        var request = await http.get(Uri.parse(
            'https://api.github.com/search/users?q=$test&page=$page&per_page=${st.perPage}'));
        final json = jsonDecode(request.body);
        if (request.statusCode == 200) {
          List items = json['items'];
          List<User> users = items.map((e) => User.fromJson(e)).toList();
          List oldData = st.list;
          users = [...oldData, ...users];
          final s = state as UserLoaded;
          emit(s.loaded(
            users: users,
            page: page,
            perPage: perPage,
            totalCount: json['total_count'],
          ));
        }
      } catch (_) {
        emit(UserError._());
      } finally {
        refreshController.loadComplete();
      }
    }
  }

  void onRefresh() {
    getUserGithub();
  }
}
