import 'package:flutter/material.dart';
import 'package:sportspectra/utils/colors.dart';

/* A stateless widget is immutable, meaning its properties cannot change once it's built.
Stateless widgets are used for UI components that don't require managing internal state or data changes. */
class CustomTextField extends StatelessWidget {
  /*ithout a controller, you won't have direct access to the text entered by the user in the text input field. You'll need to rely on other methods to access the input data, such as reading the onChanged callback parameter or using form submission methods.*/
  final TextEditingController controller;
  const CustomTextField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        // whenever user clicks on textfield, textfield will show bolded border
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: buttonColor,
            width: 2,
          ),
        ),
        // this is when email is not clicked, we still want grey border
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: secondaryBackgroundColor,
          ),
        ),
      ),
    );
  }
}
