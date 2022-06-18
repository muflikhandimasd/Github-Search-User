import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:git_search/cubit/user_cubit.dart';
import 'package:git_search/models/user_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

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
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.w600),
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
                                  if (state is UserLoaded) {
                                    return Row(
                                      children: [
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Expanded(
                                          child: Center(
                                            child: TextField(
                                              onSubmitted: (value) {
                                                context
                                                    .read<UserCubit>()
                                                    .getUserGithub();
                                              },
                                              controller: UserCubit.search,
                                              decoration: const InputDecoration(
                                                  hintText: 'Cari...',
                                                  enabledBorder:
                                                      InputBorder.none,
                                                  border: InputBorder.none,
                                                  focusedBorder:
                                                      InputBorder.none,
                                                  errorBorder:
                                                      InputBorder.none),
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          child: const Icon(
                                            Icons.search,
                                            color: Color(0xff666666),
                                          ),
                                          onTap: () {
                                            context
                                                .read<UserCubit>()
                                                .getUserGithub();
                                          },
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                      ],
                                    );
                                  }
                                  return const SizedBox.shrink();
                                }))),
                      ],
                    )),
              ],
            )),
        // automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [_bodyContent(context)],
      ),
    );
  }

  Widget _bodyContent(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(builder: (_, state) {
      int perPage = 14;
      if (state is UserLoaded) {
        if (state.list.isEmpty) {
          return const Center(child: Text('User Not Found'));
        }
        return _bodyLoaded(context, state, perPage);
      }
      if (state is UserError) {
        return const Center(
          child: Text('Error '),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _bodyLoaded(BuildContext context, UserLoaded state, int perPage) {
    return Expanded(
      child: SmartRefresher(
        enablePullDown: false,
        enablePullUp: (state.page * perPage) != state.totalCount,
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
            return _SearchResultItem(user: user);
          },
        ),
      ),
    );
  }
}

// Search Result Item
class _SearchResultItem extends StatelessWidget {
  final User user;
  const _SearchResultItem({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Image.network(
          user.avatarUrl!,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null &&
                        loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (_, object, stackTrace) => Material(
            borderRadius: BorderRadius.circular(8),
            child: const Text('Image not Available'),
          ),
        ),
      ),
      title: Text(user.login!),
      onTap: () async {
        final url = Uri.parse(user.htmlUrl!);
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        }
      },
    );
  }
  // Search Result Item
}
