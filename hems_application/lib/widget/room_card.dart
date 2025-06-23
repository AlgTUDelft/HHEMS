import 'package:flutter/material.dart';
import 'package:hems_app/model/internal/room.dart';
import 'package:hems_app/widget/page/edit_room.dart';

/// Room Card widget on the home screen.
class RoomCard extends StatefulWidget {
  final Room room;

  const RoomCard(this.room, {super.key});

  @override
  State<StatefulWidget> createState() {
    return RoomCardState();
  }
}

class RoomCardState extends State<RoomCard> {
  /// Builds the widget.
  ///
  /// The widget displays a [Card] containing the [Room]'s icon and name.
  /// The [Card] is wrapped in an [InkWell] which when tapped, navigates to [EditRoom] to
  /// allow the user to edit the selected room.
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        Navigator.push<Room>(
          context,
          MaterialPageRoute(builder: (context) => EditRoom(room: widget.room)),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              child: Icon(
                size: 45,
                widget.room.icon(),
                color: widget.room.color(),
              ),
            ),
            Text(
              widget.room.name,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.apply(color: widget.room.color()),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
