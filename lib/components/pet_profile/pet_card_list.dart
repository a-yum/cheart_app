import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class PetCardList extends StatelessWidget {
  final List<String> petNames;
  final Future<void> Function() onAddPet;
  final void Function(String) onPetSelected;

  const PetCardList({
    super.key,
    required this.petNames,
    required this.onAddPet,
    required this.onPetSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      height: 120,
      // ToDo: Remove after testing.
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 5),
          itemCount: petNames.isEmpty ? 1 : petNames.length + 1, // +1 for add button
          itemBuilder: (context, index) {
            // Add button should always be the first item (index == 0)
            if (index == 0) {
              return GestureDetector(
                onTap: () async {
                  await onAddPet();
                },
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.all(10),
                  child: DottedBorder(
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(8),
                    color: Colors.grey,
                    strokeWidth: 1,
                    dashPattern: const [6, 3],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.add,
                            size: 40,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Add Pet',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            // Pet Card: Offset index by 1 for petNames since the first item is the add button
            final petIndex = index - 1;

            return InkWell(
              onTap: () => onPetSelected(petNames[petIndex]),
              child: Container(
                width: 100,
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Center(
                  child: Text(
                    petNames[petIndex],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          },
        ),
      ), // ToDo: Remove after testing.
    );
  }
}
