cd generator
dart pub get
cd ../manager
dart pub get
cd ../metadata
./generate_sources.sh
cd ../weaver
./generate_sources.sh
cd ../weaver_generator
dart pub get
cd ..
