default: 
	mkdir -p ./build
	cd build && cmake ..
	cmake --build ./build

disabled: 
	mkdir -p ./build
	cd build && cmake .. -DDISABLED_WARNINGS=ON
	cmake --build ./build

extra: 
	mkdir -p ./build
	cd build && cmake .. -DEXTRA_WARNINGS=ON
	cmake --build ./build

paranoid: 
	mkdir -p ./build
	cd build && cmake .. -DPARANOID_WARNINGS=ON
	cmake --build ./build

clean:
	rm -rf ./build
