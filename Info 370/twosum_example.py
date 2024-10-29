def two_sum(nums, target):
  """
  Given an array of integers nums and an integer target, return indices of the two numbers such that they add up to target.
  
  You may assume that each input would have exactly one solution, and you may not use the same element twice.
  
  You can return the answer in any order.
  
  Example:
  --------
  nums = [2, 7, 11, 15], target = 9
  Output: [0, 1]
  Because nums[0] + nums[1] == 9, we return [0, 1].
  
  Parameters:
  -----------
  nums : List[int]
    List of integers.
  target : int
    Target sum.
  
  Returns:
  --------
  List[int]
    Indices of the two numbers that add up to the target.
  """
  positions = {}
  for i, num in enumerate(nums):
    if target - num in positions:
      return [positions[target - num], i]
    positions[num] = i

if __name__ == "__main__":
  nums = [2, 7, 11, 15]
  target = 9
  result = two_sum(nums, target)
  print(f"Indices of the two numbers that add up to {target} are: {result}")