package main

import (
	"log"
	"net"
	"path"
	"time"

	firestorepb "google.golang.org/genproto/googleapis/firestore/v1beta1"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type server struct {
	firestorepb.FirestoreServer
}

func (s *server) Listen(in firestorepb.Firestore_ListenServer) error {
	req, err := in.Recv()
	if err != nil {
		log.Println("failed to receive:", err)
		return err
	}
	log.Printf("ListenRequest = %v", req)

	target := req.GetAddTarget()
	if target == nil {
		return status.Error(codes.InvalidArgument, "InvalidArgument")
	}

	var docs []string
	if d := target.GetDocuments(); d != nil {
		docs = d.GetDocuments()
	} else if q := target.GetQuery(); q != nil {
		parent := q.GetParent()
		for _, v := range q.GetStructuredQuery().GetFrom() {
			docs = append(docs, path.Join(parent, v.GetCollectionId()))
		}
	}

	for {
		res := &firestorepb.ListenResponse{
			ResponseType: &firestorepb.ListenResponse_DocumentChange{
				DocumentChange: &firestorepb.DocumentChange{
					Document: &firestorepb.Document{
						Name: docs[0],
						Fields: map[string]*firestorepb.Value{
							"timestamp": &firestorepb.Value{
								ValueType: &firestorepb.Value_IntegerValue{
									IntegerValue: time.Now().Unix(),
								},
							},
						},
					},
				},
			},
		}
		if err := in.Send(res); err != nil {
			log.Println("failed to send:", err)
			return err
		}
		time.Sleep(3 * time.Second)
	}
}

func main() {
	l, err := net.Listen("tcp", ":50051")
	if err != nil {
		log.Fatalln("failed to listen:", err)
	}

	s := grpc.NewServer()
	firestorepb.RegisterFirestoreServer(s, &server{})

	if err := s.Serve(l); err != nil {
		log.Fatalln("failed to serve:", err)
	}
}
