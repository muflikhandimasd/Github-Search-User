part of 'user_cubit.dart';

@immutable
abstract class UserState {}

class UserInitial extends UserState {}

class UserLoaded extends UserState {
  final int page;
  final int totalCount;
  final int perPage;
  final List<User> list;

  UserLoaded._(
      {required this.list,
      this.page = 1,
      this.totalCount = 1,
      this.perPage = 14});

  UserLoaded.init() : this._(list: []);

  UserLoaded loaded(
      {required List<User> users, int? perPage, int? totalCount, int? page}) {
    return UserLoaded._(
        list: users,
        page: page ?? this.page,
        totalCount: totalCount ?? this.totalCount,
        perPage: perPage ?? this.perPage);
  }
}

class UserError extends UserState {}
