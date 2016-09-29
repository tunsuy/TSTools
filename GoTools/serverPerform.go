package main

import (
	"log"
	"net"
	"strconv"
	"time"
)

var ch = make(chan int, 10)

type Server struct {
	ip          string
	normal, ssl int
}

func NewServer(ip string, normal int, ssl int) *Server {
	return &Server{ip: ip, normal: normal, ssl: ssl}
}

func (server *Server) connect() {
	_, err := net.DialTimeout("tcp", server.ip+":"+strconv.Itoa(server.normal), 2*time.Second)
	if err != nil {
		_, err := net.DialTimeout("tcp", server.ip+":"+strconv.Itoa(server.ssl), 2*time.Second)
		if err != nil {
			log.Println("connect error: ", err)
			return
		}
	}
	log.Println("Connect to %s successfully", server.ip+":"+strconv.Itoa(server.normal))
}

func main() {

	/**
	操作系统包含最大打开文件数(Max Open Files)限制, 分为系统全局的, 和进程级的限制.
	系统级限制：cat /proc/sys/fs/file-nr ——第三列
	进程级限制：ulimit -n
	突破这个进程级限制就会报下面这样的错误提示：
	socket: too many open files
	*/

	for i := 0; i < 65535; i++ {
		var server *Server = NewServer("200.200.169.136", 6800, 443)
		log.Println("i = ", strconv.Itoa(i))
		server.connect()
	}
	// var server *Server = NewServer("200.200.169.136", 6800, 443)
	// server.connect()
	<-ch
}
