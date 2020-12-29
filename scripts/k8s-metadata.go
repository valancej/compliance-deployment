package main

import (
	"bufio"
	"fmt"
	"gopkg.in/yaml.v2"
	"io/ioutil"
	"os"
	"regexp"
	"strings"
)

type ComplianceManifest struct {
	Name      string                 `yaml:"name"`
	ImageName string                 `yaml:"imageName"`
	Labels    map[string]interface{} `yaml:"labels"`
}

func check(e error) {
	if e != nil {
		panic(e)
	}
}

func main() {

	complianceYaml, err := ioutil.ReadFile("compliance_manifest.yaml")
	check(err)

	var complianceManiest ComplianceManifest

	err = yaml.Unmarshal([]byte(complianceYaml), &complianceManiest)
	check(err)

	file, err := os.Create("artifacts/pod-annotations.env")
	check(err)

	defer file.Close()

	w := bufio.NewWriter(file)

	for key, value := range complianceManiest.Labels {
		matched, err := regexp.MatchString(`anchore.stig.profile*`, key)
		check(err)

		if matched {
			newkey := strings.Replace(key, ".", "\\.", -1)
			str := fmt.Sprint(value)
			newstr := newkey + "=" + str + "\n"
			w.WriteString(newstr)
		}

	}

	w.Flush()

}
