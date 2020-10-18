cmake_minimum_required(VERSION 3.5.1)

# For Protobuf's cmake warnings
if(POLICY CMP0077)
  cmake_policy(SET CMP0077 NEW)
endif()

project(hello C CXX)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

find_package(Threads REQUIRED)

# Find Protobuf installation
# Looks for protobuf-config.cmake file installed by Protobuf's cmake installation.
set(protobuf_MODULE_COMPATIBLE TRUE)
find_package(Protobuf CONFIG REQUIRED)
message(STATUS "Using protobuf ${Protobuf_VERSION}")

set(_PROTOBUF_LIBPROTOBUF protobuf::libprotobuf)
set(_REFLECTION gRPC::grpc++_reflection)
find_program(_PROTOBUF_PROTOC protoc)

# Find gRPC installation
# Looks for gRPCConfig.cmake file installed by gRPC's cmake installation.
find_package(gRPC CONFIG REQUIRED)
message(STATUS "Using gRPC ${gRPC_VERSION}")

set(_GRPC_GRPCPP gRPC::grpc++)
find_program(_GRPC_CPP_PLUGIN_EXECUTABLE grpc_cpp_plugin)

# Protos
get_filename_component(h_proto "hello.proto" ABSOLUTE)
get_filename_component(h_proto_path "${h_proto}" PATH)

# Generated sources
set(h_proto_srcs "${CMAKE_CURRENT_BINARY_DIR}/hello.pb.cc")
set(h_proto_hdrs "${CMAKE_CURRENT_BINARY_DIR}/hello.pb.h")
set(h_grpc_srcs "${CMAKE_CURRENT_BINARY_DIR}/hello.grpc.pb.cc")
set(h_grpc_hdrs "${CMAKE_CURRENT_BINARY_DIR}/hello.grpc.pb.h")
add_custom_command(
  OUTPUT "${h_proto_srcs}" "${h_proto_hdrs}" "${h_grpc_srcs}" "${h_grpc_hdrs}"
  COMMAND ${_PROTOBUF_PROTOC}
  ARGS --grpc_out "${CMAKE_CURRENT_BINARY_DIR}"
    --cpp_out "${CMAKE_CURRENT_BINARY_DIR}"
    -I "${h_proto_path}"
    --plugin=protoc-gen-grpc="${_GRPC_CPP_PLUGIN_EXECUTABLE}"
    "${h_proto}"
  DEPENDS "${h_proto}")

# Generated sources headers
include_directories("${CMAKE_CURRENT_BINARY_DIR}")

# Targets (the binaries)
foreach(_target
  hello_client hello_server)
  add_executable(${_target} "${_target}.cc"
    ${h_proto_srcs}
    ${h_grpc_srcs})
  target_link_libraries(${_target}
    ${_REFLECTION}
    ${_GRPC_GRPCPP}
    ${_PROTOBUF_LIBPROTOBUF})
endforeach()
