CXX = g++
CPPFLAGS += `pkg-config --cflags protobuf grpc`
CPPFLAGS += -I .
CXXFLAGS += -std=c++11
LDFLAGS += -L/usr/local/lib `pkg-config --libs protobuf grpc++ grpc` \
           -lgrpc++_reflection \
           -ldl

vpath %.cc google/firestore/v1beta1:google/api:google/type:google/rpc

client: client.o firestore.grpc.pb.o firestore.pb.o annotations.pb.o http.pb.o common.pb.o document.pb.o latlng.pb.o query.pb.o write.pb.o status.pb.o
	$(CXX) $^ $(LDFLAGS) -o $@


.PHONY: clean
clean:
	rm -f *.o client
