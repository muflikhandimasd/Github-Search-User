// ignore_for_file: depend_on_referenced_packages

import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:git_search/models/user_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

      // log('Get User $json');

      if (request.statusCode == 200) {
        List items = json['items'];

        List<User> users = items.map((e) => User.fromJson(e)).toList();

        emit(UserLoaded._(
            list: users,
            totalCount: json['total_count'],
            perPage: perPage,
            page: page));
      }
    } catch (e, stack) {
      log('Error: $e , Stack : $stack');
      emit(UserError());
    } finally {
      refreshController.loadComplete();
    }
  }

  void onLoadMoreUser() async {
    var test = search.text;
    if (state is UserLoaded) {
      var st = state as UserLoaded;

      try {
        // log('State Page : ${st.page}');
        int page = 1 + st.page;
        // log('PerPage sekarang : ${st.perPage}');
        // log('Page Sekarang : $page');

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
      } catch (e) {
        log('Error : $e');
        emit(UserError());
      } finally {
        refreshController.loadComplete();
      }
    }
  }

  void onRefresh() {
    getUserGithub();
  }
}
