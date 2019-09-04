package main

import (
        "bytes"
        "fmt"
        "github.com/dutchcoders/go-clamd"
        "io/ioutil"
        "os"
        "path/filepath"
)

func main() {
        err := filepath.Walk(".",
                func(path string, info os.FileInfo, err error) error {
                        if err != nil {
                                return err
                        }
                        //    fmt.Println(path, info.Size())
                        if !info.IsDir() {
                                //      continue
                                myscan(path)
                        }
                        return nil
                })
        if err != nil {
                fmt.Printf("%v\n", err)
        }
}

func myscan(scanfile string) {
        c := clamd.NewClamd("tcp://clamav.intr:3310")
        _ = c

        fmt.Printf(scanfile + "\t")
        filebyte, err := ioutil.ReadFile(scanfile)
        if err != nil {
                fmt.Printf("ReadFile: %v\n", err)
        }
        reader := bytes.NewReader(filebyte)
        response, err := c.ScanStream(reader, make(chan bool))

        for s := range response {
                fmt.Printf("%v %v\n", s, err)
        }
}

