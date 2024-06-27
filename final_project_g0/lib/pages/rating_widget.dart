import 'package:flutter/material.dart';
import 'package:rate_in_stars/rate_in_stars.dart';


class RatingFormWidget extends StatelessWidget {
  final bool? isImportant;
  final int? number;
  final double? star;
  final ValueChanged<bool> onChangedImportant;
  final ValueChanged<int> onChangedNumber;
  final ValueChanged<double> onRatingChanged;

  const RatingFormWidget({
    Key? key,
    this.isImportant = false,
    this.number = 0,
    this.star =.0,
    required this.onChangedImportant,
    required this.onChangedNumber,
    required this.onRatingChanged
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Row(
            children: new List.generate(5, (index) => buildStar(context, index)),
          ),          // buildStar(context, star),
          const SizedBox(height: 8),

        ],
      ),
    ),
  );

  Widget buildStar(BuildContext context, int index) {
    Icon icon;
    double ratingvalue = 0;
    if (index >= ratingvalue) {
      icon = new Icon(
        Icons.star_border,
        color: Colors.black,
      );
    }
    else if (index > ratingvalue - 1 && index < ratingvalue) {
      icon = new Icon(
        Icons.star_half,
        color:  Colors.red,
      );
    } else {
      icon = new Icon(
        Icons.star,
        color: Colors.red,
      );
    }
    return new InkResponse(
      onTap: onRatingChanged == null ? null : () => onRatingChanged(index + 1.0),
      child: icon,
    );
  }
// Widget buildStar(BuildContext context) {
//   return Row(
//     children: List.generate(5, (index) {
//       return Icon(
//         index < 0 ? Icons.star : Icons.star_border,
//         color: Colors.green,
//       );
//     }),
//
//   );
// }
}

