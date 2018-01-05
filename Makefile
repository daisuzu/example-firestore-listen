# Tools
PROTOC = protoc
GRPC_CPP_PLUGIN = grpc_cpp_plugin
GRPC_CPP_PLUGIN_PATH ?= `which $(GRPC_CPP_PLUGIN)`

# Paths
PROTOS_PATH = ./googleapis
API_VERSION = v1beta1

FIRESTORE_PROTO_PATH = $(PROTOS_PATH)/google/firestore/$(API_VERSION)
GOOGLE_API_PROTO_PATH = $(PROTOS_PATH)/google/api
GOOGLE_TYPE_PROTO_PATH = $(PROTOS_PATH)/google/type
GOOGLE_RPC_PROTO_PATH = $(PROTOS_PATH)/google/rpc


all: gen-pb/cpp cpp/client


.PHONY: gen-pb/cpp
gen-pb/cpp:
	$(PROTOC) -I $(PROTOS_PATH) -I $(FIRESTORE_PROTO_PATH) -I $(GOOGLE_API_PROTO_PATH) -I $(GOOGLE_TYPE_PROTO_PATH) -I $(GOOGLE_RPC_PROTO_PATH) \
		--cpp_out=$(notdir $@) $(FIRESTORE_PROTO_PATH)/*.proto $(GOOGLE_API_PROTO_PATH)/*.proto $(GOOGLE_TYPE_PROTO_PATH)/*.proto $(GOOGLE_RPC_PROTO_PATH)/*.proto
	$(PROTOC) -I $(PROTOS_PATH) -I $(FIRESTORE_PROTO_PATH) -I $(GOOGLE_API_PROTO_PATH) -I $(GOOGLE_TYPE_PROTO_PATH) -I $(GOOGLE_RPC_PROTO_PATH) \
		--grpc_out=$(notdir $@) --plugin=protoc-gen-grpc=$(GRPC_CPP_PLUGIN_PATH) $(FIRESTORE_PROTO_PATH)/*.proto $(GOOGLE_API_PROTO_PATH)/*.proto $(GOOGLE_TYPE_PROTO_PATH)/*.proto $(GOOGLE_RPC_PROTO_PATH)/*.proto

.PHONY: gen-pb/go
gen-pb/go:
	$(PROTOC) -I $(PROTOS_PATH) --go_out=plugins=grpc:$(notdir $@) $(FIRESTORE_PROTO_PATH)/*.proto


cpp/client:
	cd $(dir $@) && $(MAKE) $(notdir $@)
