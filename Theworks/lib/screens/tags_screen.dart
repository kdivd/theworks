import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:choice/choice.dart';
import 'package:theworks/routes.dart';

class TagsScreen extends StatefulWidget {
  const TagsScreen({super.key});

  @override
  State<TagsScreen> createState() => _TagsScreenTagging();
}

class _TagsScreenTagging extends State<TagsScreen> {
  List<String> choices = [];
  List<String> selectedValues = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChoices();
  }

  Future<void> _loadChoices() async {
    try {
      final String response = await rootBundle.loadString('assets/tags.json');
      final List<dynamic> data = json.decode(response);
      await Future.delayed(const Duration(milliseconds: 300)); //for effect
      if (!mounted) return;
      setState(() {
        choices = data.cast<String>();
        isLoading = false;
      });
    } catch (e) {
      // Using debugPrint instead of print for production considerations
      debugPrint('Error loading tags: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void setSelectedValues(List<String> values) {
    setState(() => selectedValues = values);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF30435A),
      body: SafeArea(
        child: isLoading
            ? const Center(
            child: CircularProgressIndicator(color: Color(0xFFCCBE96)))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Welcome. Select the tags that fit you best.',
                    style: TextStyle(
                      color: Color(0xFFCCBE96),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Icon(
                    Icons.sell_outlined,
                    color: const Color(0xFFCCBE96).withAlpha(178), // Replaced withOpacity(0.7)
                    size: 32,
                  ),
                ],
              ),
            ),
            Expanded(
              child: InlineChoice<String>.multiple(
                clearable: true,
                value: selectedValues,
                onChanged: setSelectedValues,
                itemCount: choices.length,
                itemBuilder: (state, i) {
                  final selected = state.selected(choices[i]);
                  return ChoiceChip(
                    selectedColor: const Color(0xFFCCBE96),
                    backgroundColor: const Color(0xFFFFFFFF).withAlpha(229), // Replaced withOpacity(0.9)
                    labelPadding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 5),
                    selected: selected,
                    onSelected: state.onSelected(choices[i]),
                    label: Text(
                      choices[i],
                      style: TextStyle(
                        color: selected
                            ? const Color(0xFF30435A)
                            : Colors.black87,
                      ),
                    ),
                  );
                },
                listBuilder: ChoiceList.createWrapped(
                  spacing: 12,
                  runSpacing: 12,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 25,
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF30435A),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.home,
                      arguments: {'selectedTags': selectedValues},
                    );
                  },
                  child: const Text(
                    'Confirm',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
