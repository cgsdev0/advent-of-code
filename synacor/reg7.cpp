#include <stdio.h>
#include <unordered_map>

std::unordered_map<int, int> cache;

int f6049(int r0, int r1, int r7) {
  int k = r0 << 16 ^ r1;
  auto it = cache.find(k);
  if (it != cache.end()) {
    return it->second;
  }
  if (r0 == 0) {
    int ans = (r1 + 1) % 32768;
    cache.emplace(k, ans);
    return ans;
  }
  if (r0 == 1) {
    int ans = (r7+r1+1)  % 32768;
    cache.emplace(k, ans);
    return ans;
  }
  if (r0 == 2) {
    int ans = ((r7+1)*r1 + (r7*2 + 1))  % 32768;
    cache.emplace(k, ans);
    return ans;
  }
  if (r1 == 0) {
    int ans = f6049((r0 + 32767) % 32768, r7, r7);
    cache.emplace(k, ans);
    return ans;
  }
  int tmp = r0;
  r1 = f6049(r0, (r1 + 32767) % 32768, r7);
  int ans = f6049((tmp + 32767) % 32768, r1, r7);
  cache.emplace(k, ans);
  return ans;
}

int main() {
  for (int i = 32768; i > 1; i--) {
    cache.clear();
    int reg_0 = f6049(4, 1, i);
    printf("trying %d...\n", i);
    if (reg_0 == 6) {
      printf("reg0: %d\n", reg_0);
      printf("reg7: %d\n", i);
      break;
    }
  }
}
