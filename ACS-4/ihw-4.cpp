#include <iostream>
#include <pthread.h>
#include <vector>
#include <random>

// Structure of pirates groups.
struct PirateGroup {
    // Number of group, section and information about treasure.
    int id;
    int area;
    bool foundTreasure;
};

// Structure for multi-threading, contains number of completed groups, info about all the groups and mutex.
struct SharedData {
    std::vector<PirateGroup> groups;
    pthread_mutex_t mutex;
    int completedGroups;
};

// Func for finding the treasure for every group.
void* searchTreasure(void* arg) {
    PirateGroup* group = static_cast<PirateGroup*>(arg);
    // Generating random result.
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_real_distribution<> dis(0, 7000);
    int res = dis(gen);
    if (group->id % 2 == 1) {
      int res = dis(gen);
      group->foundTreasure = (res % 5 > 2); // Found or not randomly.
    } else {
      int res = dis(gen);
      group->foundTreasure = (res % 7 > 1); // Found or not randomly.
    }
    // Output the answer.
    std::cout << "Group " << group->id << (group->foundTreasure ? " has found a treasure on the area " : " hasn't found a treasure on the area ") <<
    group->area << "\n";
    return nullptr;
}

// Func for John Silver work.
void* JohnSilver(void* arg) {
    SharedData* sharedData = static_cast<SharedData*>(arg);
    while (true) {
        // We check completed groups, so we need mutex.
        pthread_mutex_lock(&sharedData->mutex);
        // If all is done, then we start to analyze.
        if (sharedData->completedGroups == sharedData->groups.size()) {
            std::cout << "Silver summarizes results...\n";
            for (int i = 0; i < sharedData->groups.size(); ++i) {
                // Outputing tht results.
                if (sharedData->groups[i].foundTreasure) {
                  std::cout << "Group " << sharedData->groups[i].id << " has found a treasure on the area "
                  << sharedData->groups[i].area << "\n";
                } else {
                  std::cout << "Group " << sharedData->groups[i].id << " hasn't found a treasure on the area "
                  << sharedData->groups[i].area << "\n";;
                }
            }
            break; // Exit.
        }
        pthread_mutex_unlock(&sharedData->mutex);
    }
    return nullptr;
}

int main() {
  // Initializing.
  SharedData sharedData;
  sharedData.completedGroups = 0;

  std::cout << "Input the num of gropus (>= 2) \n";
  int numGroups;
  std::cin >> numGroups;

  if (numGroups < 2) {
      std::cout << " Bad input! Num of groups >= 2\n";
      return 1;
  }

  std::cout << "Input the num of areas (> number of groups) \n";
  int areas;
  std::cin >> areas;
  if (areas <= numGroups) {
    std::cout << "Bad input! Num of areas > num of groups\n";
    return 1;
  }
  sharedData.groups.resize(numGroups);

  pthread_mutex_init(&sharedData.mutex, nullptr);

  std::vector<pthread_t> pirateThreads(numGroups);

  // Creating.
  for (int i = 0; i < numGroups; ++i) {
      sharedData.groups[i].id = i + 1;
      sharedData.groups[i].foundTreasure = false;
      sharedData.groups[i].area = areas - i;
      // Starting the threads.
      pthread_create(&pirateThreads[i], nullptr, searchTreasure, &sharedData.groups[i]);
  }
  pthread_t JohnSilverThread;
  pthread_create(&JohnSilverThread, nullptr, JohnSilver, &sharedData);
  // Waiting for all groups to end.
  for (int i = 0; i < numGroups; ++i) {
      pthread_join(pirateThreads[i], nullptr);
      ++sharedData.completedGroups;
  }
  // Waiting for John Silver.
 pthread_join(JohnSilverThread, nullptr);

  // Destroying mutex and ending the program.
  pthread_mutex_destroy(&sharedData.mutex);

  return 0;
}
