# 本文の Pico 2 の C プログラム (out/pico/**/*.c) を全部 .uf2 にする (docs/133 の前提の層)。
# 使い方: tests/pico/uf2/build.sh  (wb-pico-sdk の Docker の中で cmake を回す)
cmake_minimum_required(VERSION 3.13)
set(PICO_BOARD pico2 CACHE STRING "Board type")
include(pico_sdk_import.cmake)
project(workbook_pico C CXX ASM)
set(CMAKE_C_STANDARD 11)
pico_sdk_init()

file(GLOB_RECURSE PROGRAMS ${PICO_PROGRAMS_DIR}/*.c)
foreach(SRC ${PROGRAMS})
    get_filename_component(NAME ${SRC} NAME_WE)
    add_executable(${NAME} ${SRC})
    target_compile_options(${NAME} PRIVATE -Wall -Wextra)
    target_link_libraries(${NAME} pico_stdlib hardware_adc hardware_dma hardware_i2c hardware_irq
        hardware_pio hardware_pwm hardware_spi hardware_uart hardware_clocks)
    pico_add_extra_outputs(${NAME})
endforeach()
