#include<iostream>
#include"BLSOM.h"
#include"SelectGPU.h"
#include"LoadDataSet.h"
#include<curand_kernel.h>

#define MAP_WIDTH 200
#define MAP_HEIGHT 150
#define TRAIN_NUM 200
#define EPOC_NUM 0

int WriteSOMMAP(std::string fileName, float* map, int map_vec, int map_width, int map_height) {
	std::ofstream ofs;
	ofs.open(fileName, 'w');

	if (!ofs) {
		std::cerr << "can't opne file" << std::endl;
		return EXIT_FAILURE;
	}

	ofs << map_vec << std::endl;
	ofs << map_width << std::endl;
	ofs << map_height << std::endl;

	for (int i = 1; i < map_height*map_width; i++) {
		for (int v = 0; v < map_vec; v++) {
			ofs << *map << " ";
			map++;
		}
		ofs << "\n";
	}
	ofs.close();

	return EXIT_SUCCESS;
}

int main(int argc, char** argv) {
	int device;
	int vec_dim;
	int map_width;
	int map_height;
	float* a;
	std::shared_ptr<float> map_weight;
	std::vector<float> trains;
	std::vector<float> ave_vec;
	std::vector<std::vector<float>> rotation;
	std::vector<float> sdev;

	trains = LoadTrain("C:\\Users\\Kai\\Desktop\\mori_PCA\\No1.epc", '\t');
	ave_vec = LoadAverageVector("C:\\Users\\Kai\\Desktop\\mori_PCA\\vector_Ave.txt");
	rotation = LoadRotation("C:\\Users\\Kai\\Desktop\\mori_PCA\\rotation.txt");
	sdev = LoadStandardDev("C:\\Users\\Kai\\Desktop\\mori_PCA\\sdev.txt");

	/*for (int i = 0; i < trains.size() / ave_vec.size(); i++){
		for (int j = 0; j < ave_vec.size(); j++) {
			std::cout << trains[i*ave_vec.size() + j] << " ";
		}
		std::cout << std::endl;
	}*/

	map_width = MAP_WIDTH;
	map_height = MAP_HEIGHT;
	vec_dim = ave_vec.size();

	map_weight = std::make_shared<float>(map_width*map_height*vec_dim);

	BLSOM test = BLSOM(vec_dim, map_width);
	test.Init(sdev[0], sdev[1], rotation[0].data(), rotation[1].data(), ave_vec.data());
	test.SetTrainingData(trains.data(), trains.size() / ave_vec.size());
	test.InitMapWeight();
	a = test.GetSOMMap();
	WriteSOMMAP("C:\\Users\\Kai\\Desktop\\mori_PCA\\init_batch_map.txt", a, vec_dim, map_width, test.MapHeight());

	test.Learning(50);
	a = test.GetSOMMap();
	std::cout << a[0] << std::endl;
	WriteSOMMAP("C:\\Users\\Kai\\Desktop\\mori_PCA\\result_batch_20190320.txt", a, vec_dim, map_width, test.MapHeight());

	/*--- Select GPU for BLSOM ---*/
	//SelectGPU(&device);

	//test.GetMapWeight
	
	return 0;
}