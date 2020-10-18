#include <iostream>
#include <memory>
#include <string>

#include <grpcpp/grpcpp.h>
#include <grpcpp/health_check_service_interface.h>
#include <grpcpp/ext/proto_server_reflection_plugin.h>

#include "hello.grpc.pb.h"

class GreeterService final : public hello::Greeter::Service
{
  grpc::Status SayHello(grpc::ServerContext *ctx, const hello::Req *req,
                        hello::Rep *rep) override
  {
    std::string prefix("Hello, ");
    std::string suffix("!");
    rep->set_message(prefix + req->name() + suffix);
    return grpc::Status::OK;
  }
};

void RunServer()
{
  std::string addr("0.0.0.0:50051");
  GreeterService service;

  grpc::EnableDefaultHealthCheckService(true);
  grpc::reflection::InitProtoReflectionServerBuilderPlugin();

  grpc::ServerBuilder builder;
  // No auth
  builder.AddListeningPort(addr, grpc::InsecureServerCredentials());
  // Register the service
  builder.RegisterService(&service);

  // Start server
  std::unique_ptr<grpc::Server> server(builder.BuildAndStart());
  std::cout << "Server running at " << addr << std::endl;

  // Wait for shutdown
  server->Wait();
}

int main(int argc, char **argv)
{
  RunServer();
  return 0;
}
