import 'package:flutter/material.dart';
import 'package:gerente_loja/widgets/add_size_dialog.dart';

class ProductSizes extends FormField<List> {
  ProductSizes(
      {BuildContext? context,
      List? initialValue,
      FormFieldSetter<List>? onSaved,
      FormFieldValidator<List>? validator,
      Key? key})
      : super(
          key: key,
          initialValue: initialValue,
          onSaved: onSaved,
          validator: validator,
          builder: (state) {
            return SizedBox(
              height: 34,
              child: GridView(
                padding: const EdgeInsets.symmetric(vertical: 4),
                scrollDirection: Axis.horizontal,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.5,
                ),
                children: state.value!.map(
                  (s) {
                    return GestureDetector(
                      onLongPress: () {
                        state.didChange(state.value!..remove(s));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(4),
                          ),
                          border: Border.all(
                            color: Colors.pinkAccent,
                            width: 3,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          s,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ).toList()
                  ..add(
                    GestureDetector(
                      onTap: () async {
                        String size = await showDialog(
                          context: context!,
                          builder: (context) => AddSizeDialog(),
                        );
                        state.didChange(
                          state.value!..add(size),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(4)),
                          border: Border.all(
                            color:
                                state.hasError ? Colors.red : Colors.pinkAccent,
                            width: 3,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "+",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
              ),
            );
          },
        );
}