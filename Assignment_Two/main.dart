void main() {
  final words = ["apple", "cat", "banana", "dog", "elephant"];


  final wordMap = { for (var w in words) w: w.length };


  wordMap
      .entries
      .where((entry) => entry.value > 4)
      .forEach((entry) => print('${entry.key} has length ${entry.value}'));
}