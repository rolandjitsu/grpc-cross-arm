#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>

#include <iostream>
#include <memory>
#include <string>

#include <grpcpp/grpcpp.h>
#include "hello.grpc.pb.h"

class GreeterClient
{
public:
  GreeterClient(std::shared_ptr<grpc::Channel> channel)
      : stub_(hello::Greeter::NewStub(channel)) {}

  std::string SayHello(const std::string &name)
  {
    hello::Req req;
    req.set_name(name);

    hello::Rep rep;
    grpc::ClientContext context;

    grpc::Status status = stub_->SayHello(&context, req, &rep);

    if (status.ok())
      return rep.message();
    else
    {
      std::cout << "Error " << status.error_code() << ": "
                << status.error_message()
                << std::endl;
      return "RPC failed";
    }
  }

private:
  std::unique_ptr<hello::Greeter::Stub> stub_;
};

int main(int argc, char **argv)
{
  std::string addr("127.0.0.1:50051");

  std::string name("stranger");
  if (argc > 1)
    name = std::string(argv[1]);

  std::shared_ptr<grpc::Channel> chan;
  chan = grpc::CreateChannel(addr, grpc::InsecureChannelCredentials());

  GreeterClient greeter(chan);

  std::string rep = greeter.SayHello(name);
  std::cout << rep << std::endl;

  return 0;
}
