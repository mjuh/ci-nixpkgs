package main

import (
	"bytes"
	"fmt"
	"github.com/dutchcoders/go-clamd"
	"gitlab.intr/go-hms/libs.git/hmsclient"
	"io/ioutil"
//	"mjuser"
        "gitlab.intr/go-hms/libs.git/mjuser"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"syscall"
)

func Gowalk(infectedchann chan string) {
	filepath.Walk(".", func(path string, info os.FileInfo, err error) error {
		if !info.IsDir() {
			if info.Size() < 10485760 {
				result := myscan(path)
				abs, _ := filepath.Abs(path)
				if result != "OK" {
			//		fmt.Printf("sending to infectedchann : %v\n", abs)
					infectedchann <- abs
			//		fmt.Printf("sended to infectedchann : %v\n", abs)
				}
			} else {
				fmt.Println(path, " Skiped(file size", info.Size(), " is too large)\n")
			}
		}
		return nil
	})
	close(infectedchann)
}

func main() {
var UnixAccountId string
	Infected := make([]string, 0)
	infectedchann := make(chan string)
	go Gowalk(infectedchann)
	for i := range infectedchann {
//		fmt.Println("Read from channel infectedchann : " + i)
		Infected = append(Infected, i)
	}
	if len(Infected) > 0 {
		fmt.Printf("Infected: %v\n", Infected)
                info, _  := os.Stat(Infected[0])
		uid := fmt.Sprint(info.Sys().(*syscall.Stat_t).Uid)
		u, _ := mjuser.LookupId(uid)
		if strings.HasPrefix(u.Name, "Hosting") {
			UnixAccountId = strings.Split(strings.Split(u.Name, ",")[4], "=")[1]
		}

		if UnixAccountId != "" {
			res := hmsclient.Getkey("https://api.intr/oauth/token", "malware", "***REMOVED***")
			infectedFiles := fmt.Sprint("{\"infectedFiles\":[\"" + strings.Join(Infected, "\", \"") + "\"],\"solved\":false}")
			url := fmt.Sprint("https://api.intr/unix-account/" + UnixAccountId + "/malware-report")
			fmt.Printf("POSTdata is:  %v\n", infectedFiles)
			fmt.Printf("UnixAccountId is:  %v\n", UnixAccountId)
			fmt.Printf("url is:  %v\n", url)
			postres := apiPost(url, res.Access_token, infectedFiles)
			fmt.Printf("postres is: %v\n", postres)
		}
	}
}

func myscan(scanfile string) string {
	c := clamd.NewClamd("tcp://clamav.intr:3310")
	_ = c
	filebyte, err := ioutil.ReadFile(scanfile)
	if err != nil {
		fmt.Printf("ReadFile: %v\n", err)
	}
	reader := bytes.NewReader(filebyte)
	response, err := c.ScanStream(reader, make(chan bool))
	for s := range response {
		return s.Status
	}
	return " "
}

func apiPost(posturl string, key string, payload string) []byte {
	req, err := http.NewRequest("POST", posturl, bytes.NewBuffer([]byte(payload)))
	req.Header.Set("cache-control", "no-cache")
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+key)
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		panic(err)
	}
	defer resp.Body.Close()
	contents, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		fmt.Printf("%s", err)
		os.Exit(1)
	}
	return []byte(contents)
}
