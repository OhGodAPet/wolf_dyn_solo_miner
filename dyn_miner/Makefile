CXX = g++

all: wolf_dyn_solo_miner

wolf_dyn_solo_miner: dyn_miner.cpp dynhash.cpp dynprogram.cpp sha256.cpp uint256.cpp common.h dynhash.h dyn_miner.h dynprogram.h
	g++ -ggdb3 -fpermissive -I. *.cpp -Wl,-Bdynamic -lpthread -lcurl -lOpenCL -o wolf_dyn_solo_miner
