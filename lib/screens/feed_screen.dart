import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runrally/bloc/feed_bloc.dart';
import 'package:runrally/color_palette.dart';
import 'package:runrally/repository/run_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedScreen extends StatelessWidget {
  final RunRepository runRepository;

  const FeedScreen({super.key, required this.runRepository});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: runRepository.runCollection.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong',
              style: TextStyle(color: ColorPalette.primaryGreen));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading",
              style: TextStyle(color: ColorPalette.primaryGreen));
        }

        return ListView.separated(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot document = snapshot.data!.docs[index];
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            double distance = data['distance'];
            return ListTile(
              title: Text('Distance: ${distance.toStringAsFixed(2)} km',
                  style: const TextStyle(color: ColorPalette.primaryGreen)),
              subtitle: Text('Duration: ${Duration(seconds: data['duration']).inMinutes.toString().padLeft(2, '0')}:${(Duration(seconds: data['duration']).inSeconds % 60).toString().padLeft(2, '0')} min',
                  style: const TextStyle(color: ColorPalette.lightGreen)),
            );
          },
          separatorBuilder: (context, index) {
            return const Divider();  // This is the separator widget
          },
        );
      },
    );
  }
}