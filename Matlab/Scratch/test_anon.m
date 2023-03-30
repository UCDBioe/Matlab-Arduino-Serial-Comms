close all
clear all
clc



f = @add_nums;

f(2,3)

function y = add_nums(a,b)
  y = a+b;
end