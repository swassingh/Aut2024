# DEFINITIONS

listofstates = ["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"]
statetosearch = "Washington"

sanitycheck = len(listofstates) # 50
print(sanitycheck)

# EXACT MATCH SEARCH (basically yes or no) - User can understand the result. Can be cheap.

for state in listofstates:
    if state == statetosearch:
        print("Found it!")
        break

isfound = False
for state in listofstates:
    if state == statetosearch:
        isfound = True

if isfound == True:
    print("Found it!")
else:
    print("Not found!")

# BEST MATCH SEARCH (ranking, finds closest or best match) - Implicit ranking. Can be expensive. User may not understand the result.

# baby step to find the best match

import re

pattern = re.compile("s")

for state in listofstates:
    if pattern.search(state):
        print("Found %s!" % state)


# Find the state with the most occurrences of 's' and rank alphabetically if tied

def count_s(state):
    return state.count('s')

listofstates = ['Alaska', 'Washington', 'Texas']

# Sort the list of states first by the count of 's' in descending order, then alphabetically in ascending order
sorted_states = sorted(listofstates, key=lambda state: (-count_s(state), state))

# The best match is the first state in the sorted list
best_match = sorted_states[0]
print(f"The best match is: {best_match}")

# Print the ranking of states based on the number of 's' and alphabetically
print("Ranking of states based on 's' count and alphabetically:")
for rank, state in enumerate(sorted_states, start=1):
    print(f"{rank}. {state} (s count: {count_s(state)})")
