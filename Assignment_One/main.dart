List<int> processList(List<int> numbers, bool Function(int) predicate) {
  return numbers.where(predicate).toList();
}

void main() {
  final nums = [1, 2, 3, 4, 5, 6];

 
  final even = processList(nums, (it) => it % 2 == 0);
  print('Even numbers: $even'); 

  final greaterThan3 = processList(nums, (it) => it > 3);
  print('Greater than 3: $greaterThan3'); 
 
  final odd = processList(nums, (it) => it % 2 != 0);
  print('Odd numbers: $odd'); 
}
