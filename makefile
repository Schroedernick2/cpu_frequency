#Nicholas Schroeder	[NIS102]
# ECE 1160 - LAB4		[MAKEFILE]
# DUE 11-20-2019

work: work.cpp
	g++ --std=c++11 -o work work.cpp

clean:
	rm -rf work
