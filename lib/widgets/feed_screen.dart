import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runrally/bloc/feed_bloc.dart';
import 'package:runrally/color_palette.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(
      builder: (context, feedState) {
        return const Center(
            child: Text(
              'No runs recorded',
              style: TextStyle(fontSize: 20, color: ColorPalette.primaryGreen),
            ),
        );
      },
    );
  }
}
