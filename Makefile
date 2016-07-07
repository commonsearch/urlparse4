clean:
	rm -rf *.so urlparse4/*.so build urlparse4/*.c urlparse4/*.cpp urlparse4/*.html dist .cache tests/__pycache__ *.rst

benchmark:
	python benchmarks/urls.py

test:
	python tests/test_*.py

docker_build:
	docker build -t commonsearch/urlparse4 .

docker_shell:
	docker run -v "$(PWD):/cosr/urlparse4:rw" -w /cosr/urlparse4 -i -t commonsearch/urlparse4 bash

docker_test:
	docker run -v "$(PWD):/cosr/urlparse4:rw" -w /cosr/urlparse4 -i -t commonsearch/urlparse4 make test

docker_benchmark:
	docker run -v "$(PWD):/cosr/urlparse4:rw" -w /cosr/urlparse4 -i -t commonsearch/urlparse4 make benchmark

build_ext:
	python setup.py build_ext --inplace