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
  UserCubit() : super(UserLoaded.init());

  static final refreshController = RefreshController();
  static final TextEditingController search = TextEditingController();

  void getUserGithub({String text = 'm'}) async {
    log(search.text);
    try {
      int page = 1;

      var request = await http.get(Uri.parse(
          'https://api.github.com/search/users?q=$text&page=$page&per_page=20'));

      final json = jsonDecode(request.body);

      log('Get User $json');

      if (request.statusCode == 200) {
        List items = json['items'];
        log('Items : $items');
        List<User> users = items.map((e) => User.fromJson(e)).toList();
        log('Users : $users');
        if (state is UserLoaded) {
          final s = state as UserLoaded;
          log("data loaded $state");
          emit(s.loaded(
            users: users,
            totalCount: json['total_count'],
          ));
        }
        refreshController.loadComplete();
      } else {
        emit(UserError());
      }
    } catch (e, stack) {
      log('Error: $e , Stack : $stack');
    } finally {
      refreshController.refreshCompleted();
    }
  }

  void onLoadMoreUser() async {
    log('method onLoad ');
    if (state is UserLoaded) {
      var st = state as UserLoaded;
      log('onLoadMore : $st');
      try {
        int page = 1 + st.page;
        log('Page : $page');

        var request = await http.get(Uri.parse(
            'https://api.github.com/search/users?q=${search.text}&page=$page&per_page=20'));

        final json = jsonDecode(request.body);

        log('Get User $json');

        if (request.statusCode == 200) {
          List items = json['items'];
          List<User> users = items.map((e) => User.fromJson(e)).toList();

          final s = state as UserLoaded;
          emit(s.loaded(
            users: users,
            totalCount: json['total_count'],
          ));

          refreshController.loadComplete();
        } else {
          emit(UserError());
        }
      } catch (e) {
        log(e.toString());
      } finally {
        refreshController.refreshCompleted();
      }
    }
  }

  void onRefresh() {
    getUserGithub();
  }
}
