package config

import (
	"reflect"
	"testing"
)

func TestConfigTestIDs(t *testing.T) {
	cases := []struct {
		name string
		in   string
		want []string
	}{
		{"empty means run all", "", nil},
		{"blank means run all", "   ", nil},
		{"single id", "getresources-vpc-has-compliant-flow-log-passes", []string{"getresources-vpc-has-compliant-flow-log-passes"}},
		{"comma separated", "a,b,c", []string{"a", "b", "c"}},
		{"trims spaces around commas", " a , b ,c ", []string{"a", "b", "c"}},
		{"drops empty segments", "a,,b,", []string{"a", "b"}},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			c := &Config{TestID: tc.in}
			if got := c.TestIDs(); !reflect.DeepEqual(got, tc.want) {
				t.Fatalf("TestIDs(%q) = %v, want %v", tc.in, got, tc.want)
			}
		})
	}
}
