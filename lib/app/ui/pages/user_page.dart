import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../app.dart';

class UserPage extends StatelessWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 70,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Text(
                    'Github Search User',
                    style: ThemeFont.defFont
                        .copyWith(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                    height: 36.0,
                    width: double.infinity,
                    margin:
                        const EdgeInsets.only(left: 16, right: 8, bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                            child: Container(
                                height: double.infinity,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.black.withOpacity(0.20),
                                    )),
                                child: BlocBuilder<UserCubit, UserState>(
                                    builder: (context, state) {
                                  if (state is UserInitial) {
                                    return _searchField(context);
                                  }
                                  if (state is UserLoaded) {
                                    return _searchField(context);
                                  }
                                  if (state is UserError) {
                                    return _searchField(context);
                                  }
                                  return const SizedBox.shrink();
                                }))),
                      ],
                    )),
              ],
            )),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [_bodyContent(context)],
      ),
    );
  }

  Widget _searchField(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: Center(
            child: TextField(
              cursorColor: Colors.black,
              style: ThemeFont.defFont.copyWith(fontSize: 12),
              onSubmitted: (value) {
                context.read<UserCubit>().getUserGithub();
              },
              controller: UserCubit.search,
              decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: ThemeFont.defFont.copyWith(fontSize: 12),
                  enabledBorder: InputBorder.none,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none),
            ),
          ),
        ),
        GestureDetector(
          child: const Icon(
            Icons.search,
            color: Color(0xff666666),
          ),
          onTap: () {
            context.read<UserCubit>().getUserGithub();
          },
        ),
        const SizedBox(
          width: 8,
        ),
      ],
    );
  }

  Widget _bodyContent(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(builder: (_, state) {
      if (state is UserInitial) {
        return Center(
          child: Text(
            'Please enter a text ',
            style: ThemeFont.defFont.copyWith(fontSize: 16),
          ),
        );
      }
      if (state is UserLoaded) {
        if (state.list.isEmpty) {
          return Center(
              child: Text('User Not Found',
                  style: ThemeFont.defFont.copyWith(fontSize: 16)));
        }
        return _bodyLoaded(context, state);
      }
      if (state is UserError) {
        return Center(
          child: Text(
            'Error',
            style: ThemeFont.defFont.copyWith(fontSize: 16),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _bodyLoaded(BuildContext context, UserLoaded state) {
    return Expanded(
      child: SmartRefresher(
        enablePullDown: false,
        enablePullUp: (((state.page * state.perPage) != state.totalCount) &&
            (state.page * state.perPage) < state.totalCount),
        controller: UserCubit.refreshController,
        onLoading: () async {
          await Future.delayed(const Duration(seconds: 5));
          context.read<UserCubit>().onLoadMoreUser();
        },
        onRefresh: context.read<UserCubit>().onRefresh,
        child: ListView.builder(
          itemCount: state.list.length,
          itemBuilder: (context, index) {
            var user = state.list[index];
            return SearchResultItem(user: user);
          },
        ),
      ),
    );
  }
}
