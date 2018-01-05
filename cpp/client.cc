#include <iostream>
#include <memory>
#include <string>

#include <grpc++/grpc++.h>
#include <google/protobuf/text_format.h>

#include "google/firestore/v1beta1/firestore.grpc.pb.h"

using google::firestore::v1beta1::Firestore;
using google::firestore::v1beta1::ListenRequest;
using google::firestore::v1beta1::ListenResponse;
using google::firestore::v1beta1::Value;

int main(int argc, char** argv) {
  grpc::string endpoint;
  std::shared_ptr<grpc::ChannelCredentials> creds;

  if (argc > 1) {
    endpoint = argv[1];
    creds = grpc::InsecureChannelCredentials();
  } else {
    endpoint = "firestore.googleapis.com:443";
    creds = grpc::GoogleDefaultCredentials();
  }

  auto channel = grpc::CreateChannel(endpoint, creds);
  std::unique_ptr<Firestore::Stub> firestore(Firestore::NewStub(channel));

  grpc::ClientContext context;
  std::shared_ptr<grpc::ClientReaderWriter<ListenRequest, ListenResponse> > stream(firestore->Listen(&context));

  ListenRequest req;
  req.set_database("projects/my-firestore/databases/(default)");

  auto* add_target = req.mutable_add_target();
  add_target->set_target_id(240);
  add_target->mutable_query()->set_parent("projects/my-firestore/databases/(default)/documents/users/100");

  auto* from = add_target->mutable_query()->mutable_structured_query()->add_from();
  from->set_collection_id("data");

  stream->Write(req);

  ListenResponse res;
  while (stream->Read(&res)) {
    if (!res.has_document_change() && !res.document_change().has_document()) {
      continue;
    }

    std::string s;
    google::protobuf::TextFormat::PrintToString(res, &s);
    std::cout << s;
  }

  return 0;
}
