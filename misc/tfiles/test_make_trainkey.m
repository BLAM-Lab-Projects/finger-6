clear all

finger_index = [[1:5] [1:5]];
symbkey = [randperm(5), 5+randperm(5)];
% up to here is already handled in the code    

ind = rand(1,5)<.5; % random number from 1:10
ind = [ind 1-ind];
o = [1:5 1:5];
symbkey_init_train = symbkey(o+5*ind);

