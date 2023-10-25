#!/bin/bash
dart pub get
dart run build_runner build --verbose
webdev build