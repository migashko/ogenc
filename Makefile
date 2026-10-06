# Сборка примера (example/).
default:
	mkdir -p ./build
	cd build && cmake ..
	cmake --build ./build

release:
	mkdir -p ./build
	cd build && cmake .. -DCMAKE_BUILD_TYPE=Release
	cmake --build ./build

debug:
	mkdir -p ./build
	cd build && cmake .. -DCMAKE_BUILD_TYPE=Debug -DENABLE_WARNINGS=ON
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
