# Get the number of warriors
war_num = int(input("> "));

# Generate a list from 1 to number of warriors
wars = [x for x in range(1, war_num+1)];

# Set index
index = 0;

# step of murder
step = 2;

def killer(nums, pointer, space):

    length = len(nums);

    # If list length more than 2
    if length > 2:

        # substract current pointer from length og the list
        dif = length - pointer;

        # if difference greater than space
        if dif > space:

            # increase pointer on space value
            pointer += space;

            # print and delete according item from the list
            dead_man_index = nums.pop(pointer);
            print(dead_man_index, end=' ');

            return killer(nums, pointer, space);

        else:

            pointer = space - (length - pointer);

            dead_man_index = nums.pop(pointer);
            print(dead_man_index, end=' ');

            return killer(nums, pointer, space);


    # else print all of the list and exit
    else:
        print("\nLucky men are on positions ");

        for i in nums:
            print(i, end=' ');

        print('\n');

        return 0;

killer(wars, index, step);
