// SPDX-FileCopyrightText: 2022 localthomas
//
// SPDX-License-Identifier: MIT OR Apache-2.0

package main

import (
	"bytes"
	"crypto/md5"
	"encoding/base64"
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"log"
	"os"
	"os/exec"
	"path"
	"path/filepath"
	"strings"
)

var inputFolder = "./"
var outputFolder = "./"
var cache = "cache.json"
var fileExt = ".drawio"
var drawioCmd = "drawio"

func main() {
	flag.StringVar(&inputFolder, "inputFolder", inputFolder, "the input folder where the *.drawio files reside")
	flag.StringVar(&outputFolder, "outputFolder", outputFolder, "the output folder where the *.png and *.pdf files are stored")
	flag.StringVar(&cache, "cache", cache, "the name for the cache file that is generated in the folder")
	flag.StringVar(&fileExt, "fileExt", fileExt, "the file extension for the drawio files")
	flag.StringVar(&drawioCmd, "drawioCmd", drawioCmd, "the command to execute the drawio executable")
	flag.Parse()

	// create output folder
	err := os.MkdirAll(outputFolder, os.ModePerm)
	if err != nil {
		fmt.Printf("error creating the output folder %q: %v\n", outputFolder, err)
		os.Exit(1)
	}

	cachePath := outputFolder + "/" + cache
	c := NewCache(cachePath)
	defer func() {
		err := c.SaveTo(cachePath)
		if err != nil {
			fmt.Println("err writing cache file:", err)
		}
	}()
	f := func(path string, info os.FileInfo, err error) error {
		if err != nil {
			fmt.Printf("prevent panic by handling failure accessing a path %q: %v\n", path, err)
			return err
		}
		if info.IsDir() && info.Name() != filepath.Base(inputFolder) {
			return filepath.SkipDir
		}
		if filepath.Ext(info.Name()) == fileExt {
			hash := generateHash(path)
			cacheHash := c.GetHash(info.Name())
			if !bytes.Equal(hash, cacheHash) {
				convert(path)
				c.SetHash(info.Name(), hash)
			} else {
				fmt.Println("skipping", path)
			}
		}
		return nil
	}
	err = filepath.Walk(inputFolder, f)
	if err != nil {
		fmt.Printf("error walking the path %q: %v\n", inputFolder, err)
		os.Exit(1)
	}
}

func convert(inputFile string) {
	// convert the input file path to the output paths
	baseOutputFileWithoutExt := strings.TrimSuffix(path.Base(inputFile), filepath.Ext(inputFile))
	baseOutputPathWithoutExt := outputFolder + string(os.PathSeparator) + baseOutputFileWithoutExt

	// Note: --no-sandbox must be the last flag
	// see https://github.com/jgraph/drawio-desktop/issues/249#issuecomment-634157627
	{
		outputFile := baseOutputPathWithoutExt + ".pdf"
		fmt.Println("converting PDF", inputFile, "->", outputFile)
		err := runCmd(drawioCmd, "--crop", "-x", "-o", outputFile, "-f", "pdf", inputFile, "--no-sandbox", "--disable-gpu")
		if err != nil {
			log.Fatalf("err on executing pdf-conversion on %v: %v\n", inputFile, err)
		}
	}
	{
		outputFile := baseOutputPathWithoutExt + ".svg"
		fmt.Println("converting SVG", inputFile, "->", outputFile)
		err := runCmd(drawioCmd, "--crop", "-t", "-x", "-o", outputFile, "-f", "svg", inputFile, "--no-sandbox", "--disable-gpu")
		if err != nil {
			log.Fatalf("err on executing svg-conversion on %v: %v\n", inputFile, err)
		}
	}
	/*{
		// no PNG creation, as it is not required
		outputFile := baseOutputPathWithoutExt + ".png"
		fmt.Println("converting PNG", inputFile, "->", outputFile)
		err := runCmd(drawioCmd, "--crop", "--scale", "4", "-t", "-x", "-o", outputFile, "-f", "png", inputFile, "--no-sandbox", "--disable-gpu")
		if err != nil {
			log.Fatalf("err on executing png-conversion on %v: %v\n", inputFile, err)
		}
	}*/
}

func runCmd(args ...string) error {
	cmd := exec.Command(args[0], args[1:]...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

func generateHash(path string) []byte {
	f, err := os.Open(path)
	if err != nil {
		fmt.Println("err on open hashing file:", err)
		return nil
	}
	defer f.Close()

	h := md5.New()
	if _, err := io.Copy(h, f); err != nil {
		fmt.Println("err copying for hashing:", err)
		return nil
	}
	return h.Sum(nil)
}

//Cache stores the hashes of the files of the last run
type Cache struct {
	Hashes map[string]string
}

//NewCache reads the cache file
func NewCache(path string) *Cache {
	c := &Cache{
		Hashes: make(map[string]string),
	}
	file, err := os.Open(path)
	if err != nil {
		return c
	}
	defer file.Close()
	dec := json.NewDecoder(file)
	err = dec.Decode(c)
	if err != nil {
		fmt.Println("Err on reading JSON:", err)
	}
	return c
}

//SaveTo saves the file to path
func (c *Cache) SaveTo(path string) error {
	file, err := os.Create(path)
	if err != nil {
		return err
	}
	defer file.Close()
	file.Truncate(0)
	file.Seek(0, 0)
	enc := json.NewEncoder(file)
	err = enc.Encode(c)
	if err != nil {
		return err
	}
	return nil
}

//GetHash returns the saved hash of the file, if any
func (c *Cache) GetHash(filename string) []byte {
	hashStr, ok := c.Hashes[filename]
	if !ok {
		return nil
	}
	hash, err := base64.StdEncoding.DecodeString(hashStr)
	if err != nil {
		fmt.Println("Err when base64.decode string:", err)
		return nil
	}
	return hash
}

//SetHash sets the given hash
func (c *Cache) SetHash(filename string, hash []byte) {
	hashStr := base64.StdEncoding.EncodeToString(hash)
	c.Hashes[filename] = hashStr
}
