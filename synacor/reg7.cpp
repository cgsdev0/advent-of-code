#include <stdio.h>
#include <unordered_map>

struct Key {
  int r0;
  int r1;

  bool operator==(const Key &other) const {
    return (this->r0 == other.r0) && (this->r1 == other.r1);
  }
};

template <> struct std::hash<Key> {
  std::size_t operator()(const Key &c) const {
    return std::hash<int>()(c.r0) ^ std::hash<int>()(c.r1);
  }
};

std::unordered_map<Key, int> cache;

int f6049(int r0, int r1, int r7) {
  Key k{.r0 = r0, .r1 = r1};
  auto it = cache.find(k);
  if (it != cache.end()) {
    return it->second;
  }

  if (!r0) {
    int ans = (r1 + 1) % 32768;
    cache.emplace(k, ans);
    return ans;
  }
  if (!r1) {
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
  for (int i = 1; i <= 32768; i++) {
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
