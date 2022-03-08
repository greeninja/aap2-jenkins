package main

import (
	"flag"
	"fmt"
)

type arrayFlags []string

func (i *arrayFlags) String() string {
	return ""
}

func (i *arrayFlags) Set(value string) error {
	*i = append(*i, value)
	return nil
}

var packages arrayFlags

func main() {
	accessToken := flag.String("token", "<Tower Access Token>", "Tower Access Token")
	towerJobId := flag.Int("job", 11, "The ID for the Ansible Tower Job")
	debugFlag := flag.Bool("debug", false, "To enable debug logging")
	flag.Var(&packages, "package", "Package name to install")
	run := flag.Bool("run", false, "True will run start the Ansible Tower Job")
	watch := flag.Bool("watch", false, "True will watch the job run")

	flag.Parse()

	fmt.Println("Access Token:", *accessToken)
	fmt.Println("Job Id:", *towerJobId)
	fmt.Println("Debug:", *debugFlag)
	fmt.Println("Packages:", packages)
	fmt.Println("Run:", *run)
	fmt.Println("Watch", *watch)

	fmt.Println("\nStarting....\n")

	if *run == true {
		fmt.Println("Running")
	} else if *watch == true {
		fmt.Println("Watching")
	}
}
