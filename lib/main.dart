import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:git_search/cubit/user_cubit.dart';

import 'package:git_search/ui/pages/user_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<UserCubit>(create: (_) => UserCubit()..getUserGithub()),
        ],
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: UserPage(),
        ));
  }
}
